## CSGHub installer
该项目提供部署 CSGHub 实例的安装脚本和配置文件，包括 Helm Chart和 Docker Compose 脚本，以简化各种环境中的部署过程。请参考[这里](https://github.com/OpenCSGs/csghub)了解更多关于CSGHub的详细信息

### 安装方式和适用场景

**选择最合适的部署方式:**

**【适合快速部署和试用】** 如果您希望快速启动CSGHub，在本机环境(Linux/MacOS/Windows)上一键运行CSGHub, 那么您可以跳转到[Docker](#docker) 章节来使用docker-all-one模式部署

**【生产可用级部署】** 如果您希望将CSGHub部署到生产环境，支持高可用并且能对接到GPU算力集群, 那么强烈推荐您使用[HelmChart](#helm-chart) 模式来部署

如果您对Docker-Compose非常熟悉并且想基于docker-compose来部署CSGHub, 那么您可以使用[DockerCompose](#docker-compose) 模式来部署

#### Docker 
1. Docker 部署方式主要是方便用户进行快速的功能验证和测试, 您将通过最简化的命令来启动一个all-in-one的容器, 并可以使用包括模型/数据集/用户的上传/下载等核心功能.
2. **【重要提示】** Docker并不适用于生产级部署(不支持系统高可用/部分配置硬编码在容器中). 如果您计划直接将CSGHub部署到生产环境, 我们强烈建议您使用HelmChart方式来部署CSGHub.
3. Docker一键部署模式目前没有内置Kubernetes集群, 因此依赖Kubernetes集群的功能(Space/Inference/Fine-Tune...)默认没有开启, 您需要手动导入外部Kubernetes集群来开启这些功能.
4. Docker部署方式的项目说明,请参见详细的文档[docker](https://github.com/OpenCSGs/csghub-installer/tree/main/docker/README.md)

#### Helm Chart
1. helm chart方式适用于对稳定性和可用性较高的场合，比如生产环境。
2. helm chart仅仅支持使用`gitaly`作为git server后端，不支持gitea。
3. helm chart安装部署方式详见[文档](https://github.com/OpenCSGs/csghub-installer/tree/main/helm-chart/README.md)

#### Docker Compose
1. compose方式部署的CSGhub实例可用于测试和试用，生产环境推荐使用helm chart方式安装。
2. compose方式部署的CSGHub实例不能直接使用依赖kubernetes平台的部分功能，比如应用空间，模型推理和模型微调。kubernetes平台部署和对接配置不在compose脚本功能范围之内，需要手动进行配置，具体配置对接方法可参见[配置对接Kubernetes](https://github.com/OpenCSGs/csghub-installer/blob/main/docker-compose/csghub/README.md#configure-kubernetes)
3. 从CSGHub v0.9.0版本开始，CSGHub不再对gitea后端提供持续支持，推荐使用gitaly后端进行安装。
4. 提供一键部署到阿里云的解决方案，[部署链接](https://computenest.console.aliyun.com/service/instance/create/cn-hangzhou?type=user&ServiceId=service-712413c5c35c47b3a42c)
5. compose安装部署方式详见[文档](https://github.com/OpenCSGs/csghub-installer/blob/main/docker-compose/csghub/README.md)
