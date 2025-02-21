# CSGHub Docker Compose 部署文档

## 介绍

Docker Compose 作为 CSGHub 常用安装方式之一，具有诸多优势。例如服务管理简单，部署灵活易扩展，快速配置启动等。如果作为生产环境部署，此方式将作为可选方式之一。

## 软/硬件支持

硬件环境需求：

- \>= 4c 8g 100gb

- amd64/arm64

软件环境需求：

- Docker Engine (>=20.10.0)
- Docker Compose (>=2.20.0)

## 部署示例

### 安装包下载

下载请到[Release](https://github.com/OpenCSGs/csghub-installer/releases)页面。

```shell
wget https://github.com/OpenCSGs/csghub-installer/releases/download/v1.4.0/csghub-docker-compose-v1.4.0.tgz
```

### 安装配置

- 解压程序

    ```shell
    tar -zxf csghub-docker-compose-v1.4.0.tgz && cd ./csghub
    ```

- 配置更新

    当前此种部署方式建议配置都在`.env`文件中进行配置。最小配置仅需要配置如下参数即可。

    ```shell
    SERVER_DOMAIN="<domain or ipv4>"
    SERVER_PORT="80"
    SERVER_PROTOCOL="http"
    
    # 指定是否对接 K8S。 0 接入，1 不接入
    CSGHUB_WITH_K8S=1
    KUBE_CONFIG_DIR=".kube/config"
    
    # SPACE_APP 部分配置需要提前配置好
    SPACE_APP_NAMESPACE="spaces"
    SPACE_APP_INTERNAL_DOMAIN="app.internal"  # 默认为
    SPACE_APP_INTERNAL_HOST="<Kourier Service IP>"
    SPACE_APP_INTERNAL_PORT="<Kourier Service Port>"
    ```

- 开始配置

    此命令是可以用来首次部署也可以用来启动 CSGHub，替代`docker compose up -d`。因为此脚本每次执行都会渲染配置文件，保持配置的一致性。

    ```shell
    ./configure
    ```

    等待程序自动配置启动完成。

- 访问地址

    |   服务   |                 地址                  |             管理员             |                        备注                         |
    | :------: | :-----------------------------------: | :----------------------------: | :-------------------------------------------------: |
    |  CSGhub  |       http://\{{ ip address }}        |         root/Root@1234         |                 可在 Casdoor 中修改                 |
    |  Minio   |     http://\{{ ip address }}:9001     | *请查看 .env 中定义的默认账户* |       MINIO_ROOT_USER<br/>MINIO_ROOT_PASSWORD       |
    | Temporal | http://\{{ ip address }}/temporal-ui/ | *请查看 .env 中定义的默认账户* | TEMPORAL_CONSOLE_USER<br/>TEMPORAL_CONSOLE_PASSWORD |
    | Casdoor  |     http://\{{ ip address }}:8000     |           admin/123            |                 可在 Casdoor 中修改                 |
    | Registry |        \{{ ip address }}:5000         | *请查看 .env 中定义的默认账户* |       REGISTRY_USERNAME<br/>REGISTRY_PASSWORD       |

## 版本说明

CSGHub `major.minor` 版本和 CSGHub Server 保持一致，`Patch` 版本根据需要更新。

| Chart 版本 | Csghub 版本 | 说明                          |
| :--------: | :---------: | ----------------------------- |
|   0.8.x    |    0.8.x    |                               |
|   0.9.x    |    0.9.x    | 增加组件 Gitaly, Gitlab-Shell |
|   1.0.x    |    1.0.x    |                               |
|   1.1.x    |    1.1.x    | 增加组件 Temporal             |
|   1.2.x    |    1.2.x    |                               |
|   1.3.x    |    1.3.x    | 移除组件 Gitea                |
|   1.4.x    |    1.4.x    | 增加组件 Dataviewer           |

## 域名和IP

CSGHub Docker Compose 部署方式在域名和 IP 的使用方式上面较为灵活，既可以使用`域名`也可以是`IPv4`。

- **域名**

域名可以使用公有域名或者自定义域名。CSGHub Docker Compose 使用单一域名部署，单一域名访问，相较于 CSGHub Helm Chart 方式，在域名使用上会简洁很多。

***注意：** 如果是自定义域名，请自行配置 Hosts 解析。公有域名，请配置 DNS 云解析。*

- **IPv4**

IP 地址选择需要使用非 `127.0.0.1` 和 `localhost` 的地址。

## .kube/config

`.kube/config`文件作为访问 Kubernetes 集群的重要配置文件，在 CSGHub Docker Compose 部署过程中直接以文件路径方式提供给安装程序。此 `.kube/config`至少需要包含对目标集群部署实例所在的命名空间的完全读写权限。

***注意：** 后续版本中如果开启了 argo和 KnativeServing 的自动配置，还需要创建命名空间等更多权限。* 

## 数据持久化

为了方便使用和管理，此种部署方式直接使用 `Volume Mount/Directory Mapping`存储持久化数据，默认存放在安装目录下的`data`目录中，以`./data/<component>`的方式分开存储。

此外所有配置文件均存储在`./configs`目录下。

## 外部资源

> **提示：** 使用外置服务的同时如果内置服务不禁用，则服务依然会正常启动。

***注意：** 因为 docker compose 中服务是否启动控制并不是很灵活，如果以下变量直接配置为外部服务，也可切换为使用外部服务。同时以下配置也可以修改内部服务配置。*

### Registry

| 变量               | 类型   | 默认值                            | 说明                                          |
| :----------------- | :----- | :-------------------------------- | :-------------------------------------------- |
| REGISTRY_ENABLED   | number | 1                                 | 1: 使用内置 Registry<br/>0: 禁用内置 Registry |
| REGISTRY_PORT      | number | 5000                              | Registry 服务端口号，80 请置空。              |
| REGISTRY_ADDRESS   | string | ${SERVER_DOMAIN}:${REGISTRY_PORT} | 指定 Registry 端点。                          |
| REGISTRY_NAMESPACE | string | csghub                            | 指定 Registry 使用的命名空间。                |
| REGISTRY_USERNAME  | string | registry                          | 指定访问 Registry 的用户名                    |
| REGISTRY_PASSWORD  | string | Registry@2025!                    | 指定访问 Registry 的密码                      |

### PostgreSQL

***注意：** 请自行创建数据库 csghub_server, csghub_portal, casdoor, temporal 。*

| 变量              | 类型   | 默认值        | 说明                                              |
| :---------------- | :----- | :------------ | :------------------------------------------------ |
| POSTGRES_ENABLED  | number | 1             | 1: 使用内置 PostgreSQL<br/>0: 禁用内置 PostgreSQL |
| POSTGRES_HOST     | string | postgres      | PostgreSQL 服务地址。                             |
| POSTGRES_PORT     | number | 5432          | 指定 PostgreSQL 服务端口号。                      |
| POSTGRES_TIMEZONE | string | Asia/Shanghai | 默认即可。无实际意义，无须配置。                  |
| POSTGRES_USER     | string | csghub        | 指定连接 PostgreSQL 的用户名                      |
| POSTGRES_PASSWORD | string | Csghub@2025!  | 指定连接 PostgreSQL 的密码                        |

### ObjectStore

| 变量                    | 类型   | 默认值                             | 说明                                           |
| :---------------------- | :----- | :--------------------------------- | :--------------------------------------------- |
| MINIO_ENABLED           | number | 1                                  | 1: 使用内置对象存储<br/>0: 禁用内置对象存储    |
| MINIO_API_PORT          | number | 9000                               | Minio API服务端口号。                          |
| MINIO_CONSOLE_PORT      | number | 9001                               | Minio Console 服务端口号。                     |
| MINIO_ENDPOINT          | string | ${SERVER_DOMAIN}:${MINIO_API_PORT} | 指定对象存储使用的命名空间。                   |
| MINIO_EXTERNAL_ENDPOINT | string | /                                  | 外部对象存储和MINIO_ENDPOINT一致，否则置空。   |
| MINIO_ROOT_USER         | string | minio                              | 指定访问对象存储的用户名。                     |
| MINIO_ROOT_PASSWORD     | string | Minio@2025!                        | 指定访问对象存储的密码。                       |
| MINIO_REGION            | string | cn-north-1                         | 指定对象存储区域。                             |
| MINIO_ENABLE_SSL        | bool   | false                              | 指定对象存储是否开启加密访问。                 |
| USING_PATH_STYLE        | bool   | true                               | 执行对象存储存储桶访问方式是否使用 path 方式。 |

## 其他变量

### Image 配置

| 变量                | 类型   | 默认值                                                     | 说明                                                 |
| :------------------ | :----- | :--------------------------------------------------------- | :--------------------------------------------------- |
| CSGHUB_IMAGE_PREFIX | string | opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public | 这里仅支持使用公有镜像仓库。                         |
| CSGHUB_VERSION      | string | latest                                                     | 指定 csghub_portal 和 csghub_server 服务的镜像版本。 |

### Nginx 配置

| 变量            | 类型   | 默认值             | 说明                                        |
| :-------------- | :----- | :----------------- | :------------------------------------------ |
| SERVER_DOMAIN   | string | csghub.example.com | 指定配置 CSGHub 使用的域名或 IPv4。         |
| SERVER_PORT     | number | 80                 | 指定 NGINX 监听端口，加密访问请配置为 443。 |
| SERVER_PROTOCOL | string | http               | 指定 URL 协议，加密访问请配置为 https。     |
| SERVER_SSL_CERT | string | /                  | 指开启加密访问的证书。                      |
| SERVER_SSL_KEY  | string | /                  | 指开启加密访问的私钥。                      |

### CSGHub Portal 配置

| 变量                       | 类型 | 默认值 | 说明                                           |
| :------------------------- | :--- | :----- | :--------------------------------------------- |
| CSGHUB_PORTAL_ENABLE_HTTPS | bool | false  | 如果 NGINX 配置为加密访问，此处需配置为 true。 |

### Git 配置

| 变量         | 类型   | 默认值 | 说明                                                       |
| :----------- | :----- | :----- | :--------------------------------------------------------- |
| GIT_SSH_PORT | number | 2222   | 配置 Git Over SSH 使用的端口号，不能和本地 SSHD 服务冲突。 |

### Kubernetes 配置

| 变量            | 类型   | 默认值      | 说明                                                         |
| :-------------- | :----- | :---------- | :----------------------------------------------------------- |
| CSGHUB_WITH_K8S | number | 0           | 1: 对接 K8S<br/>0: 不对接 K8S。                              |
| KUBE_CONFIG_DIR | string | /root/.kube | 存放 config 文件的路径，多个 config 文件需重命名为以 config 开头的文件。 |

### Space Application 配置

| 变量                      | 类型   | 默认值       | 说明                                                         |
| :------------------------ | :----- | :----------- | :----------------------------------------------------------- |
| SPACE_APP_NAMESPACE       | string | spaces       | 创建各类部署实例所在的 K8S 命名空间（会自动创建）。          |
| SPACE_APP_INTERNAL_DOMAIN | string | app.internal | KnativeServing 配置使用的域名。                              |
| SPACE_APP_INTERNAL_HOST   | string | 127.0.0.1    | KnativeServing 配置使用的 Kourier 的访问地址。根据实际填写，不可设置为 127.0.0.1 或 localhost。 |
| SPACE_APP_INTERNAL_PORT   | number | 30541        | KnativeServing 配置使用的 Kourier 的访问端口。根据实际填写。 |

### Gitaly 配置

| 变量                 | 类型   | 默认值            | 说明                                        |
| :------------------- | :----- | :---------------- | :------------------------------------------ |
| GITALY_ENABLED       | number | 1                 | 1: 使用内置 Gitaly<br/>0: 禁用内置 Gitaly。 |
| GITALY_SERVER_SOCKET | string | tcp://gitaly:8075 | Gitaly 服务地址。                           |
| GITALY_STORAGE       | string | default           | 保持默认即可。                              |
| GITALY_AUTH_TOKEN    | string | Gitaly@2025!      | 指定连接到 Gitaly 服务的验证 Token。        |

### Temporal 配置

| 变量                      | 类型   | 默认值         | 说明                             |
| :------------------------ | :----- | :------------- | :------------------------------- |
| TEMPORAL_UI_ENABLED       | number | 1              | 启用 UI 访问服务。               |
| TEMPORAL_CONSOLE_USER     | string | temporal       | 指定访问 Temporal 服务的用户名。 |
| TEMPORAL_CONSOLE_PASSWORD | string | Temporal@2025! | 指定访问 Temporal 服务的密码。   |

### 其他配置

按需修改。

## 故障排查

### http: server gave HTTP response to HTTPS client

CSGHub 默认安装使用不安全的 registry（即上面提到的：`<domain or IPv4>:5000`），需要确保 Kubernetes 可以从这个 registry 拉取镜像。因此在 Kubernetes 的每个节点上需做如下配置：

1. 配置前请确认配置文件 `/etc/containerd/config.toml` 是否存在，若不存在，可以使用以下命令创建。

```shell
mkdir -p /etc/containerd/ && containerd config default >/etc/containerd/config.toml
```

2. 配置 config_path 

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

3. 配置 `hosts.toml`

    ```shell
    # 创建 Registry 配置目录
    mkdir /etc/containerd/certs.d/<domain or IPv4>:5000
    
    # 定义配置
    cat /etc/containerd/certs.d/<domain or IPv4>:5000/hosts.toml
    server = "http://<domain or IPv4>:5000"
    
    [host."http://<domain or IPv4>:5000"]
       capabilities = ["pull", "resolve", "push"]
       skip_verify = true
       plain-http = true
    EOF
    ```

4. 重启 `containerd` 服务

    ```shell
    systemctl restart containerd
    ```

## 问题反馈

如遇使用过程中遇到任何问题可以通过方式提交反馈：

-  [Feedback](https://github.com/OpenCSGs/csghub-installer/issues)
