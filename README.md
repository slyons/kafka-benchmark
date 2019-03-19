# kafka-benchmark
[![Join the chat at https://gitter.im/rust-rdkafka/Lobby](https://badges.gitter.im/rust-rdkafka/Lobby.svg)](https://gitter.im/rust-rdkafka/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A tool to run programmable benchmarks on Kafka clusters.

This tool uses the high-performance
[rdkafka](https://github.com/fede1024/rust-rdkafka/) Rust client library for
Kafka (based on the C library
[librdkafka](https://github.com/edenhill/librdkafka)), and is able to produce
at extremely high speed to the cluster you want to benchmark.

Benchmark scenarios are configurable using a YAML file.

## Examples

This is an example run while producing messages to localhost, on an Intel(R)
Core(TM) i7-4712HQ CPU @ 2.30GHz:

```
→ git clone https://github.com/fede1024/kafka-benchmark.git
[...]

→ cd kafka-benchmark/

→ cargo install
[...]

→ kafka-benchmark producer config/base_producer.yaml msg_bursts_base
Scenario: msg_bursts_base, repeat 5 times, 10s pause after each
* Produced 20000000 messages (190.735 MB) in 5.045 seconds using 6 threads
    3964321 messages/s
    37.807 MB/s
* Produced 20000000 messages (190.735 MB) in 5.125 seconds using 6 threads
    3902439 messages/s
    37.217 MB/s
* Produced 20000000 messages (190.735 MB) in 5.032 seconds using 6 threads
    3974563 messages/s
    37.904 MB/s
* Produced 20000000 messages (190.735 MB) in 4.980 seconds using 6 threads
    4016064 messages/s
    38.300 MB/s
* Produced 20000000 messages (190.735 MB) in 5.036 seconds using 6 threads
    3971406 messages/s
    37.874 MB/s
Average: 3964950 messages/s, 37.813 MB/s

→ kafka-benchmark produce config/base_producer.yaml 1KB_bursts
Scenario: 1KB_bursts, repeat 3 times, 20s pause after each
* Produced 200000 messages (1.863 GB) in 2.800 seconds using 6 threads
    71429 messages/s
    681.196 MB/s
* Produced 200000 messages (1.863 GB) in 2.529 seconds using 6 threads
    79083 messages/s
    754.191 MB/s
* Produced 200000 messages (1.863 GB) in 2.514 seconds using 6 threads
    79554 messages/s
    758.691 MB/s
Average: 76492 messages/s, 729.481 MB/s
```

When producing to localhost, kafka-benchmark can send almost 4 million messages
per second on commodity hardware.

## Running in Docker

### Building the image

This build requires Docker Buildkit. You can either build it yourself locally:

```sh
DOCKER_BUILDKIT=1 docker build -t kafka-benchmark .
```

Or you can use the prebuilt one at ``slyons/rdkafka-benchmark``.

### Get the config

You can either check out this repo or use one of the config files located in the ``config`` directory.

### Run the benchmark

Assuming you've got the config files in <CONFIGDIR> and using the published docker image:
    
```sh
docker run -v <CONFIGDIR>:/config slyons/rdkafka-benchmark <producer/consumer> /config/<config filename> <scenario>
```

Or, if you're running in Kubernetes:

```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: rdkafka-bench
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: rdkafka-bench
    spec:
      containers:
      - name: rdkafka-bench
        image: slyons/rdkafka-benchmark:latest
        args: ["producer", "/config/future_producer.yaml", "1KB_bursts"]
        volumeMounts:
        - name: configvol
          mountPath: /config
```
