FROM ghcr.io/graalvm/graalvm-ce:ol8-java11-22.2.0 as build
RUN gu install native-image

COPY ./x86_64-linux-musl-native.tgz ./x86_64-linux-musl-native.tgz

RUN mkdir /musl && \
    tar -xvzf x86_64-linux-musl-native.tgz -C /musl --strip-components 1 && \
    cp /usr/lib/gcc/x86_64-redhat-linux/8/libstdc++.a /musl/lib/

ENV CC=/musl/bin/gcc

RUN curl -L -o zlib.tar.gz https://zlib.net/zlib-1.2.12.tar.gz && \
    mkdir zlib && tar -xvzf zlib.tar.gz -C zlib --strip-components 1 && \
    cd zlib && ./configure --static --prefix=/musl && \
    make && make install && \
    cd / && rm -rf /zlib && rm -f /zlib.tar.gz

ENV PATH="$PATH:/musl/bin"

RUN microdnf install xz && \
    curl -sL -o - https://github.com/upx/upx/releases/download/v3.96/upx-3.96-amd64_linux.tar.xz | tar xJ &&