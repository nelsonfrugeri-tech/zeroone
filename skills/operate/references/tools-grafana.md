# Grafana

## Dashboard Best Practices

### Variables
```
$namespace = label_values(kube_namespace_created, namespace)
$service = label_values(up{namespace="$namespace"}, job)
```

### Panel Types by Use Case
| Data | Panel |
|------|-------|
| Time series trends | Time series |
| Current value | Stat / Gauge |
| Comparisons | Bar chart |
| Status overview | State timeline |
| Logs | Logs panel (Loki datasource) |

### Annotations
- Auto-annotate deploys: ArgoCD webhook → Grafana annotation API
- Incident markers: PagerDuty integration

### Version: Grafana 11.x (2026 stable)
