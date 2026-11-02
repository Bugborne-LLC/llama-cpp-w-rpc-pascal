# syntax=docker/dockerfile:1
ARG CUDA_VERSION=12.4.1
ARG UBUNTU_VERSION=22.04

# Stage 1: Builder
FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION} AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    cmake \
    build-essential \
    git \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone llama.cpp directly
RUN git clone --depth 1 https://github.com/ggerganov/llama.cpp.git /app/llama.cpp

WORKDIR /app/llama.cpp

# Configure CMake for standalone server with Pascal (GTX 1080 Ti) optimizations (No RPC)
RUN cmake -B build \
    -DGGML_CUDA=ON \
    -DGGML_RPC=OFF \
    -DGGML_NATIVE=OFF \
    -DGGML_AVX512=OFF \
    -DGGML_AVX2=ON \
    -DGGML_AVX=ON \
    -DGGML_CUDA_GRAPHS=OFF \
    -DGGML_CUDA_FA=OFF \
    -DGGML_CUDA_F16=OFF \
    -DCMAKE_CUDA_ARCHITECTURES=61 \
    -DGGML_CUDA_NO_VMM=ON \
    -DGGML_CUDA_FORCE_MMQ=ON \
    -DGGML_CUDA_FORCE_CUBLAS=ON \
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

# Copy the standalone llama-server binary
COPY --from=builder /app/llama.cpp/build/bin/llama-server /app/llama-server

# Safely copy any dynamic libraries if they exist
RUN --mount=type=bind,from=builder,source=/app/llama.cpp/build/bin,target=/tmp/bin \
    cp /tmp/bin/*.so* /app/ 2>/dev/null || true

ENV LD_LIBRARY_PATH=/app:$LD_LIBRARY_PATH

# Pascal GPU environment runtime variables
ENV GGML_CUDA_FORCE_MMQ=1
ENV GGML_CUDA_DISABLE_GRAPHS=1

EXPOSE 8080

ENTRYPOINT ["/app/llama-server"]
