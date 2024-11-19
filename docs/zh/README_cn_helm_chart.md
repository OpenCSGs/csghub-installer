# CSGHub Helm Chart 安装部署文档

## 概述

CSGHub 是一个开源、可信的大模型资产管理平台，可帮助用户治理 LLM 及其应用生命周期中涉及到的资产（数据集、模型文件、代码等）。基于 CSGHub，用户可以通过 Web 界面、Git 命令行或者自然语言 Chatbot 等方式，实现对模型文件、数据集、代码等资产的操作，包括上传、下载、存储、校验和分发；同时平台提供微服务子模块和标准化 API，便于用户与自有系统集成。

CSGHub 致力于为用户带来针对大模型原生设计的、可私有化部署离线运行的资产管理平台。CSGHub 提供类似私有化的 Hugging Face 功能，以类似 OpenStack Glance 管理虚拟机镜像、Harbor 管理容器镜像以及 Sonatype Nexus 管理制品的方式，实现对 LLM 资产的管理。

## 说明

### 部署说明

本 Helm Chart 目前仅包含了必要组件的必要资源的创建。如使用过程中遇到任何问题可以提交反馈到项目 [csghub-installer](https://github.com/OpenCSGs/csghub-installer/issues) 。

### 版本说明

目前 CSGHub Helm Chart 的版本和 CSGHub 版本保持一致。

| Chart version | CSGHub version | Remark |
| :-----------: | :------------: | ------ |
|     1.0.x     |     v1.0.x     |        |
|     0.9.x     |     v0.9.x     |        |
|     0.8.x     |     v0.8.x     |        |

### 组件介绍

下面将介绍 CSGHub Helm Chart 部署时创建的必要组件。

- **csghub_server：** 提供主要的服务逻辑和 API 接口，以处理客户端请求和服务交互。

- **csghub_portal：** 负责用户界面的管理和展示，供用户直接与系统进行交互。

- **csghub_user：** 管理用户身份、认证及相关操作，确保用户的安全和数据隐私。

- **csghub_nats：** 实现微服务间的消息传递和事件驱动架构，提供高效的异步通信能力。

- **csghub_proxy：** 用于请求的转发和负载均衡，保证系统在不同服务间的通信顺畅。

- **csghub_accounting：** 负责财务和账务处理，监控交易并生成相关报表。

- **csghub_mirror：** 提供仓库同步服务，确保仓库数据的高效同步。

- **csghub_runner：** 负责部署应用实例到 Kubernetes 集群。

- **csghub_builder：** 主要负责构建应用镜像并上传到容器镜像仓库。

- **csghub_watcher：** 监控所有 secret 和 configmap 的变动，管理 pod 依赖。

- **gitaly：** CSGHub 的 Git 存储后端，提供 Git 操作的高效实现。

- **gitlab-shell：** 提供 CSGHub 与 Gitaly 仓库之间的 Git over SSH 交互，用于 Git 操作的 SSH 访问。

- **ingress-nginx：** 作为 Kubernetes 集群中的入口控制器，管理外部访问到内部服务的流量。

- **minio：** 为 csghub_server 、csghub_portal 和 gitaly 提供对象存储服务，以支持文件存储和访问。

- **postgresql：** 关系型数据库管理系统，负责存储和管理（csghub_server/csghub_portal/casdoor）结构化数据。

- **registry：** 提供容器镜像仓库，便于存储和分发容器镜像。

- **redis：** 为 csghub_builder 和 csghub_mirror 提供高性能的缓存和数据存储服务，支持快速数据读取和写入。

- **casdoor：** 负责用户身份验证和授权，提供单点登录（SSO）和多种认证方式。

- **coredns：** 用于处理和解析内部 DNS 解析。

- **fluentd：** 日志收集和处理框架，聚合和转发应用程序日志，便于分析和监控。

### 数据持久化

CSGHub Helm Chart 存在多个组件需要持久化数据，包含的组件如下：

- PostgreSQL ( 默认 50Gi )
- Redis ( 默认 10Gi )
- Minio ( 默认 200Gi )
- Registry ( 默认 200Gi )
- Gitaly ( 默认 200Gi )
- Builder ( 默认 50Gi )
- Nats ( 默认 10Gi )
- GitLab-Shell ( 默认 1Gi )

在实际部署过程中需要根据使用情况，自定义 PVC 的大小，或者直接使用可扩展的 StorageClass。

以上持久化存储通过 PVC 自动申请创建 PV，因此需要您的 Kubernetes 集群支持 PV 动态管理。

### 域名

CSGHub Helm Chart 仅支持域名部署（Ingress 不支持使用 IP 地址）。示例如下：

例如：指定域名为 **example.com**，部署完成后将会生成如下域名：

- **csghub.example.com：** 用于 CSGHub 服务的访问入口。
- **casdoor.example.com：** 用于访问 casdoor 统一登录系统。
- **minio.example.com：** 用于访问对象存储。
- **registry.example.com：** 用于访问容器镜像仓库。

如果您使用的域名是公网域名，请自行配置 DNS 确保以上域名可以正确解析到 Kubernetes 集群。如果是临时域名请确保宿主机的 /etc/hosts 和 Kubernetes coredns 可以解析这些域名。

### KubeConfig

CSGHub 部署时需要依赖目标集群的`.kube/config`文件，但是 `.kube/config`文件作为访问 Kubernetes 集群的私密配置文件，不应被直接置入到 `values.yaml`中，并且因为 CSGHub 支持多集群部署的特性，服务账户（serviceAccount）并不能满足 CSGHub 的运行需求。因此`.kube/config`需要必不可少，且至少需要包含对目标集群将要创建部署实例所在的命名空间的完全读写权限。

## 前置条件

硬件需求：

- x86_64/aarch64  8c16g

软件需求：

- Kubernetes 1.20+
- Helm 3.8.0+
- PV Dynamic Provisioning

## 基础环境准备

### 部署 Kubernetes

> **仅适用于没有 k8s 基础环境的用户，如果您已经具备 K8S 寄出环境，请从下章节继续配置。**

> **Tips:**
>
> - 本章节所部署服务仅供测试，未经生产环境验证。
>
> - 已有 K8S 集群可以跳过前 3 章节，直接配置 Knative Serving。

对于没有基础环境的用户，可以通过此章节快速准备部署环境。部署内容如下：

- Kubernetes 集群部署
- Helm 安装
- PV 动态管理模拟

#### 部署 Kubernetes

目前支持快速拉起 Kubernetes 环境的方式有很多，例如 K3S、MiniKube、Kubeadm、MicroK8s 等。这里主要介绍以下两种快速拉起基础环境的方式：

- **[Docker Desktop](https://docs.docker.com/desktop/kubernetes/)**

    如果您是 macOS 环境使用 Docker Desktop 或许是更加方便的方式。启用方式如下：

     `仪表盘（Dashboards）` >  `设置（Settings）` > `Kubernets` > `启用（Enable Kubernetes）` > `应用（Apply）`

    等待 Kubernetes 集群启动完成。Docker Desktop 集成的 Kubernetes 集群可以支持 PV 动态管理和 ServiceLB。此两项功能可以在部署时简化部署操作和提供 CSGHub 服务友好访问。

- **[K3S](https://docs.k3s.io/zh/quick-start)**

    K3S 同样内置了 PV Dynamic Provisioning 和 ServiceLB，且部署简单实用。部署方式如下：

    ```shell
    # 安装集群
    curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_VERSION=v1.30.4+k3s1 sh -s - --disable=traefik --bind-address=<IPv4>
    
    # 以下操作将用户 CSGHub Helm Chart 部署，正常使用 k3s 集群并不需要以下配置
    mkdir ~/.kube && cp /etc/rancher/k3s/k3s.yaml .kube/config && chmod 0400 .kube/config
    
    # 在进行下一步之前，请确认 Kubernetes 集群已经正常运行：
    # 确认节点健康
    kubectl get nodes 
    # 确认所有 Pod 已经正常运行
    kubectl get pods -A 
    ```

#### 安装 Helm

这里提供两种安装方式：

- [Official](https://helm.sh/docs/intro/install/)

    ```shell
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh && ./get_helm.sh && helm version
    ```

- Other

    ```shell
    snap install helm --classic && helm version
    ```

#### 配置 PV 动态管理

如果您的集群已经支持此特性，或者是通过以上方式启用的 Kubernetes 集群可以跳过此章节。此章节介绍的方式**仅适用于测试**，切勿用于生产环境。

此处解决方案来源于 [kubernetes-sigs/sig-storage-local-static-provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner)，详细参考 [Install local-volume-provisioner with helm](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner/blob/master/helm/README.md)。

详细配置操作如下:

1. 创建 StorageClass

    ```shell
    # 创建 namespace
    kubectl create ns kube-storage
    
    # 创建 storage class
    cat <<EOF | kubectl apply -f -
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: fast-disks
      annotations:
        storageclass.kubernetes.io/is-default-class: "true"
    provisioner: kubernetes.io/no-provisioner
    volumeBindingMode: WaitForFirstConsumer
    reclaimPolicy: Delete
    allowVolumeExpansion: true
    EOF
    ```

2. 部署 local-volume-provisoner

    ```shell
    # 添加 helm 仓库
    helm repo add sig-storage-local-static-provisioner https://kubernetes-sigs.github.io/sig-storage-local-static-provisioner
    
    # 更新仓库
    helm repo update
    
    # 创建资源文件
    helm template --debug sig-storage-local-static-provisioner/local-static-provisioner --namespace kube-storage | sed 's/registry.k8s.io/opencsg-registry.cn-beijing.cr.aliyuncs.com\/opencsg_public/g'> local-volume-provisioner.generated.yaml
    
    # 应用资源文件
    kubectl apply -f local-volume-provisioner.generated.yaml
    ```

3. 创建虚拟磁盘

    ```shell
    for flag in {a..z}; do
    	mkdir -p /mnt/fake-disks/sd${flag} /mnt/fast-disks/sd${flag} 2>/dev/null
    	mount --bind /mnt/fake-disks/sd${flag} /mnt/fast-disks/sd${flag}
    	echo "/mnt/fake-disks/sd${flag} /mnt/fast-disks/sd${flag} none bind 0 0" >> /etc/fstab
    done
    ```

    *注意：此种挂载方式无法严格控制 PV 大小，但是不影响测试使用。*

4. 功能测试

    ```shell
    cat <<EOF | kubectl apply -f -
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: local-volume-example
      namespace: default
    spec:
      serviceName: "local-volume-example-service"
      replicas: 1  # 实例数量
      selector:
        matchLabels:
          app: local-volume-example
      template:
        metadata:
          labels:
            app: local-volume-example
        spec:
          containers:
          - name: local-volume-example
            image: busybox:latest
            ports:
            - containerPort: 80
            volumeMounts:
            - name: example-storage
              mountPath: /data
      volumeClaimTemplates:
      - metadata:
          name: example-storage
        spec:
          accessModes: [ "ReadWriteOnce" ]
          resources:
            requests:
              storage: 1Gi
    EOF
    
    # 查看 pvc/pv
    kubectl get pvc
    ```

### 配置 Kubernetes

> **如果您已经具备 Kubernetes 基础环境请从此章节继续配置。**

> **提示：**
>
> - 此章节不适用于使用以上方式创建的 K8S 集群。

虽然此 Helm Chart 内置了一个简单的 Container Registry 程序用于测试，但它不提供可靠的加密访问。您仍然需要通过 [更多配置](https://github.com/containerd/containerd/blob/main/docs/hosts.md) 才能正常从 Registry 拉取镜像。请自行为生产环境准备 Registry。

- 配置 containerd 以允许使用非安全加密访问 Registry

    配置前，请确认配置文件 `/etc/containerd/config.toml` 是否存在。如果不存在，可以使用以下命令创建。

     ```shell
    mkdir -p /etc/containerd/ && containerd config default >/etc/containerd/config.toml
     ```

      1. 配置 config_path

         - containerd 2.x

          ```toml
         version = 3
           
         [plugins."io.containerd.cri.v1.images".registry]
            config_path = "/etc/containerd/certs.d"
          ```

         - Containerd 1.x

          ```toml
         version = 2
           
         [plugins."io.containerd.grpc.v1.cri".registry]
            config_path = "/etc/containerd/certs.d"
          ```

         此配置需要重新启动 containerd 服务。

      2. 重启 Containerd

         ```shell
         systemctl restart containerd
         ```
    
      3. 配置 hosts.toml
    
         ```shell
         # 该端口为本 helm 内置的 NodePort 端口，可以通过 .Values.global.registry.service.nodePort 进行修改
         mkdir /etc/containerd/certs.d/registry.example.com:32500
           
         cat <<EOF > /etc/containerd/certs.d/registry.example.com:32500/hosts.toml
         server = "https://registry.example.com:5000"
           
         [host."http://192.168.170.22:5000"]
           capabilities = ["pull", "resolve", "push"]
           skip_verify = true
         EOF
         ```
    
         *注意：此配置直接生效，无需重启*
    
      4. 验证配置
    
         ```shell
         ctr images pull --hosts-dir "/etc/containerd/certs.d" registry.example.com:5000/image_name:tag
         ```

## 部署 Knative Serving

Knative Serving 是 CSGHub 创建应用实例所必须的组件。

- [Install Knative Serving using YAML files](https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/#install-a-networking-layer)

部署如下：

1. 安装核心组件

    ```shell
    # 安装自定义资源
    kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/serving-crds.yaml
        
    # 安装核心组件
    kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/serving-core.yaml
    ```

2. 安装网络组件

    ```shell
    kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/kourier.yaml
    ```

3. 配置默认网络组件

    ```shell
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
    ```

4. 配置服务访问方式

    ```shell
    kubectl patch service/kourier \
        --namespace kourier-system \
        --type merge \
        --patch '{"spec": {"type": "NodePort"}}'
    ```

5. 配置DNS

    配置 Knative Serving 使用 RealDNS，配置如下。

    ```shell
    kubectl patch configmap/config-domain \
      --namespace knative-servings \
      --type merge \
      --patch '{"data":{"app.internal":""}}' 
    ```

    `app.internal` 是一个用于暴露 ksvc 服务的二级域名，此域名不需要暴露在互联网中，因此你可以定义为任何域名，此域名解析会通过 CSGHub Helm Chart 的 coredns 组件完成。

6. 禁用 KSVC Pod 缩放至 0

    ```shell
    kubectl patch configmap/config-autoscaler \
        --namespace knative-serving \
        --type merge \
        --patch '{"data":{"enable-scale-to-zero":"false"}}'
    ```

7. 验证所有服务

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

​	确认一切服务正常运行。

## 安装 CSGHub Helm Chart

### 手动部署

#### 创建 KubeConfig Secret

用于保存`.kube/config`的 Secret 需要我们自行创建，因为配置文件较为私密，因此并没有集成在 helm chart 中。

如果你有多个 config 文件，可以通过`.kube/config*`的方式存放在目标目录下，Secret 创建后会统一存储。

```shell
# 此命名空间后面也会用到
kubectl create ns csghub 
# 创建 Secret
kubectl -n csghub create secret generic kube-configs --from-file=/root/.kube/
```

#### 部署 CSGHub

1. 添加 helm repo

    ```shell
    helm repo add csghub https://opencsgs.github.io/csghub-installer
    helm repo update
    ```

2. 部署 CSGHub

    - `global`

        - `domain`：前面章节要求提供的[二级域名](#域名)。
        - `runner.internalDomain[i]`
            - `domain`：安装 Knative Serving 时配置的[内部域名](#配置dns)。
            - `host`：[Kourier 组件服务](#kourier-svc)暴露的`EXTERNAL-IP`地址，示例中`172.25.11.130`为本机 IP 地址。
            - `port`：[Kourier 组件服务](#kourier-svc)暴露的 80 对应的`NodePort`端口，本示例中为 `32497`。

    - **LoadBalancer**

        >**提示：**如果您是使用自动安装脚本或者所用集群不具备 LoadBalancer 供给能力，请使用 NodePort 方式安装，否则安装后 CSGHub 会占用本机 22 端口导致 SSH 无法正常登录。如果您坚持使用 LoadBalancer 服务类型安装，请提前将服务器 SSHD 服务端口修改为非 22 端口。

        ```shell
        helm install csghub csghub/csghub \
        	--namespace csghub \
        	--create-namespace \
        	--set global.domain=example.com \
        	--set global.runner.internalDomain[0].domain=app.internal \
        	--set global.runner.internalDomain[0].host=172.25.11.130 \
        	--set global.runner.internalDomain[0].port=32497
        ```

    - **NodePort**

        如果你使用的 Kubernetes 环境不具备 LoadBalancer 负载均衡功能。那么可以通过如下方式进行部署。

        ```shell
        helm install csghub csghub/csghub \
        	--namespace csghub \
        	--create-namespace \
        	--set global.domain=example.com \
        	--set global.ingress.service.type=NodePort \
        	--set global.runner.internalDomain[0].domain=app.internal \
        	--set global.runner.internalDomain[0].host=172.25.11.130 \
        	--set global.runner.internalDomain[0].port=32497
        ```

        因为配置因素，NodePort 端口被内置定义为如下映射：80/30080, 443/30443, 22/30022。

3. 配置 Knative Serving

    CSGHub Helm Chart 部署时默认使用了自签证书以减少一些不必要的问题，因此需要配置 Knative Serving 以正常拉取镜像。

    ```shell
    kubectl -n csghub get secret csghub-certs -ojsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
    kubectl -n knative-serving create secret generic csghub-registry-certs-ca --from-file=ca.crt=./ca.crt
    kubectl -n knative-serving patch deployment.apps/controller --type=json -p='[
        {
          "op": "add",
          "path": "/spec/template/spec/containers/0/env/-",
          "value": {
            "name": "SSL_CERT_DIR",
            "value": "/opt/certs/x509"
          }
        },
        {
          "op": "add",
          "path": "/spec/template/spec/volumes",
          "value": [
            {
              "name": "custom-certs",
              "secret": {
                "secretName": "csghub-registry-certs-ca"
              }
            }
          ]
        },
        {
          "op": "add",
          "path": "/spec/template/spec/containers/0/volumeMounts",
          "value": [
            {
              "name": "custom-certs",
              "mountPath": "/opt/certs/x509"
            }
          ]
        }
      ]'
    ```

4. DNS 解析

    如果您使用的是云服务器，且具备已经备案可以正常使用的域名，请自行配置 DNS 解析 `csghub.example.com`、`casdoor.example.com`、`minio.example.com`、`registry.example.com` 域名到云服务器。

    如果您是本地测试服务器，请配置宿主机和客户端的`/etc/hosts`域名解析，以及配置 Kubernetes CoreDNS，配置方式如下：

    ```shell
    # 添加自定义域名解析
    $ kubectl apply -f - <<EOF
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: coredns-custom
      namespace: kube-system
    data:
      example.server: |
        example.com {
          hosts {
            172.25.11.131 csghub.example.com csghub
            172.25.11.131 casdoor.example.com casdoor
            172.25.11.131 registry.example.com registry
            172.25.11.131 minio.example.com minio
          }
        }
    EOF
    
    # 更新 coredns pods
    $ kubectl -n kube-system rollout restart deploy coredns
    ```

5. 配置 Registry

    如果您的基础 K8S 环境使用的是 K3S，可以通过以下方式配置：

    ```shell 
    SECRET_JSON=$(kubectl -n csghub get secret csghub-registry-docker-config -ojsonpath='{.data.\.dockerconfigjson}' | base64 -d)
    REGISTRY=$(echo "$SECRET_JSON" | jq -r '.auths | keys[]')
    REGISTRY_USERNAME=$(echo "$SECRET_JSON" | jq -r '.auths | to_entries[] | .value | .username')
    REGISTRY_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.auths | to_entries[] | .value | .password')
    
    cat <<EOF > /etc/rancher/k3s/registries.yaml
    mirrors:
      docker.io:
        endpoint:
          - "https://opencsg-registry.cn-beijing.cr.aliyuncs.com"
        rewrite:
          "^rancher/(.*)": "opencsg_public/rancher/\$1"
      ${REGISTRY}:
        endpoint:
          - "https://${REGISTRY}"
    configs:
      "${REGISTRY}":
        auth:
          username: ${REGISTRY_USERNAME}
          password: ${REGISTRY_PASSWORD}
        tls:
          insecure_skip_verify: true
    EOF
    ```

    重启K3S

    ```shell
    systemctl restart k3s
    ```

6. 访问 CSGHub

    登录URL: 

    - LoadBalancer方式：http://csghub.example.com 
    - NodePort方式：http://csghub.example.com:30080

    用户名：`root`

    密码：`Root@1234`

    *更多请查看 helm install 输出，大概内容如下：*

    ```shell
    ......
    To access the CSGHub Portal®, please navigate to the following URL:
    
        http://csghub.example.com
    
    You can use the following admin credentials to log in:
         Username: root
         Password: Root@1234
    ......
    ```

### 快捷部署

使用试下方式可以快速启动 CSGHub Helm Chart 测试环境。

```shell
# <domain>: 例如 example.com
## 默认服务类型为: NodePort
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/install.sh | bash -s -- <domain>


## 提示：使用 LoadBalancer 服务类型进行安装，请提前将服务器sshd服务端口修改为非22端口，此类型会自动抢占 22 端口作为 git ssh 服务端口。
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/install.sh | INGRESS_SERVICE_TYPE=LoadBalancer bash -s -- <domain>

## 启用 NVIDIA GPU 支持
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/install.sh | ENABLE_NVIDIA_GPU=true bash -s -- <domain>
```

如果是自定义域名，请在访问前配置本地 hosts 解析。

## 故障排查

### dial tcp: lookup casdoor.example.com on 10.43.0.10:53: no such host

此问题是由于集群无法解析自定义域名，需要添加域名解析到 Kubernetes 内部的 coredns 配置中。

### ssh: connect to host csghub.example.com port 22: Connection refused

此问题由于 helm 适配时的 bug 导致，临时解决方案如下：

```shell
# 修改配置
$ kubectl -n csghub edit configmap/csghub-ingress-nginx-tcp
....
data:
  "22": csghub/csghub-gitlab-shell:22
....
# 应用配置
$ kubectl rollout restart deploy csghub-ingress-nginx-controller -n csghub
```

### 点击头像无法新建仓库

此问题已在后面的版本中修复，临时解决方案如下：

点击头像 > 账号设置 > 填写**邮箱** > 保存

### 应用空间实例不构建

此问题已在后面的版本中修复，临时解决方案如下：

点击头像 > 账号设置 > Access Token
