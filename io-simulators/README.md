```sh
argocd app create io-simulators \
  --repo https://github.com/MyDecisive/example-argocd.git \
  --revision rlaw/mdai-labs-plus-envoy-hub-chart \
  --path io-simulators \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace mdai \
  --helm-set connection_name=testy-one \
  --sync-policy automated \
  --auto-prune \
  --port-forward \
  --port-forward-namespace="argocd" \
  --plaintext
```

```sh
argocd app sync io-simulators \
  --plaintext \
  --port-forward \
  --port-forward-namespace="argocd"
```