#!/usr/bin/env sh
set -eu

mkdir -p /app/data

cat > /app/ov.conf <<EOF
{
  "embedding": {
    "dense": {
      "provider": "${OV_EMBED_PROVIDER}",
      "api_base": "${OV_EMBED_API_BASE}",
      "api_key": "${OV_EMBED_API_KEY}",
      "model": "${OV_EMBED_MODEL}",
      "dimension": ${OV_EMBED_DIMENSION}
    }
  },
  "vlm": {
    "provider": "${OV_VLM_PROVIDER}",
    "api_base": "${OV_VLM_API_BASE}",
    "api_key": "${OV_VLM_API_KEY}",
    "model": "${OV_VLM_MODEL}"
  },
  "storage": {
    "workspace": "/app/data",
    "agfs": {
      "backend": "local"
    },
    "vectordb": {
      "backend": "local"
    }
  }
}
EOF

exec /opt/venv/bin/openviking-server --config /app/ov.conf --host 0.0.0.0 --port 1933
