# CSGHub Helm Chart deployment document

## Introduction

The CSGHUB project uses Helm Chart as the main way to deploy Kubernetes to achieve efficient and repeatable application management.

The Helm Chart design of CSGHub tries to follow the principle of backward compatibility. Usually, you only need to execute the `helm upgrade` command to seamlessly deploy the new version, which simplifies the update process and reduces risks. In addition, as the architecture evolves, we regularly refactor the Helm Chart to improve flexibility and performance, make it clearer and easier to use, and facilitate developers to customize configuration.

In this way, CSGHUB achieves flexible deployment management and can respond to user needs more quickly.

## Software/Hardware Support

Hardware environment requirements:

- \>= 8c16g

- amd64/arm64

Software environment requirements:

- Kubernetes 1.20+

- Helm 3.12.0+

***Note:** Kubernetes needs to support Dynamic Volume Provisioning.*

## Deployment example

### Quick deployment (for testing purposes)

Currently, the deployment supports quick deployment, which is mainly used for testing. The deployment method is as follows:

```shell
# {{ domain }}: like example.com
# NodePort is the default ingress-nginx-controller service type
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm/quick_install.sh | bash -s -- example.com

## Tip: When using the LoadBalancer service type for installation, please change the server sshd service port to a non-port 22 in advance. This type will automatically occupy port 22 as the git ssh service port.
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm/quick_install.sh | INGRESS_SERVICE_TYPE=LoadBalancer bash -s -- example.com

# Enable Nvidia GPU
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm/quick_install.sh | ENABLE_NVIDIA_GPU=true bash -s -- example.com
```

The above deployment will automatically install/configure the following resources:

- K3S Single Node Cluster
- Helm Tools
- CSGHub Helm Chart
- CoreDNS/Hosts
- Insecure Private Container Registry

***Note:** After the deployment is complete, access and log in to CSGHub according to the terminal `prompt information` or `login.txt`.*

**Variable description:**

|        Variable         | Default value | Function                                                     |
| :---------------------: | :-----------: | :----------------------------------------------------------- |
|       ENABLE_K3S        |     true      | Create a K3S cluster                                         |
|    ENABLE_DYNAMIC_PV    |     false     | Simulate dynamic volume management                           |
|    ENABLE_NVIDIA_GPU    |     false     | Install nvidia-device-plugin                                 |
|       HOSTS_ALIAS       |     true      | Configure coredns and local hosts resolution                 |
|      INSTALL_HELM       |     true      | Install helm tool                                            |
|  INGRESS_SERVICE_TYPE   |   NodePort    | CSGHub service exposure method. If it is LoadBalancer mode, please make sure that the SSHD service uses a non-22 port |
| KNATIVE_INTERNAL_DOMAIN | app.internal  | KnativeServing domain name                                   |
|  KNATIVE_INTERNAL_HOST  |   127.0.0.1   | Kourier service address, which will be reassigned to the local IPv4 when the script is running |
|  KNATIVE_INTERNAL_PORT  |      80       | Kourier service port, if INGRESS_SERVICE_TYPE is NodePort, the port will be reassigned to 30213 |

### Standard deployment

#### Prerequisites

- Kubernetes 1.20+

- Helm 3.12.0+

- Dynamic Volume Provisioning

    Or manually create the following persistent volumes:

    - PV 500Gi * 1 (for Minio)

    - PV 200Gi * 1 (for Gitaly)

    - PV 50Gi * 2 (for PostgreSQL, Builder)

    - PV 10Gi * 2 (for Redis, Nats)

    - PV 1Gi * 1 (for Gitlab-Shell)

#### Start installation

- **Add helm repository**

    ```shell
    helm repo add csghub https://opencsgs.github.io/csghub-installer
    helm repo update
    ```

- **Create kube-configs Secret**

    ```shell
    kubectl create ns csghub
    kubectl -n csghub create secret generic kube-configs --from-file=/root/.kube/
    ```

