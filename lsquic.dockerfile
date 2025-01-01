# Этап 1: Сборка
FROM zig_builder:latest AS builder

# Клонирование репозитория lsquic и BoringSSL

RUN apk add --no-cache \
    perl \
    git \
    cmake \
    make \
    openssl-dev \
    libc-dev \
    linux-headers \
    musl-dev \
    binutils \
    zlib-dev \
    build-base \
    bsd-compat-headers \
    && rm -rf /var/cache/apk/*

RUN git clone --recursive https://github.com/litespeedtech/lsquic.git /opt/lsquic
RUN git clone --recursive https://github.com/google/boringssl.git /opt/boringssl

    
# Сборка BoringSSL
WORKDIR /opt/boringssl
RUN mkdir    build && cd build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="-fPIC" -DCMAKE_CXX_FLAGS="-fPIC" .. && make


# --- 
# Нужно будет боринг собрать сжатой

# Проверка наличия библиотек BoringSSL
RUN ls -l /opt/boringssl/build/crypto /opt/boringssl/build/ssl

# Сборка LSQUIC
WORKDIR /opt/lsquic/build
RUN cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="/usr/local/zig/zig" \
    -DCMAKE_C_COMPILER_ARG1="cc" \
    -DCMAKE_AR="/usr/bin/ar" \
    -DCMAKE_RANLIB="/usr/bin/ranlib" \
    -DCMAKE_C_FLAGS="-target x86_64-linux-musl" \
    -DBORINGSSL_DIR="/opt/boringssl" \
    -DBORINGSSL_LIB_crypto="/opt/boringssl/build/crypto/libcrypto.a" \
    -DBORINGSSL_LIB_ssl="/opt/boringssl/build/ssl/libssl.a" \
    -DBUILD_SHARED_LIBS=ON \
    -DLSQUIC_SHARED_LIB=1 \
    ..

# Сборка проекта
RUN make VERBOSE=1 CFLAGS="-O3 -Os -Wno-parentheses -Wno-bitwise-op-parentheses -Wno-shift-op-parentheses" CXXFLAGS="-O3 -Os -Wno-parentheses -Wno-bitwise-op-parentheses -Wno-shift-op-parentheses" LDFLAGS="-s"

# Проверка наличия библиотеки
RUN find /opt/lsquic/build -name "liblsquic.*"

RUN ls -sS /opt/lsquic/build