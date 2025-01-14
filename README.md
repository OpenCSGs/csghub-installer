# CSGHub Installer

## Overview

CSGHub is an open source, trusted large model asset management platform that helps users manage assets (datasets, model files, codes, etc.) involved in the life cycle of LLM and LLM applications. Based on CSGHub, users can operate assets such as model files, data sets, codes, etc. through the Web interface, Git command line, or natural language Chatbot, including uploading, downloading, storage, verification, and distribution; at the same time, the platform provides microservice submodules and standardized APIs to facilitate users to integrate with their own systems.

CSGHub is committed to bringing users an asset management platform that is natively designed for large models and can be privately deployed and run offline. CSGHub provides a similar private Hugging Face function to manage LLM assets in a similar way to OpenStack Glance managing virtual machine images, Harbor managing container images, and Sonatype Nexus managing artifacts.

> **Tips:**
>
> - Starting from v0.9.0, CSGHub will use [Gitaly](https://gitlab.com/gitlab-org/gitaly) as the default git service and will no longer provide Gitea support.
> - Docker Engine and Helm Chart deployment methods provide simple k8s deployment, but only for testing.
> - [中文文档](docs/zh/README_cn.md)

This project introduces various ways to deploy CSGHub, including:

- Docker Engine/Docker Desktop
- Docker Compose
- Helm Chart

## Deployment Methods

### Docker Engine/Docker Desktop

1. The Docker Engine deployment method provides the simplest deployment and already includes complete functions, but is currently in the testing phase.
2. Docker deployment methods are divided into two parts: **quick deployment** and **complete deployment**. Quick deployment does not include some advanced features. For example, Space application hosting, model inference and fine-tuning.
3. The full functional experience requires the deployment of Kubernetes cluster support. The document already includes the quick deployment method (for testing and functional experience only).
4. Quick start:
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
5. For more details, please refer to [here](docker/README.md).


### Docker Compose

1. This method can be used for testing and development purposes, the production environment recommends using the helm chart deployment method.
2. As an enhanced deployment method of docker, the docker compose deployment method also needs to rely on k8s to experience the full functionality. The current deployment method does not include k8s deployment.
3. Quick start:
```shell
curl -L -o csghub.tgz https://github.com/OpenCSGs/csghub-installer/releases/download/v1.3.0/csghub-docker-compose-v1.3.0.tgz
tar -zxf csghub.tgz && cd csghub

# If .env is update or first install, `./configure` must be executed.
chmod +x configure && ./configure
```
4. For more details, please refer to [here](docker-compose/README.md).

### Helm Chart

1. The Helm Chart method is suitable for scenarios with high stability and availability, such as production environments.
2. Helm Chart only supports `gitaly` as the git server backend,  `gitea` is not supported.
3. Quick start:
```shell
# If this is your first installation, please refer to step 4 to complete the prerequisite configuration
# create namespace kube-configs
kubectl create ns csghub 
kubectl -n csghub create secret generic kube-configs --from-file=/root/.kube/

# Add csghub helm repo
helm repo add csghub https://opencsgs.github.io/csghub-installer
helm repo update

# Install csghub
# If zsh, replace `internalDomain[0]` to `internalDomain\[0\]`.
helm install csghub csghub/csghub \
  	--namespace csghub \
  	--create-namespace \
  	--set global.domain=example.com \
  	--set global.runner.internalDomain[0].domain=app.internal \
  	--set global.runner.internalDomain[0].host=172.25.11.130 \
  	--set global.runner.internalDomain[0].port=32497
```
4. For more details, please refer to [here](helm-chart/README.md).


Learn more about CSGHub [here](https://github.com/OpenCSGs/CSGHub).
