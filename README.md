## CSGHUB Helm Chart

CSGHub is an open source, trustworthy large model asset management platform that can assist users in governing the assets involved in the lifecycle of LLM and LLM applications (datasets, model files, codes, etc).

### Helm Usage Instructions

Due to the version problem, the configuration is relatively complicated, which will be optimized in later versions. To simplify the configuration, only global parameters are defined in values.yaml. The mapping method of sub-charts in global in this helm chart is consistent with directly modifying the sub-chart configuration in the parent chart. Therefore, when modifying a subchart, you only need to add or modify the parameters of the corresponding subchart in global.

#### Configuration

Currently, the following configurations are required:

1. Domain
   1. csghub main: `csghub.example.com`
   2. minio console: `minio.example.com`
   3. registry: `registry.example.com`
   4. public application: `public.example.com`
2. TLS certificate for all domains (if tls enabled for each component)
3. Persistent Storage
   1. postgresql
   2. redis
   3. registry
   4. gitea
   5. builder
4. Ingress access method, LoadBalancer or NodePort
5. `.kube/config` (it is necessary at this stage. configured with `.Values.global.runner.kubeConfig`)

#### Installation

```shell
helm install csghub .
```