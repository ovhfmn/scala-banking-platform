# Event-Driven Core Banking Infrastructure

This repository orchestrates the core real-time transactional system, featuring an isolated HTTP API layer, an asynchronous high-concurrency event notifier processing engine, and pre-configured database and streaming infrastructure.

---

## 🏗 System Architecture & Network Topology

All services communicate through a dedicated Docker bridge network (`banking_network`). This enables secure service discovery using internal container names while keeping the core infrastructure isolated from the host environment.

```
                  +-----------------------+
                  |  Redpanda Console UI  |
                  +-----------+-----------+
                              |
+-------------------+     +---+----+     +------------------------+
|   HTTP Service    |---->|Redpanda|<----+   Notifier Engine      |
|  (Scala 3 API)    |     | Stream |     | (Scala 3, Concurrency) |
+---------+---------+     +---+----+     +------------------------+
          |                                         
          |                                  
          v                                     
+-------------------+            
| PostgreSQL DB     |
+-------------------+

```

---

## 🔌 Service Endpoints & Ports

| Service Name | Host Access / URL | Internal Docker Endpoint | Purpose |
| --- | --- | --- | --- |
| **Redpanda Console** | `http://localhost:8080` | *N/A* | Web UI to monitor brokers, topics, and consumer groups. |
| **HTTP Service** | `http://localhost:8081` | `http-service:8080` | Core Scala 3 REST API interface. |
| **Redpanda Broker** | `localhost:9092` | `redpanda:29092` | Kafka wire-protocol endpoint. |
| **PostgreSQL** | `localhost:5432` | `postgres:5432` | Transactional relational database. |

---

## 💾 Infrastructure Components

### 1. PostgreSQL (Transactional Layer)

Provides transactional persistence for platform services. The database initializes automatically on first boot using `init-infra/schema.sql`.

* **Database:** `banking_db`
* **User:** `banking_user`
* **Password:** `banking_secure_password`

```sql
CREATE TABLE IF NOT EXISTS accounts (
  id TEXT PRIMARY KEY,
  balance NUMERIC NOT NULL,
  version BIGINT NOT NULL DEFAULT 0
);
```

### 2. Redpanda (Streaming Platform)

Kafka API-compatible streaming engine used for event-driven communication.

### 3. Infrastructure Initializer (`infra-init`)

A lightweight management container that handles environmental bootstrapping. It blocks until PostgreSQL and Redpanda pass their health checks, then automatically provisions the `account-events` topic (**3 partitions, 1 replica**). This ensures application services never boot into unready infrastructure.

---

## 🚀 Orchestration & Development Commands

### Spin Up the Complete Environment

To build the Scala application images and launch all infrastructure services in the background:
* **Build Performance:** Note that cold Docker builds for each service can take up to **~350 seconds** due to initial dependency resolution. Subsequent incremental builds take **~3 seconds** thanks to Docker layer caching.

```bash
docker compose up -d --build
```

### Spin Up Infrastructure Only


```bash
docker compose up -d postgres redpanda redpanda-console infra-init
```

### Verify PostgreSQL Schema Initialization

Ensure that the `schema.sql` file executed successfully against the database:

```bash
docker exec -it banking_postgres psql -U banking_user -d banking_db -c "\dt"
```

### Debugging & Accessing Containers

To open an interactive shell inside the HTTP service container for debugging or log inspection:

```bash
docker exec -u 0 -it banking_http_service bash
docker logs -f banking_notifier --tail 20
```

### Teardown & Clean Slate

To stop all services and completely **wipe out all local persistent data volumes**

```bash
docker compose down -v
```

---

## 📦 Persistent Storage Volumes

Docker named volumes are used to prevent data loss across standard container restarts:

| Volume Name | Purpose |
| --- | --- |
| `postgres_data` | Retains transactional SQL states and account data. |
| `redpanda_data` | Stores immutable cluster commit logs and streaming events. |
| `banking_data_lake` | Shared storage layer used for downstream Spark batch data integration. |

---
