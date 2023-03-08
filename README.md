# KafkaBeginner

**Implementation of the course:**
**[Apache Kafka Series - Learn Apache Kafka for Beginners v3](https://www.udemy.com/course/apache-kafka/) using elixir**

- Kafka setup: I went with the docker option following the [conduktor guide](https://www.conduktor.io/kafka/how-to-start-kafka-using-docker/)


This is a simple repo to learn how to use kafka with; 
- kafka_ex
- avro
- broadway (soon)

In this project I: 
1. read a stream events from https://stream.wikimedia.org/v2/stream/recentchange
2. Parse the events.
3. Encode the parsed events using avro.
4. Publish messages through Kafka.
5. Consume messages through Kafka.

Prerequisites: 

- Docker
- Elixir 1.14.3 (compiled with Erlang/OTP 25)

Steps to run: 

- to setup zookeeper, kafka and kafka-schema-registry: 
```bash
    docker-compose up -d
```

- register schemas: 
```bash
    mix avrora.reg.schema --name "body.Wikimedia"
```

create topic: 
```bash
docker exec -it kafka1 /bin/bash

kafka-topics --bootstrap-server localhost:9092 --topic wikimedia.recent_change --create --partitions 3 --replication-factor 1
```

- In case you want to see how everythings works automatically just run: 
```bash
    iex -S mix
```

```elixir
    Wikimedia.start()
```

- In case you have producer and consumer in different terminals:

```elixir
# 1st terminal:

# Starts avro:
{:ok, pid} = Avrora.start_link()

#Starts Producer:
{:ok, pid} = GenServer.start(Wikimedia.ChangeHandler, [])

# to stop:
send(pid, :terminate)
```

```elixir
# 2nd terminal:

# Starts avro:
{:ok, pid} = Avrora.start_link()

#Starts Consumer:
{:ok, pid} = KafkaEx.GenConsumer.start_link(
    Wikimedia.Consumer,
    "wikimedia_group",
    "wikimedia.recent_change",
    0,
    auto_offset_reset: :latest,
    commit_interval: 5000, commit_threshold: 100
)

# to stop:
send(pid, :terminate)
```
