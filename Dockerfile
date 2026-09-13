ARG CUDA_VERSION=12.8.1
ARG UBUNTU_VERSION=24.04

# Stage 1: Builder
FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION} AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    cmake \
    build-essential \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the submodule source directly into the image
COPY llama.cpp /app/

# Configure CMake with CUDA and RPC enabled
RUN cmake -B build \
    -DGGML_CUDA=ON \
    -DGGML_RPC=ON \
    -DGGML_CUDA_GRAPHS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --config Release -j$(nproc)

# Stage 2: Minimal Runtime Image
FROM nvidia/cuda:${CUDA_VERSION}-runtime-ubuntu${UBUNTU_VERSION} AS runtime

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libgomp1 \
    libcurl4 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/build/bin/llama-server /app/llama-server
COPY --from=builder /app/build/bin/rpc-server /app/rpc-server
COPY --from=builder /app/build/bin/*.so* /app/ 2>/dev/null || true

EXPOSE 8080

ENTRYPOINT ["/app/llama-server"]
