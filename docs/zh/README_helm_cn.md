# CSGHub Helm Chart 部署文档

## 介绍

CSGHUB 项目使用 Helm Chart 作为 Kubernetes 部署的主要方式，以实现高效、可重复的应用管理。

CSGHub 的 Helm Chart 设计尽量遵循向后兼容的原则，通常情况下只需执行 `helm upgrade` 命令即可无缝部署新版本，简化了更新流程并降低了风险。此外随着架构演进，我们定期对 Helm Chart 进行重构，提升灵活性和性能，使其更加清晰易用，便于开发者自定义配置。

通过这种方式，CSGHUB 实现了灵活的部署管理，能够更快速地响应用户需求。

## 软/硬件支持

硬件环境需求：

- \>= 8c16g

- amd64/arm64

软件环境需求：

- Kubernetes 1.20+

- Helm 3.12.0+

***说明：** Kubernetes 需要支持 Dynamic Volume Provisioning。*

## 版本说明

CSGHub `major.minor` 版本和 CSGHub Server 保持一致，`Patch` 版本根据需要更新。

| Chart 版本 | Csghub 版本 | 说明                          |
| :--------: | :---------: | ----------------------------- |
|   0.8.x    |    0.8.x    |                               |
|   0.9.x    |    0.9.x    | 增加组件 Gitaly, Gitlab-Shell |
|   1.0.x    |    1.0.x    |                               |
|   1.1.x    |    1.1.x    | 增加组件 Temporal             |
|   1.2.x    |    1.2.x    |                               |
|   1.3.x    |    1.3.x    | 移除组件 Gitea                |

## 域名

CSGHub Helm Chart 部署需要使用到域名，因为 Ingress 暂不支持使用 IP 地址进行路由转发。

域名可以是公有域名也可以是自定义域名，区别如下：

**公有域名：** 可以直接使用云解析，配置方便。

**自定义域名：** 需要自行配置地址解析，主要包含所在 Kubernetes 集群的 CoreDNS 解析以及客户端主机的 hosts 解析。

域名的使用方式举例如下：

如果在安装时指定域名`example.com`，CSGHub Helm Chart 会将此域名作为父域名，创建如下子域名：

- **csghub.example.com**：用于 csghub 主服务的访问入口。
- **casdoor.example.com**：用于访问 casdoor 统一登录系统。
- **minio.example.com**：用于访问对象存储。
- **registry.example.com**：用于访问容器镜像仓库。
- **temporal.example.com**：用于访问计划任务系统。

***注意：** 无论使用哪种域名，请确保已正确配置域名解析。*

## .kube/config

`.kube/config`文件作为访问 Kubernetes 集群的重要配置文件，在 CSGHub Helm Chart 部署过程中需要以 Secret 的方式提供给 CSGHub Helm Chart。因 CSGHub 跨集群功能特性的支持，服务账户（serviceAccount）并不能满足 CSGHub 的运行需求。此 `.kube/config`至少需要包含对目标集群部署实例所在的命名空间的完全读写权限，如果开启了 argo和 KnativeServing 的自动配置，还需要创建命名空间等更多权限。

## 持久化卷

CSGHub Helm Chart 存在多个组件需要持久化数据，组件如下：

- **PostgreSQL**

  默认 50Gi，用于存储数据库数据文件。

- **Redis**

  默认 10Gi，用于存储 Redis AOF 转储文件。

- **Minio**

  默认 500Gi，用于存储 头像图像、LFS 文件，Docker Image 镜像文件。

- **Gitaly**

  默认 200Gi ，用于存储 Git 仓库数据。

- **Builder**

  默认 50Gi ，用于存储临时构建的镜像。

- **Nats**

  默认 10Gi，存储消息流相关数据。

- **GitLab-Shell**

  默认 1Gi，用于存储主机密钥对。

在实际部署过程中，需要根据使用情况调整 PVC 的大小，或者直接使用可扩展的 StorageClass。

需要注意的是 CSGHub Helm Chart  并不会主动创建相关的 Persistent Volume，而是通过创建 Persistent Volume Claim 的方式自动申请 PV 资源，因此需要您的 Kubernetes 集群支持 Dynamic Volume Provisioning。如果是自部署集群可以通过模拟的方式实现动态管理，详细参考：[kubernetes-sigs/sig-storage-local-static-provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner)。

## 部署示例

### 快速部署（用于测试目的）

目前部署支持快速部署，此种方式主要用于测试，部署方式如下：

