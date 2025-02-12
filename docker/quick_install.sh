#!/bin/bash

# Check if Docker meets the minimum version requirements
DOCKER_VERSION=$(docker --version | awk '{print $3}' | tr -d ',')
MINIMUM_VERSION="20.10.0"
if [[ "$(printf '%s\n' "$DOCKER_VERSION" "$MINIMUM_VERSION" | sort -V | head -n1)" != "$MINIMUM_VERSION" ]]; then
    echo "Warning: You are using an outdated version of Docker. Please consider upgrading."
fi

if [ $(uname) == "Darwin" ]; then
    IPv4=$(ipconfig getifaddr $(route get default | grep interface | awk '{print $2}'))
elif [ $(uname) == "Linux" ]; then
    IPv4=$(ip addr show $(ip route show default | awk '/default/ {print $5}') | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
else
    echo "Not supported."
    exit 1
fi

# 显示帮助信息的函数
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h HOST       Specify visit host (default csghub.example.com)."
    echo "  -p PORT       Specify visit port (default 80)."
    echo "  -s PORT       Specify git ssh port (default 2222)."
    echo "  -r PORT       Specify registry port (default 5000)."
    echo "  -a PORT       Specify casdoor port (default 8000)."
    echo "  -m PORT       Specify minio port (default 9000)."
    echo "  -v VOLUME     Specify location for data persistence (default .)."
    echo "  -k            Integrate k8s cluster."
    echo "  -c CONFIG     Specify the configuration file (required if -k is specified, default ~/.kube)."
    echo "  -i IMAGE      Specify the Docker image to use (default: <ACR>/opencsg_public/omnibus-csghub:latest)."
    echo "  -o            Only print docker command."
    echo "  -H, --help    Display this help message."
}

# 默认值
host=csghub.example.com
port=80
ssh_port=2222
registry_port=5000
casdoor_port=8000
minio_port=9000
volume=.
k8s=false
config=""
image="opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest"
print=false

# 解析短选项
while getopts ":h:p:s:r:a:m:v:i:c:okH" opt; do
  case $opt in
    h) host="$OPTARG" ;;
    p) port="$OPTARG" ;;
    s) ssh_port="$OPTARG" ;;
    r) registry_port="$OPTARG" ;;
    a) casdoor_port="$OPTARG" ;;
    m) minio_port="$OPTARG" ;;
    v) volume="$OPTARG" ;;
    k) k8s=true ;;
    c) config="$OPTARG" ;;
    i) image="$OPTARG" ;;
    o) print=true ;;
    H) show_help; exit 0 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; show_help; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; show_help; exit 1 ;;
  esac
done

# 移除已解析的短选项
shift $((OPTIND - 1))

docker_cmd="docker run -it -d \
    --name omnibus-csghub \
    --hostname omnibus-csghub \
    -p ${port}:80 \
    -p ${ssh_port}:2222 \
    -p ${casdoor_port}:8000 \
    -p ${minio_port}:9000 \
    -v ${volume}/csghub/data:/var/opt \
    -v ${volume}/csghub/log:/var/log \
    -e SERVER_DOMAIN=${host} \
    -e SERVER_PORT=${port} \
    -e GITLAB_SHELL_SSH_PORT=${ssh_port} \
    -e CASDOOR_PORT=${casdoor_port} \
    -e S3_ENDPOINT=${host}:${minio_port}   "

if ! [[ "$port" =~ ^[0-9]+$ ]]; then
    echo "Error: Port must be a positive integer."
    exit 1
fi

if $k8s && [[ -z "$config" ]]; then
    echo "Error: -k requires -c to be specified."
    exit 1
fi

if $k8s; then
    docker_cmd+="  -e CSGHUB_WITH_K8S=1 \
    -v ${config:-"~/.kube"}:/etc/.kube \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -p ${registry_port}:5000 \
    -e REGISTRY_ADDRESS=${host}:${registry_port}   "
else
    docker_cmd+="  -e CSGHUB_WITH_K8S=0   "
fi

if [ "$port" == "80" ] || [ "$port" == "443" ]; then
    URL=http://${host}
else
    URL=http://${host}:${port}
fi

cat <<EOF

Visit Info:
  url: ${URL}
  auth: root/Root@1234

Note:
  1. '${IPv4} ${host}' should be added to hosts.
  2. Remove with \`docker rm -f omnibus-csghub\`.

EOF

docker_cmd+="  $image"

if $print; then
    echo -e "${docker_cmd//   / \ \n}"
else
    eval "$docker_cmd"
fi
