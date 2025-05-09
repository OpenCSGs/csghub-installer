# Knative Serving安装指引

> **官方文档：**
>
> - [Install Knative Serving using YAML files](https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/#install-a-networking-layer)
>
> _**注意：**本文档仅供参考。_

## 安装说明

Knative Serving 是 CSGHub 部署实例必续组件，在部署 CSGHub 前需要提前配置并部署好。Helm 部署通过指定`global.deployment.knative.serving.autoConfig=true`自动部署 Knative Serving。

CSGHub 通过 Knative Serving 实现推理和微调已经应用空间等实例的部署功能。

## 配置步骤

### 安装核心组件

```shell
# 安装自定义资源
kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/knative/serving-crds.yaml
    
# 安装核心组件
kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/knative/serving-core.yaml
```

### 安装网络组件

```shell
kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/knative/kourier.yaml
```

### 配置网络组件

1. 配置默认使用 Kourier

    ```shell
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
    ```

2. 【如所需】配置服务访问方式

    _提示：如果你的环境支持 LoadBalancer，请跳过。_

    ```shell
    kubectl patch service/kourier \
        --namespace kourier-system \
        --type merge \
        --patch '{"spec": {"type": "NodePort"}}'
    ```

3. 配置使用 RealDNS

    ```shell
    kubectl patch configmap/config-domain \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"app.internal":""}}' 
    ```

    `app.internal` 是一个用于暴露 ksvc 服务的二级域名，此域名不需要暴露在互联网中，因此你可以定义为任何域名，此域名解析会通过 CSGHub Helm Chart 的 coredns 组件完成。

### 配置 HPA

```shell
kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/knative/serving-hpa.yaml
```

### 禁用 KSVC Pod 缩放至 0

```shell
kubectl patch configmap/config-autoscaler \
    --namespace knative-serving \
    --type merge \
    --patch '{"data":{"enable-scale-to-zero":"false"}}'
```

### 禁用标签解析

_**提示：**如果安装时指定的域名为`example.com`，则这里应该配置`registry.example.com`，如果指定的是 IP 地址，则直接写 IP 地址。_

```shell
kubectl patch configmap/config-deployment \
    --namespace knative-serving \
    --type merge \
    --patch '{"data":{"registries-skipping-tag-resolving":"registry.example.com"}}'
```

### 验证所有服务

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

确认一切服务正常运行。