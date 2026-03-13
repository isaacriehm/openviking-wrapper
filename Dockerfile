# syntax=docker/dockerfile:1.9

FROM golang:1.26-trixie AS go-toolchain

FROM ghcr.io/astral-sh/uv:python3.13-trixie-slim AS py-builder
COPY --from=go-toolchain /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
 && rm -rf /var/lib/apt/lists/*

ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
ENV UV_NO_DEV=1

WORKDIR /src
RUN git clone --depth=1 https://github.com/volcengine/OpenViking.git .

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --no-editable

FROM python:3.13-slim-trixie
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libstdc++6 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=py-builder /src/.venv /app/.venv
COPY docker-entrypoint.sh /app/docker-entrypoint.sh

RUN chmod +x /app/docker-entrypoint.sh

ENV PATH="/app/.venv/bin:$PATH"
ENV OPENVIKING_CONFIG_FILE="/app/ov.conf"

EXPOSE 1933

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -fsS http://127.0.0.1:1933/health || exit 1

ENTRYPOINT ["/app/docker-entrypoint.sh"]
