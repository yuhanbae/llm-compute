#!/bin/sh
# Fallback: point pi directly at the current trycloudflare tunnel (no /v1 suffix).
# Run when the Railway proxy returns "Application not found".
# The gist is the rotation source of truth; the tunnel rotates every ~6h,
# so this fallback must be re-run after each rotation (or the proxy restored).
GH_TOKEN=$(git config --global credential.gh_token 2>/dev/null || gh auth token 2>/dev/null)
URL=$(curl -s -H "Authorization: Bearer $GH_TOKEN" \
  "https://api.github.com/gists/7ec01cb438fa7f501847b725ed44063a" | \
  python3 -c "import json,sys; print(json.load(sys.stdin)['files']['url.txt']['content'].strip())")
echo "tunnel: $URL"
python3 - "$URL" <<'EOF'
import json, sys, os
url = sys.argv[1] + "/v1"
f = os.path.expanduser("~/.pi/agent/models.json")
mj = json.load(open(f))
p = mj["providers"]["github-llm-compute"]
old = p["baseUrl"]
p["baseUrl"] = url
json.dump(mj, open(f, "w"), indent=2)
print(f"models.json github-llm-compute.baseUrl: {old} -> {url}")
EOF
# sanity: real completion through pi runtime
cd ~/.pi/agent && node --input-type=module -e "
import {ModelRuntime} from '/data/data/com.termux/files/home/.pi/agent/npm/node_modules/@earendil-works/pi-coding-agent/dist/core/model-runtime.js';
const rt = await ModelRuntime.create({});
const m = rt.getModel('github-llm-compute','Qwen3.6-35B-A3B-Uncensored-Genesis');
const res = await rt.complete(m,{messages:[{role:'user',content:'say OK in one word'}]},{maxTokens:16});
console.log('llm-compute:', res.stopReason, res.errorMessage ? 'ERR: '+res.errorMessage : 'OK');
"
echo "note: the */10 cron (update-llm-compute-url.sh) will HEAL baseUrl back to the Railway proxy."
echo "if the proxy is down long-term, update the cron script too, or re-run this after each tunnel rotation."
