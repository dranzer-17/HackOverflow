# System Architecture - Project Morpheus

## Scaled Architecture Diagram

```mermaid
graph TB
    subgraph Client["Client Layer"]
        Web[Web Browser]
        Mobile[Mobile App]
        WhatsApp[WhatsApp Bot]
    end

    subgraph LB_Layer["Load Balancing Layer"]
        LB[Application Load Balancer]
    end

    subgraph API_Layer["API Layer - FastAPI Instances"]
        API1[FastAPI Instance 1]
        API2[FastAPI Instance 2]
        API3[FastAPI Instance N]
    end

    subgraph Cache_Layer["Caching Layer"]
        Redis[(Redis Cache)]
    end

    subgraph Queue_Layer["Message Queue Layer"]
        RabbitMQ[RabbitMQ]
    end

    subgraph Stream_Layer["Event Streaming Layer"]
        Kafka[Apache Kafka]
    end

    subgraph Worker_Layer["Worker Layer"]
        Worker1[Worker 1]
        Worker2[Worker 2]
        Worker3[Worker 3]
        Worker4[Worker 4]
        Worker5[Worker 5]
    end

    subgraph Data_Layer["Data Layer"]
        MongoDB[(MongoDB Primary)]
        MongoReplica[(MongoDB Replica)]
    end

    subgraph External["External Services"]
        Gemini[Google Gemini API]
        Tavily[Tavily API]
        LinkedIn[LinkedIn Scraper]
        EmailService[Email Service]
    end

    subgraph Monitor["Monitoring & Observability"]
        CloudWatch[CloudWatch]
        Prometheus[Prometheus]
        Grafana[Grafana]
    end

    Web --> LB
    Mobile --> LB
    WhatsApp --> LB

    LB --> API1
    LB --> API2
    LB --> API3

    API1 --> Redis
    API2 --> Redis
    API3 --> Redis

    API1 --> RabbitMQ
    API2 --> RabbitMQ
    API3 --> RabbitMQ

    API1 --> Kafka
    API2 --> Kafka
    API3 --> Kafka

    RabbitMQ --> Worker1
    RabbitMQ --> Worker2
    RabbitMQ --> Worker3
    RabbitMQ --> Worker4

    Kafka --> Worker5

    Worker1 --> Gemini
    Worker2 --> Gemini
    Worker3 --> EmailService
    Worker4 --> EmailService
    Worker5 --> Tavily
    Worker5 --> LinkedIn

    API1 --> MongoDB
    API2 --> MongoDB
    API3 --> MongoDB
    MongoDB --> MongoReplica

    Worker1 --> MongoDB
    Worker2 --> MongoDB
    Worker3 --> MongoDB
    Worker4 --> MongoDB
    Worker5 --> MongoDB

    API1 -.-> CloudWatch
    API2 -.-> CloudWatch
    API3 -.-> CloudWatch
    Redis -.-> CloudWatch
    RabbitMQ -.-> CloudWatch
    Kafka -.-> CloudWatch
    MongoDB -.-> CloudWatch
    CloudWatch --> Prometheus
    Prometheus --> Grafana

    classDef apiLayer fill:#4A90E2,stroke:#2E5C8A,stroke-width:2px,color:#fff
    classDef cacheLayer fill:#DC382D,stroke:#A02820,stroke-width:2px,color:#fff
    classDef queueLayer fill:#FF6600,stroke:#CC5200,stroke-width:2px,color:#fff
    classDef dataLayer fill:#47A248,stroke:#2D6E2F,stroke-width:2px,color:#fff
    classDef workerLayer fill:#9B59B6,stroke:#6C3483,stroke-width:2px,color:#fff
    classDef monitorLayer fill:#F39C12,stroke:#B9770E,stroke-width:2px,color:#fff

    class API1,API2,API3 apiLayer
    class Redis cacheLayer
    class RabbitMQ,Kafka queueLayer
    class MongoDB,MongoReplica dataLayer
    class Worker1,Worker2,Worker3,Worker4,Worker5 workerLayer
    class CloudWatch,Prometheus,Grafana monitorLayer
```

## Component Details

### 1. Load Balancing Layer

- **Application Load Balancer**: Distributes traffic across multiple FastAPI instances
- Health checks ensure only healthy instances receive traffic
- SSL termination for HTTPS

### 2. API Layer

- **Multiple FastAPI Instances**: Horizontally scalable
- Each instance handles all routes but load is distributed
- Stateless design for easy scaling

### 3. Caching Layer (Redis)

- **User Profiles**: Fast access to frequently requested data
- **Job Listings**: Cached with TTL to reduce DB load
- **Career Recommendations**: Cache by user_id + skills hash
- **Session Storage**: JWT tokens and session data
- **Rate Limiting**: Track API call counts per user

### 4. Message Queue (RabbitMQ)

- **resume_generation**: Heavy AI processing tasks
- **presentation_generation**: Async PPT creation
- **portfolio_deploy**: Deployment tasks
- **interview_sessions**: Long-running interview processes
- **email_queue**: Bulk email sending
- Dead Letter Queues for failed tasks

### 5. Event Streaming (Kafka)

- **job-scraping**: Distributed job scraping events
- **career-recommendations**: Recommendation generation events
- **user-events**: User activity analytics
- **email-events**: Email tracking and analytics

### 6. Worker Layer

- **Stateless Workers**: Process tasks from queues
- Auto-scaling based on queue depth
- Retry logic for failed tasks

### 7. Data Layer

- **MongoDB Primary**: Write operations
- **MongoDB Replicas**: Read operations for better performance
- Connection pooling for efficient resource usage

### 8. Monitoring & Observability

- **CloudWatch**: Metrics, logs, and alarms
- **Prometheus**: Advanced metrics collection
- **Grafana**: Visual dashboards and alerting

## Data Flow Examples

### Career Recommendation Request

```
User → LB → API Instance → Redis (check cache)
                                    ↓ (cache miss)
                              RabbitMQ → Worker → Gemini API
                                    ↓
                              Redis (store result) → MongoDB (persist)
                                    ↓
                              User (response)
```

### Job Scraping Flow

```
Scheduler → Kafka Producer → Kafka Topic (job-scraping)
                                    ↓
                              Multiple Workers consume
                                    ↓
                              Tavily/LinkedIn APIs
                                    ↓
                              MongoDB (store jobs)
                                    ↓
                              Redis (cache job listings)
```

### Resume Generation Flow

```
User Request → API → RabbitMQ (resume_generation queue)
                                    ↓
                              Worker picks task
                                    ↓
                              Gemini API (AI processing)
                                    ↓
                              MongoDB (save resume)
                                    ↓
                              Redis (cache for quick access)
                                    ↓
                              User (download PDF)
```

## Scaling Strategy

1. **Horizontal Scaling**: Add more FastAPI instances behind load balancer
2. **Auto-scaling**: Scale workers based on queue depth
3. **Database Scaling**: Read replicas for MongoDB
4. **Cache Scaling**: Redis Cluster for high availability
5. **Queue Scaling**: Kafka partitions for parallel processing
