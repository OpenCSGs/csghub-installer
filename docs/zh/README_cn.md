# 安装 CSGHub

## 概述

CSGHub 是一个开源、可信的大模型资产管理平台，可帮助用户治理 LLM 及其应用生命周期中涉及到的资产（数据集、模型文件、代码等）。基于 CSGHub，用户可以通过 Web 界面、Git 命令行或者自然语言
 Chatbot 等方式，实现对模型文件、数据集、代码等资产的操作，包括上传、下载、存储、校验和分发；同时平台提供微服务子模块和标准化 API，便于用户与自有系统集成。

CSGHub 致力于为用户带来针对大模型原生设计的、可私有化部署离线运行的资产管理平台。CSGHub 提供类似私有化的 Hugging Face 功能，以类似 OpenStack Glance 管理虚拟机镜像、Harbor 管理容器镜>像以及 Sonatype Nexus 管理制品的方式，实现对 LLM 资产的管理。

> **提示:**
>
> - 从 v0.9.0 版本开始, CSGHub 将使用 [Gitaly](https://gitlab.com/gitlab-org/gitaly) 作为默认的 Git 服务，并且不在继续提供 Gitea 支持。
> - Docker 和 Helm Chart 部署方式的文档中提供了快速部署 k8s 服务的脚本，但仅用于测试.

当前项目介绍了部署 CSGHub 的多种方式, 主要有以下：

- Docker Engine/Docker Desktop
- Docker Compose
- Helm Chart

## 部署方式

### Docker Engine/Docker Desktop

1. Docker Engine 部署方式提供最简易部署（包含完整功能），目前处于测试阶段。
2. Docker 部署方式分为**快速部署**和**完整部署**两部分，快速部署不包含部分高级功能，例如 Space 应用托管、模型推理与微调等。
3. 完整功能体验需要 Kubernetes 集群支持部署，文档中已包含快速部署方式（仅供测试与功能体验）。
4. 快速启动：
```shell
export SERVER_DOMAIN=$(ip addr show $(ip route show default | awk '/default/ {print $5}') | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
export SERVER_PORT=80
docker run -it -d \
    --name omnibus-csghub \
    --hostname omnibus-csghub \
    -p ${SERVER_PORT}:80 \
    -p 2222:2222 \
    -p 8000:8000 \
    -p 9000:9000 \
    -v /srv/csghub/data:/var/opt \
    -v /srv/csghub/log:/var/log \
    -e CSGHUB_WITH_K8S=0 \
    -e SERVER_DOMAIN=${SERVER_DOMAIN} \
    -e SERVER_PORT=${SERVER_PORT} \
    opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest
```
5. 更多详细信息请参考[这里](README_cn_docker.md)。

### Docker Compose

1. 此方式仅用于测试开发用途，生产环境建议使用 Helm Chart 部署方式。
2. Docker Compose 部署方式作为 Docker 的增强部署方式，同样需要依赖 k8s 才能体验完整功能，目前的部署方式不包含 k8s 部署。
3. 快速启动：
```shell
curl -L -o csghub.tgz https://github.com/OpenCSGs/csghub-installer/releases/download/v1.3.0/csghub-docker-compose-v1.3.0.tgz
tar -zxf csghub.tgz && cd csghub

# 如果 `.env` 发生变化或者是第一次安装，那么必须执行`./configure`以渲染新的配置文件。
chmod +x configure && ./configure
```
4. 更多详细信息请参考[这里](README_cn_docker_compose.md)。

### Helm Chart

1. Helm Chart 部署方式适用于对稳定性和可用性要求较高的场景，例如生产环境。
2. Helm Chart 仅支持`gitaly`作为 git 服务器后端，不支持`gitea`。
3. 快速启动:
```shell
# 如果是第一次安装请参考步骤 4 完成前置条件配置
# 创建命名空间和 Secret
kubectl create ns csghub 
kubectl -n csghub create secret generic kube-configs --from-file=/root/.kube/

# 添加 CSGHub Helm 仓库
helm repo add csghub https://opencsgs.github.io/csghub-installer
helm repo update

# 安装 CSGHub
# 如果使用的是 ZSH，请替换 `internalDomain[0]`为`internalDomain\[0\]`
helm install csghub csghub/csghub \
  	--namespace csghub \
  	--create-namespace \
  	--set global.domain=example.com \
  	--set global.runner.internalDomain[0].domain=app.internal \
  	--set global.runner.internalDomain[0].host=172.25.11.130 \
  	--set global.runner.internalDomain[0].port=32497
```
4. 更多详细信息请参考[这里](README_cn_helm_chart.md)。


有关 CSGHub 的更多详细信息请参见[这里](https://github.com/OpenCSGs/CSGHub)。
