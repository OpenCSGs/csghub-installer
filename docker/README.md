# CSGHub Quick Deployment Guide  

## Overview  

CSGHub provides a streamlined Docker deployment solution for quick testing and evaluation. The All-in-One Docker container allows users to instantly deploy CSGHub on their local machine (Linux/MacOS/Windows) with minimal setup.  
This deployment approach is perfect for proof of concept and testing purposes, enabling users to immediately access CSGHub's core features including model/dataset management, inference, and fine-tuning.  

> **Note:**  
> This deployment method is **not intended for production use** (lacks high availability support and contains hardcoded configurations).  

## Advantages  

- **Quick Setup:** One-command deployment for rapid testing and demos.  
- **Unified Management:** Integrated model and dataset management featuring remote synchronization.  
- **Zero Configuration:** Streamlined LLM operations without configuration overhead.  

## Prerequisites  

- **Supported OS**: Linux, MacOS, Windows  
- **Required Tool**: Docker installed (Download from [Docker official website](https://www.docker.com/))  

## Installation Steps  

Follow these steps to quickly deploy CSGHub:

**1. Launch Container**  
Run the following command in your terminal to start the CSGHub container, replacing `<ip address>` with your local IP:  

```shell
docker run -it -d --name csghub --hostname csghub \
    -p 80:80 \
    -p 2222:2222 \
    -p 8000:8000 \
    -p 9000:9000 \
    -e SERVER_DOMAIN=<ip address> \
    opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/csghub-all-in-one:v1.0.0
```

This creates an All-in-One CSGHub container with everything you need for model/dataset management, inference, and fine-tuning.  

> Finding Your IP Address:  
>
> - **Linux:** Run **ifconfig** and look for the **inet** address  
> - **MacOS:** Run **ifconfig** and check **en0** (WiFi) or **en1** (ethernet) for the **inet** address  
> - **Windows:** Press **Win + R**, type **cmd**, then run **ipconfig** and look for **IPv4 Address**  

> Note: The CSGHub image supports AMD64 platforms. You can safely ignore warnings like:  
*WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested
c18a023b21c5619b1b613bf6dd215942cd9adec6d61d5e1d4b9e2795bee62cd0*  

**2. Access CSGHub**  
Once deployed, connect to CSGHub using:  

- Access URL: `http://<ip address>`  
- Username: `root`  
- Password: `Um9vdEAxMjM0NTY=`  

**3. Explore Features**  

CSGHub offers several key capabilities:  

- Model Management: Easily upload and manage models with support for remote synchronization and team collaboration.  
- Dataset Management: Streamlined tools for handling your datasets - perfect for quick testing and validation.  
- Inference & Fine-tuning: User-friendly interfaces for running inferences and fine-tuning models, suitable for end-to-end use cases.  

**4. Manage CSGHub Container**  

```shell
# Check running status
docker ps -a | grep csghub

# Stop container
docker stop csghub

# Remove container
docker rm csghub
```

With these steps, you'll have CSGHub running locally and be all set to explore its core features!
