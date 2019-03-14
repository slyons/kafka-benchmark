FROM rust:latest AS base

RUN USER=root cargo new --bin kafka-benchmark
WORKDIR /kafka-benchmark

RUN apt-get update && apt-get install -y libsasl2-dev

COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

RUN rm src/*.rs

COPY ./src ./src

RUN cargo build --release

FROM rust:slim

RUN apt-get update && apt-get install -y libsasl2-dev && \ 
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY --from=base /kafka-benchmark/target/release/kafka-benchmark .
RUN mkdir /config
ENTRYPOINT ["./kafka-benchmark"]