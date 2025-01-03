# CSGHub Docker Compose 部署文档

## 概述

此脚本可实现一键部署 CSGHub 实例，实例包括所有相关组件：

- **csghub-server：** 提供主要的服务逻辑和 API 接口，处理客户端请求和服务交互。
- **csghub-portal：** 负责用户界面的管理和展示，让用户直接与系统交互。
- **csghub-user：** 管理用户身份认证及相关操作，确保用户安全和数据隐私。
- **nats：** 实现微服务间的消息和事件驱动架构，提供高效的异步通信能力。
- **csghub-proxy：** 用于请求转发和负载均衡，确保系统中不同服务间通信顺畅。
- **csghub-accounting：** 负责计量计费处理，监控交易并生成相关报告。
- **csghub-mirror-repo/csghub-mirror-lfs：** 提供仓库同步服务，保证仓库数据高效同步。
- **csghub-runner：** 负责将应用实例部署到 Kubernetes 集群。
- **csghub-space-builder：** 主要负责构建应用镜像，并上传到容器镜像仓库。
- **gitaly：** CSGHub 的 Git 存储后端，提供 Git 操作的高效实现。
- **gitlab-shell：** 提供 CSGHub 与 Gitaly 仓库之间的 Git over SSH 交互，用于 SSH 访问进行 Git 操作。
- **minio：** 为 csghub_server、csghub_portal、gitaly 提供对象存储服务，支持文件存储和访问。
- **postgresql：** 关系型数据库管理系统，负责存储和管理（csghub_server/csghub_portal/casdoor）结构化数据。
- **registry：** 提供容器镜像仓库，方便容器镜像的存储和分发。
- **redis：** 为 csghub_builder 和 csghub_mirror 提供高性能的缓存和数据存储服务，支持快速的数据读写。
- **casdoor：** 负责用户认证授权，提供单点登录（SSO）和多种认证方式。
- **coredns：** 用于处理和解析内部 DNS 解析。
- **temporal:** 异步任务管理服务，用于执行耗时较长任务，比如资源同步任务。
- **temporal-ui:** 异步任务管理界面，提供任务查看功能。
- **nginx：** 提供路由转发。

## 先决条件

* **硬件**
    * 最低配置: 4 CPU/8GB RAM/50GB Hard Disk
    * 建议配置: 8 CPU/16GB RAM/500GB Hard Disk


* **软件**
    - Linux/AMD64，Linux/ARM64 (适配中)
    - Docker Engine (>=5:20.10.24)

## 配置

1. 导航到 `docker-compose`.
2. 编辑文件 `.env` ，设置变量 `SERVER_DOMAIN` 为本机 IPv4 地址或者域名，不要使用 `127.0.0.1` 或 `localhost`。
3. 如果没有 Kubernetes 集群，`.env` 中的 space 和 registry 相关配置可以忽略。与现有 Kubernetes 集群集成的配置可以在[下文](#配置-kubernetes)中找到。
4. 执行 `startup.sh` 脚本。所有服务启动完成后，可以通过`http://[SERVER_DOMAIN]`访问自行部署的 CSGHub 服务，若`SERVER_PORT`默认不是 80，请通过`http://[SERVER_DOMAIN]:[SERVER_PORT]`进行访问。
5. 实例启动后，通过使用默认管理员帐户`root/Root@1234`进行登录。
6. 其他所有服务的用户和密码均可以在 `.env` 文件中找到.

*注意: 无论何时，请使用 `startup.sh` 渲染应用更新后的配置。*

### 注意

1. 自部署的 CSGHub 使用本地类型的 Docker 卷进行持久化，例如 PostgreSQL、Minio 等，请确保 Docker 本地卷有足够的磁盘空间。
2. 确定以下端口可以向外暴露 (默认):
    - 2222: Git Over SSH
    - 5000: Registry
    - 8000: Casdoor
    - 9000: Minio API
    - 9001: Minio Console
3. CSGHub 服务默认只支持 HTTP 协议，如果需要 HTTPS 请进行相应配置。
4. 使用以下命令彻底删除 CSGHub 实例：
```
docker compose -f docker-compose.yml down -v
```

## 配置 Kubernetes

### 先决条件

- Kubernetes 版本 > 1.20+.
- 最低服务器配置 8c16g。
- Kubernetes 支持多种部署方式，例如 Docker Desktop、[K3s](https://docs.k3s.io/quick-start)、[Kubeadm ](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)等。
- 使用 Docker Compose 安装脚本运行 CSGHub 实例。

### 配置 Knative

有关 Knative 配置，请参阅 [Knative 安装](https://opencsg.com/docs/csghub/101/helm/installation)。

### 配置 CSGHub

重新配置 CSGHub 实例以连接到指定的 Kubernetes 集群。

示例如下：

- CSGHub IP：`110.95.70.140`
- Kubernetes 主节点: `101.201.52.76`
- Kubernetes 工作节点: `59.10.62.160 `
- 使用`NodePort` 暴露 Knative 服务，假设端口为`30541`。

更多详细信息，请参阅 [Knative config](https://opencsg.com/docs/csghub/101/helm/installation#%E5%AE%89%E8%A3%85%E7%BD%91%E7%BB%9C%E7%BB%84%E4%BB%B6)。

### 重新配置 CSGHub 实例

根据以上信息，首先将`.env`文件内容修改如下：
```
## External URL
## Default it should be your server ipv4 address or domain.
SERVER_DOMAIN="110.95.70.140"
SERVER_PORT=80

SPACE_APP_NAMESPACE="space"
## Define knative serving internal domain.
## It is knative network layer endpoint.
## it can be an internal lb or ip which will not be exposed to external
SPACE_APP_INTERNAL_DOMAIN="app.internal"
## Define kourier network plugin service ip and port.
SPACE_APP_INTERNAL_HOST="59.10.62.160"
## If ServiceType is LoadBalancer SPACE_APP_INTERNAL_PORT should be 80 or 443
SPACE_APP_INTERNAL_PORT="30541"

## If using Space/Finetune/Inference/Model Evaluation/Dataflow functions and so on.
KUBE_CONFIG_DIR="/root/.kube"
```

然后使用如下命令重新配置 CSGHub 实例:

```
./startup.sh
```

### 继续配置 Kubernetes

- 为 Kubernetes 配置不安全的 Docker 镜像仓库

    CSGHub 默认安装使用不安全的 registry（即上面提到的：`110.95.70.140:5000`），需要确保 Kubernetes 可以从这个 registry 拉取镜像。在 Kubernetes 的每个 worker 节点上执行以下操作：

    配置前请确认配置文件 `/etc/containerd/config.toml` 是否存在，若不存在，可以使用以下命令创建。

    ```shell
    mkdir -p /etc/containerd/ && containerd config default >/etc/containerd/config.toml
    ```

1. 配置 config_path 

   - Containerd 2.x

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

2. 重启 `containerd` 服务

    ```shell
    systemctl restart containerd
    ```

3. 配置 hosts.toml

    ```shell
    mkdir /etc/containerd/certs.d/110.95.70.140:5000
    
    cat <<EOF > /etc/containerd/certs.d/110.95.70.140:5000/hosts.toml
    server = "http://110.95.70.140:5000"
    
    [host."http://110.95.70.140:5000"]
            capabilities = ["pull", "resolve", "push"]
            skip_verify = true
    EOF
    ```

​	*注意：此配置无需重启效。* 

