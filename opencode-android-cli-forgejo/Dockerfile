# Use OpenCode's official image as the base foundation
FROM ghcr.io/anomalyco/opencode:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/bin:${PATH}"

# 1. Define Android SDK root using an absolute path
ENV ANDROID_HOME="/root/Android/Sdk"

# 2. Add platform-tools and cmdline-tools directly to PATH
ENV PATH="${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin:${PATH}"

# Install core build dependencies, OpenJDK 21, Git, and utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    forgejo-cli \
    ca-certificates \
    openjdk-21-jdk-headless \
    nodejs \
    npm \
    unzip \
    && rm -rf /var/lib/apt-get/lists/*

# 3. Install official Google Android CLI
RUN curl -fsSL https://dl.google.com/android/cli/latest/linux_x86_64/install_root.sh | bash

# 4. Install Android SDK tools, platforms, NDK, and cmake
RUN android sdk install \
    platform-tools \
    platforms/android-37.1 \
    platforms/android-37.0 \
    platforms/android-36.1 \
    platforms/android-36 \
    ndk/28.2.13676358 \
    ndk/30.0.15729638 \
    cmdline-tools/latest \
    build-tools/36.0.0 \
    build-tools/36.1.0 \
    build-tools/37.0.0 \
    cmake/3.22.1 \
    cmake/4.1.2 
    
RUN android init

WORKDIR /workspace

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command inherits OpenCode's server behavior
