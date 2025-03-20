FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/temporalio/auto-setup:1.25.1 AS temporal

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/temporalio/ui:2.30.3 AS temporal-ui

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/minio/minio:RELEASE.2024-07-15T19-02-30Z AS minio-server

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/minio/mc:RELEASE.2024-06-01T15-03-35Z AS minio-mc

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/registry:2.8.3 AS registry

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/gitaly:v17.5.0 AS gitaly

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/gitlab-shell:v17.5.0 AS gitlab-shell

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/csghub_nats:2.10.16 AS nats-server

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/csghub_server:latest AS server

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/csghub_portal:latest AS portal

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/space_builder:latest AS csghub-builder

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/casbin/casdoor:v1.733.0 AS casdoor

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/golang:latest AS go-builder
ENV GOPROXY=https://goproxy.cn,direct
WORKDIR /
COPY logger .
RUN go build -o logger

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/debian:bookworm-slim AS tools
WORKDIR /tools

ARG GL_VERSION=16.4.6-ee.0
RUN apt update && apt install -y wget apache2-utils curl openssh-client && ssh-keygen -A

ARG TARGETPLATFORM
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") \
            curl -L -o /usr/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
            curl -L -o helm.tar.gz https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz \
            ;; \
        "linux/arm64") \
            curl -L -o /usr/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" && \
            curl -L -o helm.tar.gz https://get.helm.sh/helm-v3.16.2-linux-arm64.tar.gz \
            ;; \
        *) \
             echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
     esac

RUN tar -zxf helm.tar.gz -C /usr/bin --strip-components=1 && \
    chmod +x -R /usr/bin/*

RUN rm -rf *.tar.gz /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/debian:bookworm-slim
LABEL authors="opencsg"
ENV GIN_MODE=release \
    DOLLAR=$

WORKDIR /
# ============================================================
#   Init Log Monitor Service
# ============================================================
COPY --from=go-builder /logger /usr/bin/logger

# ============================================================
#   Init PostgreSQL, Redis Services and So on
# ============================================================
# Here are the instructions for installing the allowed programs
RUN pkgDeps=' \
    bash \
    curl \
    gettext \
    yq \
    jq \
    jo \
    procps \
    logrotate \
    git \
    git-lfs \
    vim \
    netcat-openbsd \
    libaprutil1 \
    ca-certificates \
    supervisor \
    postgresql \
    redis-server \
    nginx \
    libnginx-mod-stream  \
    dnsmasq' && \
    apt update && \
    apt install -y --no-install-recommends $pkgDeps

# ============================================================
#   Using bash Shell Default
# ============================================================
SHELL ["/bin/bash", "-c"]
COPY etc /etc
COPY scripts /scripts

# ============================================================
#   Init Minio Services
# ============================================================
COPY --from=minio-server /usr/bin/minio /usr/bin/minio
COPY --from=minio-mc /usr/bin/mc /usr/bin/mc

# ============================================================
#   Init Registry Service
# ============================================================
COPY --from=tools /usr/bin/htpasswd /usr/bin/htpasswd
COPY --from=registry /bin/registry /usr/bin/registry
COPY --from=registry /bin/busybox /usr/bin/busybox

# ============================================================
#   Init Gitaly and Gitlab-Shell Service
# ============================================================
COPY --from=tools /etc/ssh/ssh_host_* /etc/ssh/
COPY --from=gitaly /usr/local/bin/git* /usr/bin/
COPY --from=gitlab-shell /srv/gitlab-shell/bin/* /usr/bin/

# ============================================================
#   Init Nats Service
# ============================================================
COPY --from=nats-server /nats-server /usr/bin/nats-server

# ============================================================
#   Init Space Builder Service
# ============================================================
COPY --from=csghub-builder /app/builder /usr/bin/builder

# ============================================================
#   Init Temporal Service
# ============================================================
COPY --from=temporal /usr/local/bin/* /usr/bin/
COPY --from=temporal /etc/temporal/config /etc/temporal/config
COPY --from=temporal /etc/temporal/schema /etc/temporal/schema
COPY --from=temporal-ui /home/ui-server/ui-server /usr/bin/ui-server
COPY --from=temporal-ui /home/ui-server/config /etc/temporal-ui/config
COPY --from=temporal-ui /home/ui-server/config-template.yaml /etc/temporal-ui/config-template.yaml

# ============================================================
#   Init Casdoor Service
# ============================================================
COPY --from=casdoor /server /usr/bin/casdoor
COPY --from=casdoor /web /etc/casdoor/web

# ============================================================
#   Init CSGHub Server Service
# ============================================================
ENV GIN_MODE=release
COPY --from=server /starhub-bin/starhub /usr/bin/csghub-server
COPY --from=server /root/.duckdb /root/.duckdb
COPY --from=server /starhub-bin/builder/store/database/seeds /builder/store/database/seeds
RUN curl -L https://opencsg-public-resource.oss-cn-beijing.aliyuncs.com/csghub/omnibus-demo/tiny-random-Llama-3.tar.gz -o /etc/server/tiny-random-Llama-3.tar.gz && \
    curl -L https://opencsg-public-resource.oss-cn-beijing.aliyuncs.com/csghub/omnibus-demo/alpaca-gpt4-data-zh.tar.gz -o /etc/server/alpaca-gpt4-data-zh.tar.gz

# ============================================================
#   Init CSGHub Portal Service
# ============================================================
COPY --from=portal /myapp/csghub-portal /usr/bin/csghub-portal

# ============================================================
#   Install kubectl/helm
# ============================================================
COPY --from=tools /usr/bin/kubectl /usr/bin/kubectl
COPY --from=tools /usr/bin/helm /usr/bin/helm

# ============================================================
#   ENTRYPOINT
# ============================================================
RUN useradd registry && \
    useradd minio && \
    useradd -m git && \
    useradd nats && \
    useradd temporal && \
    chmod +x -R /scripts && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/* && \
    chmod 0644 /etc/ssh/ssh_host_* && \
    pg_dropcluster 15 main && rm -rf /etc/postgresql

ENTRYPOINT ["/scripts/entrypoint.sh"]

# docker buildx build --provenance false --platform linux/arm64,linux/amd64 \
#   -t opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:v1.2.0 \
#   -t opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest --push .
