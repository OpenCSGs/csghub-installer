# CSGHub Quick Deployment Guide

## Overview

CSGHub offers a one-click Docker deployment solution designed for users who wish to quickly test and experience CSGHub's functionalities. By deploying in Docker's All-in-One mode, users can swiftly launch a CSGHub instance in their local environment (Linux/MacOS/Windows) without complex configuration steps. This deployment method is ideal for functionality testing and basic demonstrations, providing easy access to CSGHub's core features, including model and dataset management, model inference, and fine-tuning.

> **Note:**
> The Docker one-click deployment mode is **not intended for production use** (it does not support high availability, and some configurations are hardcoded within the container).

## Key Benefits

- **Quick Setup**: Deploy a CSGHub instance in your local environment with a single command, enabling fast access to core functionality and feature exploration.
- **Centralized Management**: Easily upload, download, and sync models and datasets, allowing users to experience end-to-end LLM management workflows.
- **Focus on Your Business**: CSGHub handles all configuration and tasks related to LLM management, enabling users to focus on their core objectives without needing to manage underlying infrastructure.

## System Requirements

- **Supported Operating Systems**: Linux, MacOS, Windows
- **Required Tool**: Docker (Download the compatible version from the [Docker official website](https://www.docker.com/))

## Quick Installation Steps

Follow these steps to quickly deploy CSGHub using Docker:

**1. Clone the required files using Git**

`git clone https://github.com/OpenCSGs/csghub.git`

**2. Start the Docker Container**
Run the following command in your terminal to start the CSGHub container (replace `<ip address>` with your machine's IP address):

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

This command will launch an All-in-One CSGHub container that includes essential components for model and dataset management, inference, and fine-tuning.

> How to Find Your IP Address:
>
> - **Linux:** In the terminal, type **ifconfig** and locate the IP address following the **inet** field.
> - **MacOS:** In the terminal, type **ifconfig** and check the **en0** (typically Wi-Fi) or **en1** (wired connection) section for the **inet** field.
> - **Windows:** Press **Win + R**, enter **cmd** to open Command Prompt, then type **ipconfig** and locate the **IPv4 Address**.

> Note: The current CSGHub image supports the AMD64 platform. If you see a warning similar to the one below, you may safely ignore it.
*WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested.*

**3. Access and Log in to CSGHub**
Once the deployment is complete, you can access and log in to CSGHub using the following information:

Access URL: `http://<ip address>`
Username: `root`
Password: `Um9vdEAxMjM0NTY=`

**4. Feature Verification**
After accessing CSGHub, you can explore the following key features:

- Model Management: Quickly upload and manage various types of model files, with support for remote model synchronization and multi-user collaboration.
- Dataset Management: Upload, download, and manage datasets for streamlined testing and validation.
- Inference and Fine-Tuning: Use CSGHub's intuitive interface to perform model inference or fine-tuning, ideal for end-to-end customer use cases.

**5. Stop or Remove the CSGHub Container**

- Use the following command to check the running status of the CSGHub container:

  ```
  docker ps -a | grep csghub
  ```

- To stop or remove the CSGHub container, use the following commands:

  ```
  docker stop csghub
  docker rm csghub
  ```

Following these steps, you can quickly deploy and run CSGHub locally to explore its core functionalities.
