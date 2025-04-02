# CHANGELOG

## v1.5.2(Planning)

---

- [Helm] Add new global.deployment.mergingNamespace to reduce namespace created.
- [Helm] Refactor global.deployment.knative.serving.autoConfigure to global.deployment.autoConfigure.

## v1.5.1

---

- [All] Rename csghub_builder to space_builder
- [All] Optimize lfs upload on machines with poor performance

## v1.5.0

---

- [All] Added support for new inference engines `TEI`, `lama.cpp`
- [All] Support gitaly cluster
- [Helm] Allow user define csghub_server image `name(repository)`, `pullPolicy` globally
- [Helm] Add new param `global.ingress.useTop` allow users to use the specified `domain` as the portal domain

## v1.4.2

---

- [Helm] Optimize password length
- [Helm] Fixed the adaptation error when using external resources
  - Now support (postgres, redis, registry, object storage, gitaly)
- [Compose] Fixed large lfs files cannot be uploads.

## v1.4.1

---

- [All] Rollback configuration user email login through unified configuration
- [Helm] Disabled tag resolving for knative serving for insecure registry by default
- [Compose] Fixed permission issues when mapping volumes
- [Compose] Allow users to turn off multi-source synchronization through simple configuration
- [Compose] Allow users define data location
- [Helm] Allow using external ingress-nginx
- [Helm] Optimize the gitlab shell host key pair generation method
- [Helm] Optimize automatic labeling behavior under automatic configuration for GPU resources

## v1.4.0

---

- [Helm] Add knative serving and argo automatic configuration
- [Helm] Optimize the number of ingresses
- [All] Add dataset preview component dataviewer
- [Docker] Add docker quick configuration script quick_install.sh
- [Docker] k8s integration is disabled by default 
