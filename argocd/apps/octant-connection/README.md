# Create App

```sh
curl --request POST \
  --url 'https://localhost:1443/api/v1/applications?upsert=true' \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhcmdvY2QiLCJzdWIiOiJhcGlVc2VyOmFwaUtleSIsImV4cCI6MTc4MTIxNDU1MywibmJmIjoxNzczNDM4NTUzLCJpYXQiOjE3NzM0Mzg1NTMsImp0aSI6IjVlNDBkOTNkLWU5ZjctNDMzMS1iNjBkLTNjNWMzMjM3ZjU5NyJ9.nWcg9SRSHK4wO3cWZrMPEwQ2YIa6z4quAhNExwcTadw' \
  --header 'Content-Type: application/json' \
  --header 'User-Agent: insomnia/11.3.0' \
  --data '{
  "apiVersion": "argoproj.io/v1alpha1",
  "kind": "Application",
  "metadata": {
    "name": "connection-one-app",
    "namespace": "argocd"
  },
  "spec": {
    "project": "default",
    "source": {
      "repoURL": "https://github.com/MyDecisive/example-argocd.git",
      "targetRevision": "rlaw/octant-connect",
      "path": "argocd/apps/octant-connection",
      "helm": {
        "parameters": [
          {
            "name": "ingressPort",
            "value": "8126"
          }
        ]
      }
    },
    "destination": {
      "name": "in-cluster",
      "namespace": "mdai"
    },
    "syncPolicy": {
      "automated": {
				"enabled": false,
        "prune": false,
        "selfHeal": false
      }
    }
  }
}'
```

# Add collectors to App

```sh
{
  "revision": "HEAD",
  "prune": false,
  "dryRun": false,
  "strategy": {
    "apply": {
      "force": false
    }
  },
  "manifests": [
    "{\"apiVersion\":\"v1\",\"kind\":\"Secret\",\"metadata\":{\"name\":\"connection-one-primary-secret\"},\"type\":\"Opaque\",\"stringData\":{\"api-key\":\"adfadfadf1234\",\"site-url\":\"FIXME\"}}",
    "{\"apiVersion\":\"opentelemetry.io/v1alpha1\",\"kind\":\"OpenTelemetryCollector\",\"metadata\":{\"name\":\"connection-one-primary\"},\"spec\":{\"podLabels\":{\"app\":\"connection-one-primary\"},\"image\":\"ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.147.0\",\"env\":[{\"name\":\"DD_API_KEY\",\"valueFrom\":{\"secretKeyRef\":{\"name\":\"connection-one-primary-secret\",\"key\":\"api-key\"}}},{\"name\":\"DD_SITE\",\"valueFrom\":{\"secretKeyRef\":{\"name\":\"connection-one-primary-secret\",\"key\":\"site-url\"}}}],\"config\":\"receivers:\\n  datadog:\\n    endpoint: \\\"0.0.0.0:8126\\\"\\nprocessors:\\n  batch:\\n    send_batch_size: 1000\\n    timeout: 10s\\nexporters:\\n  datadog:\\n    api:\\n      key: \\\"${env:DD_API_KEY}\\\"\\n      site: \\\"${env:DD_SITE}\\\"\\nservice:\\n  pipelines:\\n    metrics:\\n      receivers: [datadog]\\n      processors: [batch]\\n      exporters: [datadog]\\n    traces:\\n      receivers: [datadog]\\n      processors: [batch]\\n      exporters: [datadog]\\n    logs:\\n      receivers: [datadog]\\n      processors: [batch]\\n      exporters: [datadog]\"}}",
    "{\"apiVersion\":\"opentelemetry.io/v1alpha1\",\"kind\":\"OpenTelemetryCollector\",\"metadata\":{\"name\":\"connection-one-shadow\"},\"spec\":{\"podLabels\":{\"app\":\"connection-one-shadow\"},\"image\":\"ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.147.0\",\"config\":\"receivers:\\n  datadog:\\n    endpoint: \\\"0.0.0.0:8126\\\"\\nprocessors:\\n  batch:\\n    send_batch_size: 1000\\n    timeout: 10s\\nexporters:\\n  datadog:\\n    api:\\n      key: \\\"dummy-key\\\"\\n      site: \\\"http://internal-validator.svc.cluster.local\\\"\\nservice:\\n  pipelines:\\n    metrics:\\n      receivers: [datadog]\\n      processors: [batch]\\n      exporters: [datadog]\\n    traces:\\n      receivers: [datadog]\\n      processors: [batch]\\n      exporters: [datadog]\\n    logs:\\n      receivers: [datadog]\\n      processors: [batch]\\n      exporters: [datadog]\"}}"
  ]
}
```