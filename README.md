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
4. For more details, please refer to [here](docker/README.md).

### Docker Compose

1. This method can be used for testing and development purposes, the production environment recommends using the helm chart deployment method.
2. As an enhanced deployment method of docker, the docker compose deployment method also needs to rely on k8s to experience the full functionality. The current deployment method does not include k8s deployment.
3. For more details, please refer to [here](docker-compose/README.md).

### Helm Chart

1. The Helm Chart method is suitable for scenarios with high stability and availability, such as production environments.
2. Helm Chart only supports `gitaly` as the git server backend,  `gitea` is not supported.
3. For more details, please refer to [here](helm-chart/README.md).


Learn more about CSGHub [here](https://github.com/OpenCSGs/CSGHub).
