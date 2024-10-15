## CSGHub installer

[简体中文](./docs/cn/csghub_installer.md)

This project provides installation scripts and configuration files for deploying CSGHub instances, including Helm Chart and Docker Compose scripts, to simplify the deployment process in various environments. 

Please go to [here](https://github.com/OpenCSGs/csghub) for more details information about CSGHub.

### Installation methods 
#### Docker Compose
1. compose mode can be used for test and develop purpose. It is recommended to use helm chart installation for production environments.
1. CSGHub instance that deployed with compose mode cannot directly use functions which rely on the kubernetes platform, such as space, model inference, and model fine-tuning. Kubernetes's deployment and configuration are not within the scope of the compose installation method, it needs further manual configurations which can be found [here](./docker-compose/csghub/README.md#configure-kubernetes)
1. Starting from CSGHub v0.9.0, CSGHub no longer provides continuous support for gitea backend, and it is recommended to use `gitaly` as default git server backend.
1. For more details about compose installation and deployment, please refer to [Document](./docker-compose/csghub/README.md)

#### Helm Chart
1. The helm chart method is suitable for scenarios with high stability and availability, such as production environments.
1. helm chart only supports `gitaly` as the git server backend,  `gitea` is not supported.
1. For more details about helm chart installation and deployment, please refer to [Document](./csghub-installer/README.md)
