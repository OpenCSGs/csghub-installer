## CSGHUB Helm Chart

CSGHub is an open source, trustworthy large model asset management platform that can assist users in governing the assets involved in the lifecycle of LLM and LLM applications (datasets, model files, codes, etc).

### Helm Usage Instructions

Due to the version problem, the configuration is relatively complicated, which will be optimized in later versions. To simplify the configuration, only global parameters are defined in values.yaml. The mapping method of sub-charts in global in this helm chart is consistent with directly modifying the sub-chart configuration in the parent chart. Therefore, when modifying a subchart, you only need to add or modify the parameters of the corresponding subchart in global.

#### PreCondition

1. [KNative Serving](https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/) should be installed.
2. With it's configMap internal domain should be patched.
```shell
kubectl patch configmap/config-domain \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"app.internal":""}}'
```

#### Configuration

Currently, the following configurations are required:

1. Domain `.Values.global.ingress.external.domain`<br>
   it will auto-generate domain for csghub-main/minio/registry/space.<br>
   
   for example:
   if `.Values.global.ingress.external.domain` set to `example.com`
   1. csghub main: `csghub.example.com`
   2. minio console: `minio.example.com`
   3. registry: `registry.example.com`
   4. space: `public.example.com`
   
   So, before installation, you should add DNS record to DNS server or `/etc/hosts`.


2. TLS certificate for all domains (if tls enabled for components)<br>
   Each component use single secret, you can config `.Values.global.*.ingress.tls.secretName` to deploy.<br>
   It is especially important to note here that if you use the built-in registry, try to use trusted TLS access, otherwise you may need to modify the settings of your k8s cluster runtime.


3. Ingress access method. <br>
   If it is a local deployment, please use NodePort. If it is a cloud deployment, please use LoadBalancer.Ingress access method. If it is a local deployment, please use NodePort.<br> Currently, due to certain features, when using NodePort, you need to set the NodePort port in advance.
   The internal template will determine whether https is enabled based on the port, for example 80 ==> http, 443 ==> https.


4. `.kube/config` <br>
   (it is necessary at this stage. configured with `.Values.global.runner.kubeConfig`). The current deployment method directly references `kubeConfig`. Although this may not be very reasonable, it is the only way to make the function work properly at present. We may make adjustments later.


5. Persistent Storage <br>
   Following components using persistent storage, your k8s cluster should support automatic management of persistent volumes. 
   1. Databases: postgresql、redis
   2. Container Registry: registry
   3. Git: gitea
   4. space builder: builder
   
   
#### Installation

```shell
helm install csghub . -n csghub
```