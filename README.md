# Banking Platform

The architecture consists of 5 distinct, deployable, decoupled services communicating over a shared network and shared storage volumes:
1. [Data-Generator Service](#) (Scala 3): Simulates transactions, calls HTTP Service via HTTP.
2. [HTTP Service](https://github.com/ovhfmn/HttpService) (Scala 3, Doobie, Http4s): Processes requests, saves state to Postgres, publishes events to Redpanda.
3. [Notifier Service](https://github.com/ovhfmn/Notifier) (Scala 3, FS2-Kafka): Consumes from Redpanda, processes alerts.
4. [Pipeline Service](https://github.com/ovhfmn/scala-data-pipeline) (Scala 2.13, FS2-Kafka): Consumes from Redpanda, writes JSONL/Delta batch files.
5. [Analytics Engine](https://github.com/ovhfmn/scala-spark-analytics) (Scala 2.13, Spark Batch): Processes batch data from shared storage. 
6. [Infrastructure](https://github.com/ovhfmn/scala-banking-platform) (Docker Compose): Provides shared platform services
