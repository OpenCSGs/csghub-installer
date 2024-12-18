FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/temporalio/auto-setup:1.25.1 AS temporal

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/temporalio/ui:2.30.3 AS temporal-ui

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/minio/minio:RELEASE.2024-07-15T19-02-30Z AS minio-server

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/minio/mc:RELEASE.2024-06-01T15-03-35Z AS minio-mc

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/registry:2.8.3 AS registry

# FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/gitaly:v16.4.6 AS gitaly

# FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/gitlab-shell:v16.4.6 AS gitlab-shell

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/csghub_nats:2.10.16 AS nats-server

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/csghub_server:v1.2.0 AS server

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/csghub_portal:v1.2.1 AS portal

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/casbin/casdoor:v1.733.0 AS casdoor

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/go-node AS go-builder
ENV GOPROXY=https://goproxy.cn,direct
WORKDIR /
COPY logger .
RUN go build -o logger

FROM debian:bookworm-slim AS tools
WORKDIR /tools

ARG GL_VERSION=16.4.6-ee.0
RUN apt update && apt install -y wget apache2-utils curl openssh-client && ssh-keygen -A
RUN curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | bash

COPY bin .
ARG TARGETPLATFORM
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") \
            cp builder_linux_amd64 /usr/bin/builder && \
            curl -L -o /usr/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
            curl -L -o helm.tar.gz https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz && \
            apt update && apt download gitlab-ee=${GL_VERSION} && \
            dpkg-deb -x gitlab-ee_${GL_VERSION}_amd64.deb / \
            ;; \
        "linux/arm64") \
            cp builder_linux_arm64 /usr/bin/builder && \
            curl -L -o /usr/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" && \
            curl -L -o helm.tar.gz https://get.helm.sh/helm-v3.16.2-linux-arm64.tar.gz && \
            apt update && apt download gitlab-ee=${GL_VERSION} && \
            dpkg-deb -x gitlab-ee_${GL_VERSION}_arm64.deb / \
            ;; \
        *) \
             echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
     esac

RUN tar -zxf helm.tar.gz -C /usr/bin --strip-components=1 && \
    chmod +x -R /usr/bin/*

RUN rm -rf *.deb *.tar.gz /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*

FROM debian:bookworm-slim
LABEL authors="opencsg"
ENV GIN_MODE=release \
    DOLLAR=$
WORKDIR /

# ============================================================
#   Init Log Monitor Service
# ============================================================
COPY --from=go-builder /logger /usr/bin/logger

# ============================================================
#   Init PostgreSQL, Redis Services
# ============================================================
# Here are the instructions for installing the allowed programs
ARG TARGETPLATFORM
RUN apt update && \
    apt install -y --no-install-recommends bash curl gettext yq jq jo procps logrotate git git-lfs vim netcat-openbsd \
        libaprutil1 ca-certificates supervisor postgresql redis nginx libnginx-mod-stream dnsmasq && \
    pg_dropcluster 15 main && rm -rf /etc/postgresql
    # if [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
    #     dpkg --add-architecture amd64 && \
    #     apt-get update && \
    #     apt-get install -y --no-install-recommends libc6:amd64 libpcre2-8-0:amd64 zlib1g:amd64; \
    # fi

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
# COPY --from=gitaly /usr/local/bin/* /usr/bin/
# COPY --from=gitlab-shell /srv/gitlab-shell/bin/* /usr/bin/
COPY --from=tools /opt/gitlab/embedded/bin/gitaly* /usr/bin/
COPY --from=tools /opt/gitlab/embedded/service/gitlab-shell/bin/* /usr/bin/
COPY --from=tools /opt/gitlab/embedded/lib/libiconv.so.2.6.0 /usr/lib/
COPY --from=tools /opt/gitlab/embedded/lib/libiconv.so.2 /usr/lib/

# ============================================================
#   Init Nats Service
# ============================================================
COPY --from=nats-server /nats-server /usr/bin/nats-server

# ============================================================
#   Init Space Builder Service
# ============================================================
COPY --from=tools /usr/bin/builder /usr/bin/builder

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
    chmod 0644 /etc/ssh/ssh_host_*

ENTRYPOINT ["/scripts/entrypoint.sh"]

# docker buildx build --provenance false --platform linux/arm64,linux/amd64 \
#   -t opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:v1.2.0 \
#   -t opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest --push .
