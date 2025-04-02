# CSGHub介绍

> **版本历史：**
>
> - 从 v0.9.0 版本开始，CSGHub 将不再继续提供 Gitea 作为 git 后端的支持。
> - 从 v1.1.0 版本开始，添加 Temporal 组件，作为异步 / 计划任务执行器。
> - 从 v1.3.0 版本开始，CSGHub 将 gitea 从 docker-compose/helm-chart 安装程序中移除。
>
> **说明：**
>
> - [多语言文档](../../docs/)

### 介绍

CSGHub 是一个开源、可信的大模型资产管理平台，可帮助用户治理 LLM 及其应用生命周期中涉及到的资产（数据集、模型文件、代码等）。基于 CSGHub，用户可以通过 Web 界面、Git 命令行或者自然语言 Chatbot 等方式，实现对模型文件、数据集、代码等资产的操作，包括上传、下载、存储、校验和分发；同时平台提供微服务子模块和标准化 API，便于用户与自有系统集成。

CSGHub 致力于为用户带来针对大模型原生设计的、可私有化部署离线运行的资产管理平台。CSGHub 提供类似私有化的 Hugging Face 功能，以类似 OpenStack Glance 管理虚拟机镜像、Harbor 管理容器镜>像以及 Sonatype Nexus 管理制品的方式，实现对 LLM 资产的管理。

关于 CSGHub 的介绍，请参考：https://github.com/OpenCSGs/csghub

### 部署方式

本项目主要介绍 CSGHub 的多种安装方式。

目前 CSGHub 安装主要包括三种安装方式：

- [Docker Engine](./install_csghub_by_docker_cn.md)（用于测试目的）
- [Docker Compose](./install_csghub_by_docker_compose_cn.md)
- [Helm Chart](./install_csghub_by_helm_cn.md)

开源版本中每种部署方式都可以进行完整功能的体验，但是完整功能的体验需要 CSGHub 对接到 Kubernetes 集群。

更多详细请参考各方式部署文档。历史部署方式请参考 release-v1.x 分支。

## 组件介绍

CSGHub 项目由多个组件组成，每个组件都承担着特定的职责，共同构成一个高效、可扩展的系统架构。以下是各个组件的简要介绍：

- **csghub_portal**: 负责用户界面的管理和展示，提供直观的界面供用户与系统交互。
- **csghub_server**: 提供主要的服务逻辑和 API 接口，处理客户端发送的请求。
- **csghub_user**: 管理用户身份和认证流程，确保用户信息的安全性和隐私保护，支持用户注册、登录及权限管理。
- **csghub_proxy**: 负责部署实例相关的请求转发，例如 space 应用的操作请求转发到 Knative Serving 服务。
- **csghub_accounting**: 计费系统，负责资源使用过程中产生的费用统计。
- **csghub_mirror**: 提供仓库数据的同步服务，负责同步 opencsg.com 模型和数据集到本地。
- **csghub_runner**: 负责在 Kubernetes 集群中部署和管理应用实例，确保应用的快速构建和持续交付。
- **space_builder**: 负责构建应用镜像并上传到容器镜像仓库，简化应用的打包和发布流程。
- **csghub_watcher**: 监控 CSGHub  所有 Secret 和 ConfigMap 变动，并更新相关依赖资源。
- **gitaly**: 用于 Git 存储后端，提供高性能的 Git 操作，实现快速、高效的代码版本控制和管理。
- **gitlab-shell**: 提供 Git over SSH 的交互接口，用于安全的 Git 操作，确保数据传输的安全性。
- **nats**: 实现微服务之间的消息传递和事件驱动架构，提供高效的异步通信能力，增强系统的解耦性和响应速度。
- **minio**: 提供高性能的本地对象存储服务。
- **postgresql**: 存储各组件元数据，提供高效的数据查询和更新能力。
- **registry**: 提供容器镜像仓库服务，便于存储、管理和分发容器镜像。
- **redis**: 提供高性能的缓存和数据存储服务。
- **casdoor**: 负责用户身份的验证和授权，配合 **csghub_user** 完成用户管理。
- **coredns**: 用于解析 CSGHub 的内部 DNS 请求，例如 Knative Serving 中使用的内部域名解析。
- **Temporal**: 异步任务管理服务，用于执行耗时较长任务，比如资源同步任务。
- **fluentd**: 灵活的日志收集和处理框架，聚合和转发各应用程序日志，便于实时监控、分析和故障排除。