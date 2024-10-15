## CSGHub installer
该项目提供部署 CSGHub 实例的安装脚本和配置文件，包括 Helm Chart和 Docker Compose 脚本，以简化各种环境中的部署过程。请参考[这里](https://github.com/OpenCSGs/csghub)了解更多关于CSGHub的详细信息

### 安装方式和适用场景
#### Docker Compose
1. compose方式部署的CSGhub实例可用于测试和试用，生产环境推荐使用helm chart方式安装。
1. compose方式部署的CSGHub实例不能直接使用依赖kubernetes平台的部分功能，比如应用空间，模型推理和模型微调。kubernetes平台部署和对接配置不在compose脚本功能范围之内，需要手动进行配置，具体配置对接方法可参见[配置对接Kubernetes](./docker-compose/csghub/README.md#configure-kubernetes)
1. 从CSGHub v0.9.0版本开始，CSGHub不再对gitea后端提供持续支持，推荐使用gitaly后端进行安装。
1. compose安装部署方式详见[文档](./docker-compose/csghub/README.md)

#### Helm Chart
1. helm chart方式适用于对稳定性和可用性较高的场合，比如生产环境。
1. helm chart仅仅支持使用`gitaly`作为git server后端，不支持gitea。
1. helm chart安装部署方式详见[文档](./csghub-installer/README.md)
