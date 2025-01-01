# Этап 1: Сборка
FROM alpine:latest AS builder

# Установка необходимых пакетов для сборки
RUN apk update && apk add --no-cache \
    curl \
    && rm -rf /var/cache/apk/*

# Установка Zig
ENV ZIG_VERSION 0.13.0
RUN curl -L https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz | tar xJ && \
    mv zig-linux-x86_64-${ZIG_VERSION} /usr/local/zig && \
    rm -rf zig-linux-x86_64-${ZIG_VERSION}.tar.xz
ENV PATH="/usr/local/zig:$PATH"


 