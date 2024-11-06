# CSGHub 快速部署指南

## 概述

CSGHub 提供了一键式 Docker 部署方案，专为希望快速验证和体验 CSGHub 功能的用户设计。通过 Docker All-in-One 模式部署，用户可以在本地环境（Linux/MacOS/Windows）中快速启动 CSGHub 实例，免去繁琐的配置过程。该部署方式适用于功能验证和简单测试，让用户可以简单快捷地访问 CSGHub 的核心功能，包括模型/数据集的管理、推理和微调等核心功能，全程无需复杂的配置。

> **注意：**
> Docker 一键部署模式**不适用于生产环境**（不支持系统高可用/部分配置硬编码在容器中）。

## 功能优势

- **快速上手**：只需运行一条命令即可在本地环境中部署 CSGHub 实例，适合快速体验和核心功能演示。
- **集中式管理**：支持模型和数据集的上传、下载和同步，帮助用户完整体验端到端的 LLM 管理流程。
- **专注业务，无需配置**：所有与 LLM 管理相关的配置和任务均由 CSGHub 处理，用户可专注于自身业务，而无需关注底层配置。

## 系统要求

- **支持的操作系统**：Linux、MacOS、Windows
- **依赖工具**：Docker（请前往 [Docker 官网](https://www.docker.com/)下载适配您设备的版本）

## 快速安装步骤

请按照以下步骤使用 Docker 快速部署 CSGHub：

**1. 使用 Git 下载部署所需的必要文件**

`git clone https://github.com/OpenCSGs/csghub.git`

**2. 启动 Docker 容器**  
在终端中运行以下命令来启动 CSGHub 容器（将 `<ip address>` 替换为您的本机 IP 地址）：

```shell
docker run -it -d --name csghub --hostname csghub \
    -p 80:80 \
    -p 2222:2222 \
    -p 8000:8000 \
    -p 9000:9000 \
    -e SERVER_DOMAIN=<ip address> \
    -v /srv/opt:/var/opt \
    -v /srv/log:/var/log \
    opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/csghub-all-in-one:v1.0.0
```

此命令将启动一个 All-in-One 的 CSGHub 容器，包含模型/数据集管理、推理微调等必要组件。

> Linux、MacOS、Windows 系统可分别通过如下方式获取本机 IP 地址：
>
> - **Linux：** 在终端中输入 **ifconfig**，查找输出中的 **inet** 字段后的值，即为本机 IP 地址。
> - **MacOS：** 在终端中输入 **ifconfig**，查找 **en0**（通常是 Wi-Fi 连接）或 **en1**（有线连接）部分中的 **inet** 字段后的值，即为本机 IP 地址。
> - **Windows：** 按下 **Win + R**，输入 **cmd**，打开命令提示符，输入 **ipconfig**，查找 **IPv4 地址** 字段，即为本机 IP 地址。

> 注意：当前 CSGHub 镜像已支持 AMD64 平台，若您遇到类似如下 Warning，可忽略。
*WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested
c18a023b21c5619b1b613bf6dd215942cd9adec6d61d5e1d4b9e2795bee62cd0*

**3. 访问和登录 CSGHub**
部署完成后，可以通过以下 URL 登录并访问 CSGHub：

- 访问地址: `http://<ip address>`
- 用户名: `root`
- 密码: `Um9vdEAxMjM0NTY=`

**4. 功能验证**
访问 CSGHub，您可以体验以下主要功能：

- 模型管理：一键上传和管理不同类型的模型文件，支持远端模型同步和多用户协作。
- 数据集管理：支持数据集的上传、下载和管理，便于快速验证和测试。
- 一键推理与微调：通过 CSGHub 的简化界面执行模型推理或微调，适用于端到端的客户案例。

**5. 停止或删除 CSGHub 容器**

- 通过以下命令检查 CSGHub 容器的运行状态：

  ```
  docker ps -a | grep csghub
  ```

- 使用以下命令停止或删除 CSGHub 容器：

  ```
  docker stop csghub
  docker rm csghub
  ```

通过以上步骤，您可以在本地快速部署并运行 CSGHub，轻松体验其核心功能。
