# CSGHub Summary

> **Version History:**
>
> - Starting from v0.9.0, CSGHub will no longer provide support for Gitea as a git backend.
> - Starting from v1.1.0, Add Temporal component as an asynchronous/scheduled task executor.
> - Starting from v1.3.0, CSGHub removes gitea from the docker-compose/helm-chart installer.
>- Starting from v1.6.0, Space Builder is removed, its function is inherited by runner.
> 

### Introduction

CSGHub is an open source, trusted large model asset management platform that helps users govern assets (datasets, model files, codes, etc.) involved in the life cycle of LLM and its applications. Based on CSGHub, users can operate assets such as model files, data sets, and codes through web interfaces, Git command lines, or natural language chatbots, including uploading, downloading, storing, verifying, and distributing. At the same time, the platform provides microservice submodules and standardized APIs to facilitate users to integrate with their own systems.

CSGHub is committed to providing users with an asset management platform that is natively designed for large models and can be privately deployed and run offline. CSGHub provides a similar private Hugging Face function to manage LLM assets in a similar way to OpenStack Glance managing virtual machine images, Harbor managing container images, and Sonatype Nexus managing artifacts.

For an introduction to CSGHub, please refer to: https://github.com/OpenCSGs/csghub

### Deployment methods

This project mainly introduces various installation methods of CSGHub.

Currently, there are three main installation methods for CSGHub:

- [Docker Engine](docker/README.md) (Update paused, reconstruction in progress (current latest=v1.5.3))
- [Docker Compose](docker/compose/README.md)
- [Helm Chart](helm/README.md)

Each deployment method in the open source version can be used for a full functional experience, but the full functional experience requires CSGHub to be connected to a Kubernetes cluster. 

For more details, please refer to the deployment documentation for each method. For historical deployment methods, please refer to the `release-v1.x` branch.

## Component Introduction

The CSGHub project consists of multiple components, each of which has specific responsibilities, and together they form an efficient and scalable system architecture. The following is a brief introduction to each component:

- **csghub_portal**: Responsible for the management and display of the user interface, providing an intuitive interface for users to interact with the system.
- **csghub_server**: Provides the main service logic and API interface, and handles requests sent by the client.
- **csghub_user**: Manages user identity and authentication processes, ensures the security and privacy of user information, and supports user registration, login, and permission management.
- **csghub_proxy**: Responsible for forwarding requests related to deployment instances, such as forwarding space application operation requests to Knative Serving services.
- **csghub_accounting**: Billing system, responsible for the cost statistics generated during resource usage.
- **csghub_mirror**: Provides warehouse data synchronization services, responsible for synchronizing opencsg.com models and datasets to local.
- **csghub_runner**: Responsible for deploying and managing application instances in the Kubernetes cluster to ensure fast building and continuous delivery of applications.
- **csghub_aigateway**: AI Gateway is an intelligent middle layer that manages and optimizes access to AI services, unifying interfaces, routing requests, ensuring security, and controlling costs.
- **csghub_dataviewer**: Helps users to preview datasets more quickly on the page.
- **csghub_watcher**: Monitor all Secret and ConfigMap changes of CSGHub and update related dependent resources.
- **gitaly**: Used for Git storage backend, providing high-performance Git operations, and achieving fast and efficient code version control and management.
- **gitlab-shell**: Provides an interactive interface for Git over SSH for secure Git operations to ensure the security of data transmission.
- **nats**: Implements messaging and event-driven architecture between microservices, provides efficient asynchronous communication capabilities, and enhances the decoupling and response speed of the system.
- **minio**: Provides high-performance local object storage services.
- **postgresql**: Stores metadata of each component and provides efficient data query and update capabilities.
- **registry**: Provides container image repository services to facilitate storage, management, and distribution of container images.
- **redis**: Provides high-performance cache and data storage services.
- **casdoor**: Responsible for user identity authentication and authorization, and cooperates with **csghub_user** to complete user management.
- **coredns**: Used to resolve CSGHub's internal DNS requests, such as the internal domain name resolution used in Knative Serving.
- **temporal**: Asynchronous task management service, used to execute time-consuming tasks, such as resource synchronization tasks.
- **fluentd**: A flexible log collection and processing framework that aggregates and forwards application logs for real-time monitoring, analysis, and troubleshooting.