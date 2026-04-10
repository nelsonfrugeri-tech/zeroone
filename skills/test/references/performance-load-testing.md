# Load Testing

## Load Profiles
| Profile | Pattern | Purpose |
|---------|---------|---------|
| Ramp-up | Gradual increase 0→N users | Find breaking point |
| Spike | Sudden burst | Test auto-scaling, error handling |
| Soak | Constant load for hours | Find memory leaks, connection exhaustion |
| Stress | Beyond expected capacity | Find failure modes |

## k6 Example
```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 },   // ramp up
    { duration: '5m', target: 100 },   // steady
    { duration: '2m', target: 200 },   // spike
    { duration: '5m', target: 0 },     // ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<200', 'p(99)<500'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  const res = http.get('http://localhost:3000/api/users');
  check(res, { 'status 200': (r) => r.status === 200 });
  sleep(1);
}
```

## Locust Example (Python)
```python
from locust import HttpUser, task, between

class APIUser(HttpUser):
    wait_time = between(1, 3)
    
    @task(3)
    def list_users(self):
        self.client.get("/api/users")
    
    @task(1)
    def create_user(self):
        self.client.post("/api/users", json={"name": "test"})
```

## Metrics to Watch
- Response time (p50, p95, p99)
- Error rate
- Throughput (req/s)
- Resource utilization (CPU, memory, connections)

## Tools: k6 0.54+ (2026), Locust 2.32+ (2026)
