The architecture consists of 5 distinct, decoupled repositories communicating over a shared network and shared storage volumes:
1. DataGenerator (Scala 3): Simulates transactions, calls HTTP Service via HTTP.
2. HTTP Service (Scala 3, Doobie, Http4s): Processes requests, saves state to Postgres, publishes events to Redpanda.
3. Notifier (Scala 3, FS2-Kafka): Consumes from Redpanda, processes alerts.
4. Pipeline Service (Scala 2.13, FS2-Kafka): Consumes from Redpanda, writes JSONL/Delta batch files.
5. Analytics Engine (Scala 2.13, Spark Batch): Processes batch data from shared storage.