```shell
# <domain>: 例如 example.com
# NodePort 是默认的 ingress-nginx-controller 服务类型
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm/quick_install.sh | bash -s -- example.com

## 提示：使用LoadBalancer服务类型安装时，请提前将服务器sshd服务端口改为非22端口，该类型会自动占用22端口作为 git ssh 服务端口。
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm/quick_install.sh | INGRESS_SERVICE_TYPE=LoadBalancer bash -s -- example.com

# 启用 Nvidia GPU 支持
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm/quick_install.sh | ENABLE_NVIDIA_GPU=true bash -s -- example.com
```

以上部署会自动安装/配置如下资源：

- K3S Single Node Cluster
- Helm Tools
- CSGHub Helm Chart
- CoreDNS/Hosts
- Insecure Private Container Registry

***说明：** 部署完成后，根据终端`提示信息`或者`login.txt`访问和登录 CSGHub。*

**变量说明：**

|          变量           |    默认值    | 作用                                                         |
| :---------------------: | :----------: | :----------------------------------------------------------- |
|       ENABLE_K3S        |     true     | 创建 K3S 集群                                                |
|    ENABLE_DYNAMIC_PV    |    false     | 模拟动态卷管理                                               |
|    ENABLE_NVIDIA_GPU    |    false     | 安装 nvidia-device-plugin                                    |
|       HOSTS_ALIAS       |     true     | 配置 coredns 以及本地 hosts 解析                             |
|      INSTALL_HELM       |     true     | 安装 helm 工具                                               |
|  INGRESS_SERVICE_TYPE   |   NodePort   | CSGHub 服务暴露方式，如果是 LoadBalancer 方式请确保 SSHD 服务使用非 22 端口 |
| KNATIVE_INTERNAL_DOMAIN | app.internal | KnativeServing 域名                                          |
|  KNATIVE_INTERNAL_HOST  |  127.0.0.1   | Kourier 服务地址，脚本运行时会重新赋值为本机 IPv4            |
|  KNATIVE_INTERNAL_PORT  |      80      | Kourier 服务端口，如果INGRESS_SERVICE_TYPE 为 NodePort，端口会被重新赋值为 30213 |

### 标准部署

#### 前置条件

- Kubernetes 1.20+

- Helm 3.12.0+

-  Dynamic Volume Provisioning

   或者手动创建如下持久卷:

    - PV 500Gi * 1 (for Minio)
    - PV 200Gi * 1 (for Gitaly)
    - PV 50Gi * 2 (for PostgreSQL, Builder)
    - PV 10Gi * 2 (for Redis, Nats)
    - PV 1Gi * 1 (for Gitlab-Shell)

#### 开始安装

- **添加 helm 仓库**

    ```shell
    helm repo add csghub https://opencsgs.github.io/csghub-installer
    helm repo update
    ```

- **创建 kube-configs Secret**

    ```shell
    kubectl create ns csghub 
    kubectl -n csghub create secret generic kube-configs --from-file=/root/.kube/
    ```

