# Этап 1: Сборка
FROM zig_builder:latest AS builder

# Установка необходимых инструментов
RUN apk add --no-cache \
    git \
    cmake \
    make \
    snappy-dev \
    libc-dev \
    linux-headers \
    musl-dev \
    binutils \ 
    && rm -rf /var/cache/apk/*

# Клонирование репозитория LevelDB
RUN git clone --recursive https://github.com/iovisor/ubpf.git /opt/ubpf

RUN mkdir -p /opt/ubpf/build
WORKDIR /opt/ubpf/build

# Конфигурация проекта с использованием Zig
RUN cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="/usr/local/zig/zig" \
    -DCMAKE_CXX_COMPILER="/usr/local/zig/zig" \
    -DCMAKE_C_COMPILER_ARG1="cc" \
    -DCMAKE_CXX_COMPILER_ARG1="c++" \
    -DCMAKE_AR="/usr/bin/ar" \
    -DCMAKE_RANLIB="/usr/bin/ranlib" \
    -DCMAKE_C_FLAGS="-target x86_64-linux-musl" \
    -DCMAKE_CXX_FLAGS="-target x86_64-linux-musl" \
    -DLEVELDB_BUILD_TESTS=OFF \
    -DLEVELDB_BUILD_BENCHMARKS=OFF \
    -DBUILD_SHARED_LIBS=ON \
    ..

# Сборка проекта
# RUN make VERBOSE=1

RUN mkdir -p /opt/ubpf/lib && \
    make VERBOSE=1 CFLAGS="-O3 -Os" CXXFLAGS="-O3 -Os" LDFLAGS="-s" && \
    strip lib/libubpf.so

RUN ls -sS /opt/ubpf/build