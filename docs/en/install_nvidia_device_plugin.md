# NVIDIA DEVICE PLUGIN Installation Guide

> **Official Documentation:**
>
> - [Install Nvidia Device Plugin](https://github.com/NVIDIA/k8s-device-plugin?tab=readme-ov-file)
>
> ***Note:** This document is for reference only.* 

## Prerequisites

- NVIDIA drivers ~= 384.81
- nvidia-docker >= 2.0 || nvidia-container-toolkit >= 1.7.0 (>= 1.11.0 to use integrated GPUs on Tegra-based systems)
- nvidia-container-runtime configured as the default low-level runtime
- Kubernetes version >= 1.10

## Prepare GPU nodes

> **Note:** Before performing the above operations, you need to add the GPU nodes to the Kubernetes cluster (the GPU machine nodes can be recognized normally in the cluster.)

This part of the operation needs to be performed on all GPU nodes and only configuration is performed, not including NVIDIA driver installation. This part of the configuration mainly modifies **Runtime** to use `nvidia` by default.

Here is an example of containerd configuration based on Debian system:

### Install NVIDIA Container Toolkit

1. Configure software repository

```shell
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

2. Update the software list

```shell
sudo apt-get update
```

3. Install nvidia-container-toolkit

```shell
sudo apt-get install -y nvidia-container-toolkit alsa-utils
```

### Configure the default Runtime

```shell
sudo nvidia-ctk runtime configure --runtime=containerd --config=/etc/containerd/config.toml
```

## Install NVIDIA DEVICE PLUGIN

### Method 1: Helm installation

1. Add Chart repository

    ```shell
    helm repo add nvdp https://nvidia.github.io/k8s-device-plugin --force-update
    helm repo update
    ```

2. Install Chart

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

3. [Optional] Adjust device discovery strategy

The default `device-discovery-strategy` is `auto`, but it may fail to scan the device. This option has two alternative parameter values `nvml` and `tegra`, which can be adjusted manually.

```shell
# nvml strategy
kubectl -n nvdp patch ds nvdp-nvidia-device-plugin --type='json' --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/args", "value": ["--device-discovery-strategy=nvml"]}]'

# tegra strategy
kubectl -n nvdp patch ds nvdp-nvidia-device-plugin --type='json' --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/args", "value": ["--device-discovery-strategy=tegra"]}]'
```

## Manually add a label

The parameter `<NODE>` refers to all GPU nodes.

```shell
kubectl label node "<NODE>" nvidia.com/mps.capable=true nvidia.com/gpu=true
```

Add a label to distinguish GPU models.

Note: Starting from version `1.3.2`, CSGHub Helm Chart will automatically add this label.

Example: `<GPU Model>` ==> `NVIDIA-A10`

```shell
kubectl label node "<NODE>" nvidia.com/nvidia_name=<GPU Model>
```