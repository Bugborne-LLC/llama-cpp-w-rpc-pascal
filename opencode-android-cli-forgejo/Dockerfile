FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/bin:${PATH}"
# Include OpenCode's install directory in the global PATH
ENV PATH="/root/.opencode/bin:/root/.local/bin:/usr/local/bin:${PATH}"
# 1. Define SDK root using an absolute path (assuming root user)
ENV ANDROID_HOME="/root/Android/Sdk"

# 2. Add platform-tools and cmdline-tools directly to PATH
ENV PATH="${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin:${PATH}"

# Install core build dependencies, OpenJDK 21, Node.js, and utilities via apt
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    forgejo-cli \
    ca-certificates \
    openjdk-21-jdk-headless \
    nodejs \
    npm \
    && rm -rf /var/lib/apt-get/lists/*

# Install OpenCode CLI via script
RUN curl -fsSL https://opencode.ai/v2/install | bash
# Pre-create configuration directory
RUN mkdir -p /root/.config/opencode

# 3. Install official Google Android CLI (works natively on Ubuntu with root/bash)
RUN curl -fsSL https://dl.google.com/android/cli/latest/linux_x86_64/install_root.sh | /bin/bash

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

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command if none is supplied at runtime:
CMD ["opencode", "serve", "--hostname", "0.0.0.0", "--port", "4096"]
