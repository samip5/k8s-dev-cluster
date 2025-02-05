# DEV Kubernetes cluster

This is the cluster where I test things.


## Cluster bootstrap using ArgoCD

Cilium install aka CNI

```shell
kubectl kustomize --enable-helm kubernetes/infra/core/cilium | kubectl apply -f -
```

CoreDNS
```shell
kubectl kustomize --enable-helm kubernetes/infra/core/coredns | kubectl apply -f -
```

External Secrets Operator and token secret to go along with it
```shell
sops -d kubernetes/infra/controllers/external-secrets/secret.sops.yaml | kubectl apply -f -
kubectl kustomize --enable-helm kubernetes/infra/controllers/external-secrets | kubectl apply -f -
```

cert-manager
```shell
kubectl kustomize --enable-helm kubernetes/infra/controllers/cert-manager| kubectl apply -f -
```

Argo CD
```shell
sops -d kubernetes/infra/core/argocd/sops-secret.sops.yaml | kubectl apply -f -
kubectl kustomize --enable-helm kubernetes/infra/core/argocd | kubectl apply -f -
```

Get Argo CD admin secret

```shell
kubectl -n argocd get secret argocd-initial-admin-secret -ojson | jq -r ' .data.password | @base64d'
```

Apply app-of-apps

```shell
kubectl apply -k kubernetes/sets
```



## 💻 Nodes
| Node                          | Hostname | RAM | Storage        | Function    | Operating System |
|-------------------------------|----------|-----|----------------|-------------|------------------|
| Raspberry Pi Compute Module 4 | m1       | 8GB | 256GB NVMe SSD | Kube Master | Talos            |
| Raspberry Pi 4 Model B        | w1       | 8GB | 256GB SSD      | Kube Worker | Talos            |
