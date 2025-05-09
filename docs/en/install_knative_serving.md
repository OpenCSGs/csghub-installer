# Knative Serving Installation Guide

> **Official Documentation:**
>
> - [Install Knative Serving using YAML files](https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/#install-a-networking-layer)
>
> _**Note:** This document is for reference only._

## Installation Instructions

Knative Serving is a required component for CSGHub deployment instances. You need to configure and deploy it before deploying CSGHub. Helm deployment automatically deploys Knative Serving by specifying `global.deployment.knative.serving.autoConfig=true`.

CSGHub uses Knative Serving to implement reasoning and fine-tuning of deployment functions such as application spaces.

## Steps

### Installing core components

```shell
# Installing Custom Resources
kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/knative/serving-crds.yaml
    
# Installing core components
kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/knative/serving-core.yaml
```

### Installing network components

```shell
kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/knative/kourier.yaml
```

### Configuring default network components

1. Configure network using Kourier

    ```shell
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
    ```

2. [Option] Configure service access method

    *Tips: If your environment supports LoadBalancer, skip this step.*

    ```shell
    kubectl patch service/kourier \
        --namespace kourier-system \
        --type merge \
        --patch '{"spec": {"type": "NodePort"}}'
    ```

3. Configuring DNS

    ```shell
    kubectl patch configmap/config-domain \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"app.internal":""}}' 
    ```

    `app.internal` is a secondary domain name used to expose the ksvc service. This domain name does not need to be exposed to the Internet, so you can define it as any domain name. This domain name resolution will be completed through the coredns component of the CSGHub Helm Chart.

### Configure using HPA

```shell
kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/knative/serving-hpa.yaml
```

### Disable ksvc pod scaling to 0

```shell
kubectl patch configmap/config-autoscaler \
    --namespace knative-serving \
    --type merge \
    --patch '{"data":{"enable-scale-to-zero":"false"}}'
```

### Disable tag resolving

_**Tips:** If the domain name specified during installation is `example.com`, then `registry.example.com` should be configured here. If the IP address is specified, then write the IP address directly._

```shell
kubectl patch configmap/config-deployment \
    --namespace knative-serving \
    --type merge \
    --patch '{"data":{"registries-skipping-tag-resolving":"registry.example.com"}}'
```

### Verify services

```shell
$ kubectl -n kourier-system get service kourier
NAME      TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
kourier   NodePort   10.43.190.125   <none>        80:32497/TCP,443:30876/TCP   42m
    
$ kubectl -n knative-serving get pods
NAME                                     READY   STATUS    RESTARTS   AGE
activator-665d7d76b7-fc2x5               1/1     Running   0          42m
autoscaler-779b955d67-zpcqr              1/1     Running   0          42m
controller-69b7d4cd45-r2cnl              1/1     Running   0          18m
net-kourier-controller-cf85dbc87-rbfpw   1/1     Running   0          42m
webhook-6c655cb488-2mm26                 1/1     Running   0          42m
```

Confirm that all services are running normally.