- **Install CSGHub Helm Chart**

    ***Note:** The following is a simple installation, please refer to the following for more parameter definitions.*

    **Sample installation information:**

    |                      Parameters                      | Default value | Description                                                  |
    | :--------------------------------------------------: | :-----------: | :----------------------------------------------------------- |
    |                global.ingress.domain                 |  example.com  | [Service domain name](#domain name)                          |
    |             global.ingress.service.type              | LoadBalancer  | Please ensure that the cluster service provider has the ability to provide LoadBalancer services. <br/>The services using LoadBalancer here are Ingress-nginx-controller Service and Kourier. |
    |        ingress-nginx.controller.service.type         | LoadBalancer  | If you untar the installer and install it locally, this parameter can be omitted and automatically copied by the internal anchor. |
    |  global.deployment.knative.serving.services[0].type  |   NodePort    | Specifies the service type for the KnativeServing Kourier when using [deployment.knative.serving.autoConfigure](#deployment). If the cluster does not support multiple LoadBalancer addresses, use NodePort. |
    | global.deployment.knative.serving.services[0].domain | app.internal  | Specify the internal domain name used by KnativeServing.     |
    |  global.deployment.knative.serving.services[0].host  | 192.168.18.3  | Specify the IPv4 address of the KnativeServing Kourier service. |
    |  global.deployment.knative.serving.services[0].port  |     30213     | Specify the port of the KnativeServing Kourier service. If the type is LoadBalancer, it needs to be configured to 80. If the type is NodePort, it needs to be configured to any 5 valid NodePort port numbers. |
    |             global.deployment.kubeSecret             | kube-configs  | Contains the Secret of all target Kubernetes clusters .kube/config. Multiple configs can be renamed to files starting with config to distinguish them. |

    - **LoadBalancer** 

        ```shell 
        helm upgrade --install csghub csghub/csghub \ 
          --namespace csghub \ 
          --create-namespace \ 
          --set global.ingress.domain="example.com" \ 
          --set global.deployment.knative.serving.services[0].type="NodePort" \ 
          --set global.deployment.knative.serving.services[0].domain="app.internal" \ 
          --set global.deployment.knative.serving.services[0].host="192.168.18.3" \ 
          --set global.deployment.knative.serving.services[0].port="30213" 
        ```

    - **NodePort** 

        ```shell 
        helm upgrade --install csghub csghub/csghub \ 
          --namespace csghub \ 
          --create-namespace \ 
          --set global.ingress.domain="example.com" \ 
          --set global.ingress.service.type="NodePort" \
          --set ingress-nginx.controller.service.type="NodePort" \
          --set global.deployment.knative.serving.services[0].type="NodePort" \ 
          --set global.deployment.knative.serving.services[0].domain="app.internal" \
          --set global.deployment.knative.serving.services[0].host="192.168.18.3" \
          --set global.deployment.knative.serving.services[0].port="30213"
        ```

    ***Note:** Installation and configuration will take some time, please be patient. After the CSGHub Helm Chart configuration is completed, Argo Workflow and KnativeServing will be automatically configured in the target cluster.*

- **ACCESS INFORMATION** 

    Take the `NodePort` installation method as an example: 

    ```shell 
    You have successfully installed CSGHub!
    
    Visit CSGHub at the following address:
    
        Address: http://csghub.example.com:30080
        Credentials: root/xxxxx
    
    Visit the Casdoor administrator console at the following address:
    
        Address: http://casdoor.example.com:30080
        Credentials: admin/xxx
    
    Visit the Temporal console at the following address:
    
        Address: http://temporal.example.com:30080
        Credentials:
            Username: $(kubectl get secret --namespace csghub csghub-temporal -o jsonpath="{.data.TEMPORAL_USERNAME}" | base64 -d)
            Password: $(kubectl get secret --namespace csghub csghub-temporal -o jsonpath="{.data.TEMPORAL_PASSWORD}" | base64 -d)
    
    Visit the Minio console at the following address:
    
        Address: http://minio.example.com:30080/console/
        Credentials:
            Username: $(kubectl get secret --namespace csghub csghub-minio -o jsonpath="{.data.MINIO_ROOT_USER}" | base64 -d)
            Password: $(kubectl get secret --namespace csghub csghub-minio -o jsonpath="{.data.MINIO_ROOT_PASSWORD}" | base64 -d)
    
    To access Registry using docker-cli:
    
        Endpoint: registry.example.com:30080
        Credentials:
            Username=$(kubectl get secret csghub-registry -ojsonpath='{.data.REGISTRY_USERNAME}' | base64 -d)
            Password=$(kubectl get secret csghub-registry -ojsonpath='{.data.REGISTRY_PASSWORD}' | base64 -d)
    
        Login to the registry:
            echo "$Password" | docker login registry.example.com:30080 --username $Username ---password-stdin
    
        Pull/Push images:
            docker pull registry.example.com:30080/test:latest
            docker push registry.example.com:30080/test:latest
    
    *Notes: This is not a container registry suitable for production environments.*
    
    For more details, visit:
    
        https://github.com/OpenCSGs/csghub-installer
    ```

## Version description

CSGHub `major.minor` version is consistent with CSGHub Server, `Patch` version is updated as needed.

| Chart version | Csghub version | Description |
| :--------: | :---------: | ----------------------------- |
| 0.8.x | 0.8.x | |
| 0.9.x | 0.9.x | Add components Gitaly, Gitlab-Shell |
| 1.0.x | 1.0.x | |
| 1.1.x | 1.1.x | Add component Temporal |
| 1.2.x | 1.2.x | |
| 1.3.x | 1.3.x | Remove component Gitea |
| 1.4.x | 1.4.x | Add component Dataviewer |

## Domain name

CSGHub Helm Chart deployment requires a domain name because Ingress does not currently support routing forwarding using IP addresses.

The domain name can be a public domain name or a custom domain name, the difference is as follows:

**Public domain name:** You can use Cloud Resolution directly, which is easy to configure.

**Custom domain name:** You need to configure the address resolution yourself, mainly including the CoreDNS resolution of the Kubernetes cluster and the hosts resolution of the client host.

The following are examples of how to use the domain name:

If you specify the domain name `example.com` during installation, the CSGHub Helm Chart will use this domain name as the parent domain name and create the following subdomains:

- **csghub.example.com**: Access entry for the csghub main service.

- **casdoor.example.com**: Used to access the casdoor unified login system.

- **minio.example.com**: Used to access object storage.

- **registry.example.com**: Used to access the container image repository.

- **temporal.example.com**: Used to access the scheduled task system.

***Note:** No matter which domain name you use, make sure that the domain name resolution is configured correctly.*

## .kube/config

The `.kube/config` file is an important configuration file for accessing the Kubernetes cluster. It needs to be provided to the CSGHub Helm Chart as a Secret during the CSGHub Helm Chart deployment process. Due to the support of CSGHub's cross-cluster features, the service account (serviceAccount) cannot meet the operation requirements of CSGHub. This `.kube/config` must at least contain full read and write permissions to the namespace where the target cluster deployment instance is located. If the automatic configuration of argo and KnativeServing is enabled, more permissions such as creating a namespace are required.

## Persistent Volume

There are multiple components in the CSGHub Helm Chart that need to persist data. The components are as follows:

- **PostgreSQL**

The default is 50Gi, which is used to store database data files.

- **Redis**

The default is 10Gi, which is used to store Redis AOF dump files.

- **Minio**

Default is 500Gi, used to store avatar images, LFS files, and Docker Image files.

- **Gitaly**

Default is 200Gi, used to store Git repository data.

- **Builder**

Default is 50Gi, used to store temporarily built images.

- **Nats**

Default is 10Gi, used to store message flow related data.

- **GitLab-Shell**

Default is 1Gi, used to store host key pairs.

In the actual deployment process, you need to adjust the size of PVC according to usage, or directly use an expandable StorageClass.

It should be noted that CSGHub Helm Chart does not actively create related Persistent Volumes, but automatically applies for PV resources by creating Persistent Volume Claims, so your Kubernetes cluster needs to support Dynamic Volume Provisioning. If it is a self-deployed cluster, dynamic management can be achieved through simulation. For details, please refer to: [kubernetes-sigs/sig-storage-local-static-provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner).

## External resources 

> **Tip:** If the built-in service is not disabled while using an external service, the service will still start normally.

### Registry

| Parameter Configuration | Field Type | Default Value | Description |
| :------------------------------------ | :------- | :----- | :---------------------------------------------------- |
| global.registry.external | bool | false | false: Use the built-in Registry<br/>true: Use the external Registry. |
| global.registry.connection | dict | { } | Default is empty, external storage is not configured. |
| global.registry.connection.repository | string | Null | Connect to external Registry repository endpoint. |
| global.registry.connection.namespace | string | Null | Connect to external Registry namespace. |
| global.registry.connection.username | string | Null | Connect to external Registry username. |
| global.registry.connection.password | string | Null | Connect to external Registry password. |

### PostgreSQL

| Parameter Configuration | Field Type | Default Value | Description |
| :------------------------------------ | :------- | :------ | :----------------------------------------------------------- |
| global.postgresql.external | bool | false | false: Use built-in PostgreSQL<br/>true: Use external PostgreSQL. |
| global.postgresql.connection | dict | { } | Default is empty, external database is not configured. |
| global.postgresql.connection.host | string | Null | The IP address of the external database. |
| global.postgresql.connection.port | string | Null | The port number of the external database. |
| global.postgresql.connection.database | string | Null | The database name of the external database. <br/>If the value is empty, the database name of csghub_portal, csghub_server, csghub_casdoor, csghub_temporal, csghub_temporal_visibility is used by default. If the database name is specified, the contents of all the above databases will be stored in the same database (this method is not recommended and may cause data table conflicts). <br/>In either case, the database needs to be created by yourself. |
| global.postgresql.connection.user | string | Null | The user to connect to the external database. |
| global.postgresql.connection.password | string | Null | The password to connect to the external database. |
| global.postgresql.connection.timezone | string | Etc/UTC | Please use `Etc/UTC`. Currently only used for pre-configuration, no practical significance. |

### Redis

| Parameter Configuration | Field Type | Default Value | Description |
| :------------------------------- | :------- | :----- | :----------------------------------------------- |
| global.redis.external | bool | false | false: Use built-in Redis<br/>true: Use external Redis. |
| global.redis.connection | dict | { } | Default is empty, external Redis is not configured. |
| global.redis.connection.host | string | Null | The IP address of the external Redis. |
| global.redis.connection.port | string | Null | The port of the external Redis. |
| global.redis.connection.password | string | Null | Password for connecting to external Redis. |

### ObjectStore

| Parameter Configuration | Field Type | Default Value | Description |
| :----------------------------------------- | :------- | :--------------------- | :----------------------------------------------------------- |
| global.objectStore.external | bool | false | false: Use built-in Minio<br/>true: Use external object storage. |
| global.objectStore.connection | dict | { } | Default is empty, external object storage is not configured. |
| global.objectStore.connection.endpoint | string | http://minio.\{{ domain }} | Endpoint for connecting to external object storage. |
| global.objectStore.connection.accessKey | string | minio | AccessKey for connecting to external object storage. |
| global.objectStore.connection.accessSecret | string | Null | AccessSecret for connecting to external object storage. |
| global.objectStore.connection.region | string | cn-north-1 | The region where the external object store is located. |
| global.objectStore.connection.encrypt | string | false | Whether the endpoint of the external object store is encrypted. |
| global.objectStore.connection.pathStyle | string | true | The access method of the external object store bucket. |
| global.objectStore.connection.bucket | string | Null | Specify the bucket of the external object store. <br/>If the value is empty, the csghub-portal, csghub-server, csghub-registry, csghub-workflow bucket is used by default. If a bucket is specified, all objects will be stored in the same bucket. <br/>No matter which method is used, the bucket needs to be created by yourself. |

## Other configurations

### global

#### image

| Parameter configuration | Field type | Default value | Scope | Description |
| :---------------- | :------- | :---------------------- | :------------ | :------------------------------ |
| image.pullSecrets | list | [ ] | All sub-charts | Specify the private image secret key to be pulled. |
| image.registry | string | OpenCSG ACR | All sub-charts | Specify the image repository prefix. |
| image.tag | string | Current latest release version number | CSGHub Server | Specify the tag of the csghub_server image. |

#### ingress

| Parameter configuration | Field type | Default value | Description |
| :--------------------- | :------- | :----------- | :----------------------------------------------------------- |
| ingress.domain | string | example.com | Specifies the external domain name of the service. |
| ingress.tls.enabled | bool | false | Specifies whether to enable ingress encrypted access.|
| ingress.tls.secretName | string | Null | Specifies the trusted certificate used for encrypted access. |
| ingress.service.type | string | LoadBalancer | Specifies the ingress-nginx service exposure method. <br/>The internal anchor `&type` is used here, please do not delete it. |

#### deployment

| Parameter configuration | Field type | Default value | Description |
| :-------------------------------------------- | :------- | :---------------- | :----------------------------------------------------------- |
| deployment.enabled | bool | true | Specifies whether to enable instance deployment. <br/>If disabled, instances such as space and inference cannot be created (that is, they are not associated with K8S clusters). |
| deployment.kubeSecret | string | kube-configs | Specifies the Secret containing all target clusters `.kube/config`, which needs to be created by yourself. The creation method has been provided in the deployment section. |
| deployment.namespace | string | spaces | The namespace where the deployment instance is located. |
| deployment.knative.serving.autoConfigure | bool | true | Specifies whether to enable automatic deployment of KnativeServing and argo. |
| deployment.knative.serving.services[n].type | string | NodePort | Specifies the service type of the KnativeServing Kourier when [deployment.knative.serving.autoConfigure](#deployment). If the cluster does not support providing multiple LoadBalancer addresses, use NodePort. |
| deployment.knative.serving.services[n].domain | string | app.internal | Specify the internal domain name used by KnativeServing. |
| deployment.knative.serving.services[n].host | string | 192.168.8.3 | Specify the IPv4 address of the KnativeServing Kourier service. |
| deployment.knative.serving.services[n].port | string | 30213 | Specify the port of the KnativeServing Kourier service. If the type is LoadBalancer, it needs to be configured to 80. If the type is NodePort, it needs to be configured to any 5 valid NodePort port numbers. |

### Local

***Note:** There are many components, and only some component parameters are explained. Among them, `autoscaling` is not adapted yet.*

#### gitaly

| Parameter configuration | Field type | Default value | Description |
| :------------------- | :------- | :----- | :----------------------------------- |
| gitaly.logging.level | string | info | Specifies the log output level. Commonly used are info, debug. |

#### minio

| Parameter configuration | Field type | Default value | Description |
| :----------------------- | :------- | :----------------------------------------------------------- | :--------------------- |
| minio.buckets.versioning | bool | true | Specifies whether to enable version control. |
| minio.buckets.defaults | list | csghub-portal<br/>csghub-server<br/>csghub-registry<br/>csghub-workflow | Buckets created by default |

#### postgresql

| Parameter configuration | Field type | Default value | Description |
| :-------------------- | :------- | :----------------------------------------------------------- | :---------------------------------------------------- |
| postgresql.parameters | map | Null | Specify the database parameters to be set, sighup and postmaster are both acceptable. |
| postgresql.databases | list | csghub_portal<br/>csghub_server<br/>csghub_casdoor<br/>csghub_temporal<br/>csghub_temporal_visibility | Databases created by default. |

#### temporal

| Parameter configuration | Field type | Default value | Description |
| :------------------------------- | :------ | :----- | :------------------------------- |
| temporal.authentication.username | string | Null | Specifies the username for authenticating login to Temporal. |
| temporal.authentication.password | string | Null | Specifies the password for authenticating login to Temporal. |

#### Others

For other parameters, please refer to the component `values.yaml` file.

### Dependencies

#### ingress-nginx

| Parameter Configuration | Field Type | Default Value | Scope | Description |
| :----------------------------------------------------- | :------- | :------------------------------------------- | :------- | :----------------------------------------------------------- |
| ingress-nginx.enabled | bool | true | / | Specifies whether to enable the built-in ingress-nginx-controller. |
| ingress-nginx.tcp | map | 22:csghub/csghub-gitlab-shell:22 | / | Specifies an additional exposed TCP port. To modify this configuration, you need to modify `gitlab-shell.internal.port at the same time. `This configuration is a related configuration. |
| ingress-nginx.controller.image.* | map | digest: "" | / | Keep the default. Only used to adapt `global.image.registry. ` |
| ingress-nginx.controller.admissionWebhooks.patch.image | map | digest: "" | / | Keep the default value. Used to adapt `global.image.registry. ` |
| ingress-nginx.controller.config.annotations-risk-level | strings | Critical | / | Keep the default value. Ingress-nginx 4.12, annotations are defined as risk configuration using snippets. |
| ingress-nginx.controller.allowSnippetAnnotations | bool | true | / | Allow the use of configuration snippets. |
| ingress-nginx.controller.service.type | string | Same as global.ingress.service.type | / | Specify the Ingress-nginx-controller service type. |
| ingress-nginx.controller.service.nodePorts | map | http: 30080<br/>https: 30442<br/>tcp.22: 30022 | / | Keep the default. The specified object port corresponds to the exposed nodePort port number by default. This configuration is an associated configuration. |

#### fluentd

| Parameter Configuration | Field Type | Default Value | Scope | Description |
| :------------------ | :------- | :----------------------------- | :------- | :----------------------- |
| fluentd.enabled | bool | true | / | Specify whether to enable fluentd. |
| fluentd.fileConfigs | map | Output to the console in json by default. | / | Specify the processing method for log collection. |

## Troubleshooting

### dial tcp: lookup casdoor.example.com on 10.43.0.10:53: no such host

This problem occurs because the cluster cannot resolve the domain name. If it is a public domain name, please configure domain name resolution. If it is a custom domain name, please configure CoreDNS and Hosts resolution. CoreDNS resolution configuration is as follows:

```shell
# Add custom domain name resolution
$ kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  example.server: |
    example.com {
      hosts {
        172.25.11.131 csghub.example.com csghub
        172.25.11.131 casdoor.example.com casdoor
        172.25.11.131 registry.example.com registry
        172.25.11.131 minio.example.com minio
      }
    }
EOF

# Update coredns pods
$ kubectl -n kube-system rollout restart deploy coredns
```

### ssh: connect to host csghub.example.com port 22: Connection refused

This problem is often caused by the failure of gitlab-shell job execution. If this problem occurs, please follow the following methods to troubleshoot:

1. View

```shell
$ kubectl get cm csghub-ingress-nginx-tcp -n csghub -o yaml
apiVersion: v1
data:
  "22": default/csghub-gitlab-shell:22
......
```

Confirm whether the service name corresponding to port 22 is correct.

2. If it is incorrect, modify it manually

```shell
$ kubectl -n csghub edit configmap/csghub-ingress-nginx-tcp
apiVersion: v1
data:
  "22": csghub/csghub-gitlab-shell:22

# Update ingress-nginx-controller
$ kubectl rollout restart deploy csghub-ingress-nginx-controller -n csghub
```

### http: server gave HTTP response to HTTPS client

CSGHub is installed by default using an insecure registry (i.e., `<domain or IPv4>:5000` mentioned above). You need to ensure that Kubernetes can pull images from this registry. Therefore, you need to configure the following on each Kubernetes node:

1. Before configuration, please confirm whether the configuration file `/etc/containerd/config.toml` exists. If it does not exist, you can use the following command to create it.

```shell
mkdir -p /etc/containerd/ && containerd config default >/etc/containerd/config.toml
```

2. Configure `config_path` 

    - Containerd 1.x

        ```toml
        version = 2
        
        [plugins."io.containerd.grpc.v1.cri".registry]
             config_path = "/etc/containerd/certs.d"
        ```

    - Containerd 2.x

        ```toml
        version = 3
        
        [plugins."io.containerd.cri.v1.images".registry]
             config_path = "/etc/containerd/certs.d"
        ```

3. Configure `hosts.toml`

    ```shell
    # Create the Registry configuration directory
    mkdir /etc/containerd/certs.d/<domain or IPv4>:5000
    
    # Add Configuration
    cat /etc/containerd/certs.d/<domain or IPv4>:5000/hosts.toml
    server = "http://<domain or IPv4>:5000"
    
    [host."http://<domain or IPv4>:5000"]
       capabilities = ["pull", "resolve", "push"]
       skip_verify = true
       plain-http = true
    EOF
    ```

4. Restart `containerd` service

    ```shell
    systemctl restart containerd
    ```

## Feedback

If you encounter any problems during use, you can submit feedback through:

- [Feedback](https://github.com/OpenCSGs/csghub-installer/issues)