# NVIDIA DEVICE PLUGIN 安装指引

> **官方文档：**
>
> - [Install Nvidia Device Plugin](https://github.com/NVIDIA/k8s-device-plugin?tab=readme-ov-file)
>
> ***注意：**本文档仅供参考。*

## 前置条件

- NVIDIA Cuda >= 12.1
- NVIDIA drivers >= 384.81
- nvidia-docker >= 2.0 || nvidia-container-toolkit >= 1.7.0 (>= 1.11.0 to use integrated GPUs on Tegra-based systems)
- nvidia-container-runtime configured as the default low-level runtime
- Kubernetes version >= 1.10

## 准备 GPU 节点

> **注意:** 在执行以上操作之前，需要将 GPU 节点加入到 Kubernetes 集群中（集群中可以正常识别到 GPU 机器节点即可。）

此部分操作需要在所有 GPU 节点上面操作且仅做配置不包含 NVIDIA 驱动安装。此部分配置主要是修改 **Runtime** 默认使用`nvidia`。

这里以基于 Debian 系统的 containerd 配置示例：

### 安装 NVIDIA Container Toolkit

1. 配置软件仓库

    ```shell
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    ```

2. 更新软件列表

    ```shell
    sudo apt-get update
    ```

3. 安装 nvidia-container-toolkit

    ```shell
    sudo apt-get install -y nvidia-container-toolkit alsa-utils
    ```

### 配置默认 Runtime

```shell
sudo nvidia-ctk runtime configure --runtime=containerd --config=/etc/containerd/config.toml
```

## 安装 NVIDIA DEVICE PLUGIN

### 方式一：Helm 安装

1. 添加 Chart 仓库

    ```shell
    helm repo add nvdp https://nvidia.github.io/k8s-device-plugin --force-update
    helm repo update
    ```

2. 安装 Chart

    ```shell
    helm upgrade -i nvdp nvdp/nvidia-device-plugin \
      --namespace nvdp \
      --create-namespace \
      --version v0.17.0 \
      --set gfd.enabled=true \
      --set runtimeClassName=nvidia \
      --set image.repository=opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/nvidia/k8s-device-plugin \
      --set nfd.image.repository=opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/nfd/node-feature-discovery
    ```

3. 【可选】调整设备发现策略

    默认 `device-discovery-strategy`为`auto`，但是可能出现无法扫描到设备的情况，此选项存在两个备选参数值`nvml`和`tegra`，可以尝试手动调整。

    ```shell
    # nvml 策略
    kubectl -n nvdp patch ds nvdp-nvidia-device-plugin --type='json' --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/args", "value": ["--device-discovery-strategy=nvml"]}]'
    
    # tegra 策略
    kubectl -n nvdp patch ds nvdp-nvidia-device-plugin --type='json' --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/args", "value": ["--device-discovery-strategy=tegra"]}]'
    ```

### 方式二：YAML 安装

```shell
kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.17.0/deployments/static/nvidia-device-plugin.yml
```

## 手动添加 Label

参数 `<NODE>`指所有 GPU 节点。

```shell
kubectl label node "<NODE>" nvidia.com/mps.capable=true nvidia.com/gpu=true
```

添加 Label 以区分 GPU 型号。

注意：自 1.3.2 版本开始，CSGHub Helm Chart 会自动添加此 Label。

示例：`<GPU Model>` ==> `NVIDIA-A10`

```shell
kubectl label node "<NODE>" nvidia.com/nvidia_name=<GPU Model>
```
