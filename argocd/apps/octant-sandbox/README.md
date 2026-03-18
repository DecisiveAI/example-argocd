# Argo Connection Sandbox

## Create sandbox app

```sh
curl --request POST \
  --url 'https://localhost:1443/api/v1/applications?upsert=true' \
  --header 'Authorization: Bearer YOUR_ARGO_TOKEN' \
  --header 'Content-Type: application/json' \
  --data '{
  "apiVersion": "argoproj.io/v1alpha1",
  "kind": "Application",
  "metadata": {
    "name": "octant-telemetry-one",
    "namespace": "argocd"
  },
  "spec": {
    "project": "default",
    "source": {
      "repoURL": "https://github.com/MyDecisive/example-argocd.git",
      "targetRevision": "rlaw/octant-connect",
      "path": "argocd/apps/octant-sandbox",
      "kustomize": {
				"namePrefix": "octant-telemetry-one-"
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

## Create resources in sandbox

```sh
curl --request POST \
  --url https://localhost:1443/api/v1/applications/octant-telemetry-one/sync \
  --header 'Authorization: Bearer YOUR_ARGO_TOKEN' \
  --header 'Content-Type: application/json' \
  --data '{
  "revision": "HEAD",
  "prune": false,
  "dryRun": false,
  "strategy": {
    "apply": {
      "force": false
    }
  },
  "manifests": [
    "{\"apiVersion\":\"v1\",\"kind\":\"Secret\",\"metadata\":{\"name\":\"octant-telemetry-one-primary-secret\"},\"type\":\"Opaque\",\"stringData\":{\"api-key\":\"YOUR_DD_APIKEY\",\"site-url\":\"YOUR_DD_URL\"}}",
    "{\"apiVersion\":\"opentelemetry.io/v1alpha1\",\"kind\":\"OpenTelemetryCollector\",\"metadata\":{\"name\":\"octant-telemetry-one-primary\"},\"spec\":{\"podLabels\":{\"app\":\"octant-telemetry-one-primary-collector\"},\"image\":\"ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.147.0\",\"env\":[{\"name\":\"DD_API_KEY\",\"valueFrom\":{\"secretKeyRef\":{\"name\":\"octant-telemetry-one-primary-secret\",\"key\":\"api-key\"}}},{\"name\":\"DD_SITE\",\"valueFrom\":{\"secretKeyRef\":{\"name\":\"octant-telemetry-one-primary-secret\",\"key\":\"site-url\"}}}],\"config\":\"receivers:\\n  datadog:\\n    endpoint: \\\"0.0.0.0:8126\\\"\\nprocessors:\\n  batch:\\n    send_batch_size: 1000\\n    timeout: 10s\\nexporters:\\n  datadog:\\n    api:\\n      key: \\\"${env:DD_API_KEY}\\\"\\n      site: \\\"${env:DD_SITE}\\\"\\nservice:\\n  pipelines:\\n    metrics:\\n      receivers: [datadog]\\n      processors: [batch]\\n      exporters: [datadog]\\n    traces:\\n      receivers: [datadog]\\n      processors: [batch]\\n      exporters: [datadog]\\n    logs:\\n      receivers: [datadog]\\n      processors: [batch]\\n      exporters: [datadog]\"}}",
    "{\"apiVersion\":\"opentelemetry.io/v1alpha1\",\"kind\":\"OpenTelemetryCollector\",\"metadata\":{\"name\":\"octant-telemetry-one-shadow\"},\"spec\":{\"podLabels\":{\"app\":\"octant-telemetry-one-shadow-collector\"},\"image\":\"ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.147.0\",\"config\":\"receivers:\\n  datadog:\\n    endpoint: \\\"0.0.0.0:8126\\\"\\nprocessors:\\n  batch:\\n    send_batch_size: 1000\\n    timeout: 10s\\nexporters:\\n  datadog:\\n    api:\\n      key: \\\"dummy-key\\\"\\n      site: \\\"http://internal-validator.svc.cluster.local\\\"\\nservice:\\n  pipelines:\\n    metrics:\\n      receivers: [datadog]\\n      processors: [batch]\\n      exporters: [datadog]\\n    traces:\\n      receivers: [datadog]\\n      processors: [batch]\\n      exporters: [datadog]\\n    logs:\\n      receivers: [datadog]\\n      processors: [batch]\\n      exporters: [datadog]\"}}",
    "{\"apiVersion\":\"v1\",\"kind\":\"ConfigMap\",\"metadata\":{\"name\":\"octant-telemetry-one-envoy-config\"},\"data\":{\"envoy.yaml\":\"static_resources:\\n  listeners:\\n  - name: listener_0\\n    address:\\n      socket_address: { address: 0.0.0.0, port_value: 8126 }\\n    filter_chains:\\n    - filters:\\n      - name: envoy.filters.network.http_connection_manager\\n        typed_config:\\n          \\\"@type\\\": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager\\n          stat_prefix: ingress_http\\n          route_config:\\n            name: local_route\\n            virtual_hosts:\\n            - name: telemetry_service\\n              domains: [\\\"*\\\"]\\n              routes:\\n              - match: { prefix: \\\"/\\\" }\\n                route:\\n                  cluster: primary_collector\\n                  request_mirror_policies:\\n                  - cluster: shadow_collector\\n                    # runtime_fraction:\\n                    #   default_value:\\n                    #     numerator: \\n                    #     denominator: HUNDRED\\n          http_filters:\\n          - name: envoy.filters.http.router\\n            typed_config:\\n              \\\"@type\\\": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router\\n              \\n  clusters:\\n    - name: primary_collector\\n      type: STRICT_DNS\\n      lb_policy: ROUND_ROBIN\\n      load_assignment:\\n        cluster_name: primary_collector\\n        endpoints:\\n        - lb_endpoints:\\n          - endpoint:\\n              address:\\n                socket_address:\\n                  # Uses value if present, otherwise defaults to the release-named service\\n                  address: octant-telemetry-one-primary-collector\\n                  port_value: 8126\\n                  \\n    - name: shadow_collector\\n      type: STRICT_DNS\\n      lb_policy: ROUND_ROBIN\\n      load_assignment:\\n        cluster_name: shadow_collector\\n        endpoints:\\n        - lb_endpoints:\\n          - endpoint:\\n              address:\\n                socket_address:\\n                  # Uses value if present, otherwise defaults to the release-named service\\n                  address: octant-telemetry-one-shadow-collector\\n                  port_value: 8126\\n\"}}",
    "{\"apiVersion\":\"v1\",\"kind\":\"Service\",\"metadata\":{\"name\":\"octant-telemetry-one-envoy-service\"},\"spec\":{\"type\":\"ClusterIP\",\"ports\":[{\"port\":8126,\"targetPort\":8126,\"protocol\":\"TCP\",\"name\":\"http\"}],\"selector\":{\"app\":\"octant-telemetry-one-envoy\"}}}",
    "{\"apiVersion\":\"apps/v1\",\"kind\":\"Deployment\",\"metadata\":{\"name\":\"octant-telemetry-one-envoy\",\"labels\":{\"app\":\"octant-telemetry-one-envoy\"}},\"spec\":{\"replicas\":1,\"selector\":{\"matchLabels\":{\"app\":\"octant-telemetry-one-envoy\"}},\"template\":{\"metadata\":{\"labels\":{\"app\":\"octant-telemetry-one-envoy\"},\"annotations\":{\"checksum/config\":\"55a9e3174d2843e890976eb8d2154790e4793c178c385765d62fe28c166e89a0\"}},\"spec\":{\"containers\":[{\"name\":\"envoy\",\"image\":\"envoyproxy/envoy:v1.37.1\",\"ports\":[{\"containerPort\":8126}],\"volumeMount\":[{\"name\":\"envoy-config-volume\",\"mountPath\":\"/etc/envoy/envoy.yaml\",\"subPath\":\"envoy.yaml\"}]}],\"volumes\":[{\"name\":\"envoy-config-volume\",\"configMap\":{\"name\":\"octant-telemetry-one-envoy-config\"}}]}}}}"
  ]
}'
```