- **安装 CSGHub Helm Chart**

  ***注意：** 以下是简单安装，更多参数定义请参考下文。*

  **示例安装信息：**

  |                         参数                         |    默认值    |    示例值    | 说明                                                         |
      | :--------------------------------------------------: | :----------: | :----------: | :----------------------------------------------------------- |
  |                global.ingress.domain                 | example.com  | example.com  | [服务域名](#域名)                                            |
  |             global.ingress.service.type              | LoadBalancer |   NodePort   | 请确保集群服务商具备提供 LoadBalancer 服务的能力。<br>这里用到LoadBalancer 的服务有Ingress-nginx-controller Service以及Kourier。 |
  |        ingress-nginx.controller.service.type         | LoadBalancer |   NodePort   | 如果您是解压安装程序在本地安装，此参数可以省略，由内部锚点自动复制。 |
  | global.deployment.knative.serving.services[0].domain | app.internal | app.internal | 这里为预指定，会自动配置到 KnativeServing。                  |
  |  global.deployment.knative.serving.services[0].host  | 192.168.18.3 | IPv4 address | 实际配置时请指定实际的目标 Kubernetes 集群的 IPv4 地址。     |
  |  global.deployment.knative.serving.services[0].port  |      80      |    30213     | 这里为预指定，会自动配置到 KnativeServing。<br>如果 global.ingress.service.type 配置为 LoadBalancer ，请使用默认值 80。<br>如果 global.ingress.service.type 配置为 NodePort ，这里可以指定为任意 5 位合法端口号。 |
  |             global.deployment.kubeSecret             | kube-configs | kube-configs | 包含所有目标 Kubernetes 集群.kube/config 的 Secret，多个 config 可以重命名为 config 开头的文件进行区分。 |

    - **LoadBalancer**

        ```shell
        helm upgrade --install csghub csghub/csghub \
          --namespace csghub \
          --create-namespace \
          --set global.ingress.domain="example.com" \
          --set global.deployment.knative.serving.services[0].domain="app.internal" \
          --set global.deployment.knative.serving.services[0].host="192.168.18.3" \
          --set global.deployment.knative.serving.services[0].port="80"
        ```

    - **NodePort**

        ```shell
        helm upgrade --install csghub csghub/csghub \
          --namespace csghub \
          --create-namespace \
          --set global.ingress.domain="example.com" \
          --set global.ingress.service.type="NodePort" \
          --set ingress-nginx.controller.service.type="NodePort" \
          --set global.deployment.knative.serving.services[0].domain="app.internal" \
          --set global.deployment.knative.serving.services[0].host="192.168.18.3" \
          --set global.deployment.knative.serving.services[0].port="30213"
        ```

  ***说明：** 安装配置需要一段时间请耐心等待。CSGHub Helm Chart 配置完成后会自动在目标集群配置 Argo Workflow 以及 KnativeServing。*

- **访问信息**

  以 `NodePort` 安装方式为例：

    ```shell
    You have successfully installed CSGHub!
    
    Visit CSGHub at the following address:
    
        Address: http://csghub.example.com:30080
        Credentials: root/xxxxx
    
    Visit the Casdoor administrator console at the following address:
    
        Address: http://casdoor.example.com:30080
        Credentials: admin/xxx
    
    Visit the Temporal console at the following address:
    
        Address: http://temporal.example.com:30080
        Credentials:
            Username: $(kubectl get secret --namespace csghub csghub-temporal -o jsonpath="{.data.TEMPORAL_USERNAME}" | base64 -d)
            Password: $(kubectl get secret --namespace csghub csghub-temporal -o jsonpath="{.data.TEMPORAL_PASSWORD}" | base64 -d)
    
    Visit the Minio console at the following address:
    
        Address: http://minio.example.com:30080/console/
        Credentials:
            Username: $(kubectl get secret --namespace csghub csghub-minio -o jsonpath="{.data.MINIO_ROOT_USER}" | base64 -d)
            Password: $(kubectl get secret --namespace csghub csghub-minio -o jsonpath="{.data.MINIO_ROOT_PASSWORD}" | base64 -d)
    
    To access Registry using docker-cli:
    
        Endpoint: registry.example.com:30080
        Credentials:
            Username=$(kubectl get secret csghub-registry -ojsonpath='{.data.REGISTRY_USERNAME}' | base64 -d)
            Password=$(kubectl get secret csghub-registry -ojsonpath='{.data.REGISTRY_PASSWORD}' | base64 -d)
    
        Login to the registry:
            echo "$Password" | docker login registry.example.com:30080 --username $Username ---password-stdin
    
        Pull/Push images:
            docker pull registry.example.com:30080/test:latest
            docker push registry.example.com:30080/test:latest
    
    *Notes: This is not a container registry suitable for production environments.*
    
    For more details, visit:
    
        https://github.com/OpenCSGs/csghub-installer
    ```

## 外部资源

> **提示：** 使用外置服务的同时如果内置服务不禁用，则服务依然会正常启动。

### Registry

| 参数配置                              | 字段类型 | 默认值 | 说明                                                  |
| :------------------------------------ | :------- | :----- | :---------------------------------------------------- |
| global.registry.external              | bool     | false  | false：使用内置 Registry<br>true: 使用外部 Registry。 |
| global.registry.connection            | dict     | { }    | 默认为空，外部存储未配置。                            |
| global.registry.connection.repository | string   | Null   | 连接外部 Registry 仓库端点。                          |
| global.registry.connection.namespace  | string   | Null   | 连接外部 Registry 命名空间。                          |
| global.registry.connection.username   | string   | Null   | 连接外部 Registry 用户名。                            |
| global.registry.connection.password   | string   | Null   | 连接外部 Registry 密码。                              |

### PostgreSQL

| 参数配置                              | 字段类型 | 默认值  | 说明                                                         |
| :------------------------------------ | :------- | :------ | :----------------------------------------------------------- |
| global.postgresql.external            | bool     | false   | false：使用内置 PostgreSQL<br/>true: 使用外部 PostgreSQL。   |
| global.postgresql.connection          | dict     | { }     | 默认为空，外部数据库未配置。                                 |
| global.postgresql.connection.host     | string   | Null    | 连接外部数据库IP地址。                                       |
| global.postgresql.connection.port     | string   | Null    | 连接外部数据库端口号。                                       |
| global.postgresql.connection.database | string   | Null    | 连接外部数据库数据库名。<br>如果值为空，则默认使用 csghub_portal, csghub_server, csghub_casdoor, csghub_temporal, csghub_temporal_visibility 数据库名字。如果指定了数据库名字，则以上所有数据库的内容都将存储到同一个数据库中（此种方式不建议，可能导致数据表冲突）。<br/>无论是哪种方式数据库都需要自行创建。 |
| global.postgresql.connection.user     | string   | Null    | 连接外部数据库的用户。                                       |
| global.postgresql.connection.password | string   | Null    | 连接外部数据库的密码。                                       |
| global.postgresql.connection.timezone | string   | Etc/UTC | 请使用`Etc/UTC`。当前仅为预配置使用，暂无实际意义。          |

### Redis

| 参数配置                         | 字段类型 | 默认值 | 说明                                             |
| :------------------------------- | :------- | :----- | :----------------------------------------------- |
| global.redis.external            | bool     | false  | false：使用内置 Redis<br/>true: 使用外部 Redis。 |
| global.redis.connection          | dict     | { }    | 默认为空，外部Redis未配置。                      |
| global.redis.connection.host     | string   | Null   | 连接外部 Redis 的 IP 地址。                      |
| global.redis.connection.port     | string   | Null   | 连接外部 Redis 的 端口。                         |
| global.redis.connection.password | string   | Null   | 连接外部 Redis 的密码。                          |

### ObjectStore

| 参数配置                                   | 字段类型 | 默认值                 | 说明                                                         |
| :----------------------------------------- | :------- | :--------------------- | :----------------------------------------------------------- |
| global.objectStore.external                | bool     | false                  | false：使用内置 Minio<br/>true: 使用外部对象存储。           |
| global.objectStore.connection              | dict     | { }                    | 默认为空，外部对象存储未配置。                               |
| global.objectStore.connection.endpoint     | string   | http://minio.\<domain> | 连接外部对象存储的端点。                                     |
| global.objectStore.connection.accessKey    | string   | minio                  | 连接外部对象存储的 AccessKey。                               |
| global.objectStore.connection.accessSecret | string   | Null                   | 连接外部对象存储的 AccessSecret。                            |
| global.objectStore.connection.region       | string   | cn-north-1             | 外部对象存储的所在的区域。                                   |
| global.objectStore.connection.encrypt      | string   | false                  | 外部对象存储的端点是否加密。                                 |
| global.objectStore.connection.pathStyle    | string   | true                   | 外部对象存储存储桶的访问方式。                               |
| global.objectStore.connection.bucket       | string   | Null                   | 指定外部对象存储的存储桶。<br>如果值为空，则默认使用 csghub-portal, csghub-server, csghub-registry, csghub-workflow 存储桶。如果指定了存储桶，则所有对象都将存储到同一个存储桶中。<br>无论是哪种方式存储桶都需要自行创建。 |

## 其他配置

### global

#### image

| 参数配置          | 字段类型 | 默认值                  | 作用范围      | 说明                            |
| :---------------- | :------- | :---------------------- | :------------ | :------------------------------ |
| image.pullSecrets | list     | [ ]                     | 所有子 Chart  | 指定拉取私有镜像秘钥。          |
| image.registry    | string   | OpenCSG ACR             | 所有子 Chart  | 指定镜像仓库前缀。              |
| image.tag         | string   | 当前最新 release 版本号 | CSGHub Server | 指定 csghub_server 镜像的标签。 |

#### ingress

| 参数配置               | 字段类型 | 默认值       | 说明                                                         |
| :--------------------- | :------- | :----------- | :----------------------------------------------------------- |
| ingress.domain         | string   | example.com  | 指定服务外部域名。                                           |
| ingress.tls.enabled    | bool     | false        | 指定是否启用 ingress 加密访问。                              |
| ingress.tls.secretName | string   | Null         | 指定加密访问所使用的受信证书。                               |
| ingress.service.type   | string   | LoadBalancer | 指定 ingress-nginx 服务暴露方式。<br>这里使用了内部锚点`&type`，请勿删除。 |

#### deployment

| 参数配置                                      | 字段类型 | 默认值            | 说明                                                         |
| :-------------------------------------------- | :------- | :---------------- | :----------------------------------------------------------- |
| deployment.enabled                            | bool     | true              | 指定是否启用实例部署。<br/>如果禁用则无法创建 space、推理等实例（即不关联 K8S 集群）。 |
| deployment.kubeSecret                         | string   | kube-configs      | 指定包含所有目标集群 `.kube/config`的 Secret，需要自行创建。创建方式在部署部分已经提供。 |
| deployment.namespace                          | string   | spaces            | 部署实例所在的命名空间。                                     |
| deployment.knative.serving.autoConfigure      | bool     | true              | 指定是否开启自动部署 KnativeServing 和 argo。                |
| deployment.knative.serving.services[n].name   | string   | example-service-1 | 无实际意义，预配置参数。                                     |
| deployment.knative.serving.services[n].domain | string   | app.internal      | 执行默认配置到 KnativeServing 的域名。                       |
| deployment.knative.serving.services[n].host   | string   | 192.168.8.3       | 指定连接到目标 K8S 集群的 IP 地址。                          |
| deployment.knative.serving.services[n].port   | string   | 80                | 指定连接到 KnativeServing kourier 服务的端口。               |

### Local

***说明：** 组件较多，仅对部分组件参数做说明。其中`autoscaling`暂时未做适配。*

#### gitaly

| 参数配置             | 字段类型 | 默认值 | 说明                                 |
| :------------------- | :------- | :----- | :----------------------------------- |
| gitaly.logging.level | string   | info   | 指定日志输出级别。常用 info, debug。 |

#### minio

| 参数配置                 | 字段类型 | 默认值                                                       | 说明                   |
| :----------------------- | :------- | :----------------------------------------------------------- | :--------------------- |
| minio.buckets.versioning | bool     | true                                                         | 指定是否启用版本控制。 |
| minio.buckets.defaults   | list     | csghub-portal<br>csghub-server<br>csghub-registry<br>csghub-workflow | 默认创建的存储桶       |

#### postgresql

| 参数配置              | 字段类型 | 默认值                                                       | 说明                                                  |
| :-------------------- | :------- | :----------------------------------------------------------- | :---------------------------------------------------- |
| postgresql.parameters | map      | Null                                                         | 指定需要设置的数据库参数，sighup 和 postmaster 均可。 |
| postgresql.databases  | list     | csghub_portal<br>csghub_server<br>csghub_casdoor<br>csghub_temporal<br>csghub_temporal_visibility | 默认创建的数据库。                                    |

#### temporal

| 参数配置                         | 字段类型 | 默认值 | 说明                             |
| :------------------------------- | :------- | :----- | :------------------------------- |
| temporal.authentication.username | string   | Null   | 指定验证登录 Temporal 的用户名。 |
| temporal.authentication.password | string   | Null   | 指定验证登录 Temporal 的密码。   |

#### casdoor

| 参数配置               | 字段类型 | 默认值       | 说明                                 |
| :--------------------- | :------- | :----------- | :----------------------------------- |
| casdoor.smtp.enabled   | bool     | false        | 指定是否启用 SMTP。                  |
| casdoor.smtp.host      | string   | smtp.163.com | 指定 SMTP 服务地址。                 |
| casdoor.smtp.port      | number   | 463          | 指定 SMTP 服务端口。                 |
| casdoor.smtp.username  | string   | Null         | 指定验证 SMTP 服务的用户名。         |
| casdoor.smtp.password  | string   | Null         | 指定验证 SMTP 服务的密码。           |
| casdoor.smtp.emailFrom | string   | Null         | 指定发件人（通常和 username 一致）。 |
| casdoor.smtp.emailName | string   | OpenCSG      | 指定发送后的邮件名称。               |
| casdoor.smtp.secure    | bool     | true         | 指定是否启用 SSL/TLS 加密。          |

#### Others

其余参数请自行参考组件`values.yaml`文件。

### Dependencies

#### ingress-nginx

| 参数配置                                               | 字段类型 | 默认值                                       | 作用范围 | 说明                                                         |
| :----------------------------------------------------- | :------- | :------------------------------------------- | :------- | :----------------------------------------------------------- |
| ingress-nginx.enabled                                  | bool     | true                                         | /        | 指定是否启用内置 ingress-nginx-controller。                  |
| ingress-nginx.tcp                                      | map      | 22:csghub/csghub-gitlab-shell:22             | /        | 指定额外暴露的 TCP 端口，修改此配置需要同时修改 `gitlab-shell.internal.port。`此配置为关联配置。 |
| ingress-nginx.controller.image.*                       | map      | digest: ""                                   | /        | 保持默认即可。仅用作适配 `global.image.registry。`           |
| ingress-nginx.controller.admissionWebhooks.patch.image | map      | digest: ""                                   | /        | 保持默认即可。用作适配 `global.image.registry。`             |
| ingress-nginx.controller.config.annotations-risk-level | strings  | Critical                                     | /        | 保持默认即可。ingress-nginx 4.12 版本开始将 annotations 使用 snippets 定义为风险配置。 |
| ingress-nginx.controller.allowSnippetAnnotations       | bool     | true                                         | /        | 允许使用配置片段。                                           |
| ingress-nginx.controller.service.type                  | string   | 同 global.ingress.service.type               | /        | 指定 Ingress-nginx-controller 服务类型。                     |
| ingress-nginx.controller.service.nodePorts             | map      | http: 30080<br>https: 30442<br>tcp.22: 30022 | /        | 保持默认即可。指定对象端口默认对应暴露的 nodePort 端口号。此配置为关联配置。 |

#### fluentd

| 参数配置            | 字段类型 | 默认值                         | 作用范围 | 说明                     |
| :------------------ | :------- | :----------------------------- | :------- | :----------------------- |
| fluentd.enabled     | bool     | true                           | /        | 指定是否启用 fluentd。   |
| fluentd.fileConfigs | map      | 默认以 json 方式输出到控制台。 | /        | 指定日志收集的处理方式。 |

## 故障排查

### dial tcp: lookup casdoor.example.com on 10.43.0.10:53: no such host

此问题是由于集群无法解析域名，如果是公有域名请配置域名解析，如果是自定义域名请配置 CoreDNS 和 Hosts 解析。CoreDNS 解析配置方式如下：

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

### ssh: connect to host csghub.example.com port 22: Connection refused

此问题常由于 gitlab-shell job 执行失败导致，出现此问题请按照如下方式进行排查：

1. 查看

    ```shell
    $ kubectl get cm csghub-ingress-nginx-tcp -n csghub -o yaml
    apiVersion: v1
    data:
      "22": default/csghub-gitlab-shell:22
    ......
    ```

   确认 22 端口对应的服务名是否正确。

2. 如果不正确手动进行修改

    ```shell
    $ kubectl -n csghub edit configmap/csghub-ingress-nginx-tcp
    apiVersion: v1
    data:
      "22": csghub/csghub-gitlab-shell:22
    
    # 更新 ingress-nginx-controller
    $ kubectl rollout restart deploy csghub-ingress-nginx-controller -n csghub
    ```

### http: server gave HTTP response to HTTPS client

CSGHub 默认安装使用不安全的 registry（即上面提到的：`<domain or IPv4>:5000`），需要确保 Kubernetes 可以从这个 registry 拉取镜像。因此在 Kubernetes 的每个节点上需做如下配置：

1. 配置前请确认配置文件 `/etc/containerd/config.toml` 是否存在，若不存在，可以使用以下命令创建。

```shell
mkdir -p /etc/containerd/ && containerd config default >/etc/containerd/config.toml
```

2. 配置 config_path 

    - Containerd 1.x

        ```toml
        version = 2
        
        [plugins."io.containerd.grpc.v1.cri".registry]
             config_path = "/etc/containerd/certs.d"
        ```

    - Containerd 2.x

        ```toml
         version = 3
        
         [plugins."io.containerd.cri.v1.images".registry]
              config_path = "/etc/containerd/certs.d"
        ```

3. 配置 `hosts.toml`

    ```shell
    # 创建 Registry 配置目录
    mkdir /etc/containerd/certs.d/<domain or IPv4>:5000
    
    # 定义配置
    cat /etc/containerd/certs.d/<domain or IPv4>:5000/hosts.toml
    server = "http://<domain or IPv4>:5000"
    
    [host."http://<domain or IPv4>:5000"]
       capabilities = ["pull", "resolve", "push"]
       skip_verify = true
       plain-http = true
    EOF
    ```

4. 重启 `containerd` 服务

    ```shell
    systemctl restart containerd
    ```

## 问题反馈

如遇使用过程中遇到任何问题可以通过方式提交反馈：

-  [Feedback](https://github.com/OpenCSGs/csghub-installer/issues)