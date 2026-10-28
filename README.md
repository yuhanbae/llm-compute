# yuhanbae/llm-compute

GitHub Actions-hosted llama.cpp server for uncensored LLMs.

See `.github/workflows/` for the serving pipelines:
- `llm-compute.yml` — Qwen3.6-35B-A3B-Uncensored-Genesis (main slot)
- `serve-ablit.yml` — Mistral-NeMo-12B-Abliterated (ablit slot)

Both publish their rotating trycloudflare tunnel to Gist `7ec01cb438fa7f501847b725ed44063a`.
The stable public face is the Railway proxy: `https://proxy-production-7ec3.up.railway.app/v1`
