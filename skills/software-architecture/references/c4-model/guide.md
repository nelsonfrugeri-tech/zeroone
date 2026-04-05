# C4 Model Guide

## Overview

The C4 model (Context, Containers, Components, Code) by Simon Brown provides a hierarchical
set of software architecture diagrams. Think of it as Google Maps for software — zoom in
and out at different levels of detail.

## Level 1: System Context Diagram

**Purpose:** Show how the system fits into the world around it.

**Elements:**
- Your software system (center)
- Users/personas (who uses it)
- External systems (what it integrates with)

**Rules:**
- Max 10-15 elements
- No technical details (no databases, queues)
- Label relationships with what they do, not how

**Structurizr DSL:**
```
workspace {
    model {
        customer = person "Customer" "Places orders online"
        admin = person "Admin" "Manages products and orders"

        ecommerce = softwareSystem "E-Commerce Platform" "Allows customers to browse and purchase products" {
            !tags "internal"
        }

        payment = softwareSystem "Payment Gateway" "Processes credit card payments" {
            !tags "external"
        }
        email = softwareSystem "Email Service" "Sends transactional emails" {
            !tags "external"
        }

        customer -> ecommerce "Browses products, places orders"
        admin -> ecommerce "Manages catalog and orders"
        ecommerce -> payment "Processes payments" "HTTPS"
        ecommerce -> email "Sends order confirmations" "SMTP"
    }
    views {
        systemContext ecommerce "SystemContext" {
            include *
            autoLayout
        }
    }
}
```

## Level 2: Container Diagram

**Purpose:** Show the high-level technology choices and how containers communicate.

**Elements:**
- Containers: web apps, APIs, databases, message queues, file systems
- External systems (from Level 1)
- Users (from Level 1)

**Rules:**
- A container = a separately deployable/runnable unit
- Include technology choices (e.g., "React SPA", "Python/FastAPI", "PostgreSQL")
- Show communication protocols on arrows (HTTPS, gRPC, SQL, AMQP)

**Structurizr DSL:**
```
workspace {
    model {
        customer = person "Customer"

        ecommerce = softwareSystem "E-Commerce Platform" {
            spa = container "Web App" "Product browsing and checkout" "React/TypeScript"
            api = container "API Server" "REST API for all operations" "Python/FastAPI"
            worker = container "Background Worker" "Processes async tasks" "Python/Celery"
            db = container "Database" "Stores products, orders, users" "PostgreSQL"
            cache = container "Cache" "Session and product cache" "Redis"
            queue = container "Message Queue" "Async task distribution" "RabbitMQ"
        }

        payment = softwareSystem "Payment Gateway" "" "external"

        customer -> spa "Uses" "HTTPS"
        spa -> api "Calls" "HTTPS/JSON"
        api -> db "Reads/Writes" "SQL"
        api -> cache "Reads/Writes" "Redis Protocol"
        api -> queue "Publishes tasks" "AMQP"
        worker -> queue "Consumes tasks" "AMQP"
        worker -> db "Reads/Writes" "SQL"
        api -> payment "Processes payments" "HTTPS"
    }
    views {
        container ecommerce "Containers" {
            include *
            autoLayout
        }
    }
}
```

## Level 3: Component Diagram

**Purpose:** Show the internal structure of a single container.

**Elements:**
- Components: logical groupings (controllers, services, repositories)
- Other containers they interact with

**Rules:**
- Only create for complex containers
- Components = logical, not physical (a component may span multiple files)
- Show which component talks to which external dependency

**When to create:** Only when a container is complex enough that its internal structure
needs documentation. Skip for simple containers (e.g., a Redis cache).

## Level 4: Code Diagram

**Purpose:** Class/function level detail.

**Rules:** Almost never worth maintaining manually. Use IDE navigation instead.
Only useful for complex algorithms or data structures that need visual explanation.

## Supplementary Diagrams

Beyond C4's core levels, these diagrams add context:

| Diagram | Purpose | When |
|---------|---------|------|
| **Deployment** | Which containers run where (cloud, k8s, VMs) | For ops and infra |
| **Dynamic** | Sequence of interactions for a specific use case | Complex flows |
| **System Landscape** | All systems in the organization | Enterprise context |

## Structurizr DSL Tips

```
# Tags for styling
element "external" {
    background #999999
    color #ffffff
}

# Groups for visual organization
group "Payment Domain" {
    paymentService = container "Payment Service" ...
    paymentDb = container "Payment DB" ...
}

# Deployment view
deploymentEnvironment "Production" {
    deploymentNode "AWS" {
        deploymentNode "ECS" {
            containerInstance api
            containerInstance worker
        }
        deploymentNode "RDS" {
            containerInstance db
        }
    }
}
```

## Anti-patterns

1. **Too many levels** — most projects need only Level 1 + Level 2
2. **Too much detail** — if a diagram has 30+ elements, split it
3. **Missing protocols** — always label arrows with protocol/format
4. **Mixing levels** — don't show databases in a System Context diagram
5. **Stale diagrams** — treat diagrams as code, update with the codebase

## Sources

- https://c4model.com/
- https://structurizr.com/
- https://github.com/structurizr/dsl
