FROM debian:bookworm-slim AS tools
WORKDIR /tools

RUN apt update && apt install -y wget apache2-utils curl openssh-client

ARG MINIO_VERSION=latest
RUN if [ "$(uname -m)" = "x86_64" ]; then \
        ARCH="amd64"; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
        ARCH="arm64"; \
    else \
        echo "Unsupported architecture"; exit 1; \
    fi && \
    curl -o minio https://dl.min.io/server/minio/release/linux-${ARCH}/minio && \
    curl -o mc https://dl.min.io/client/mc/release/linux-${ARCH}/mc && \
    chmod +x minio mc

ARG DISTRIBUTION_VERSION=2.8.3
RUN if [ "$(uname -m)" = "x86_64" ]; then \
        ARCH="amd64"; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
        ARCH="arm64"; \
    else \
        echo "Unsupported architecture"; exit 1; \
    fi && \
    curl -O https://ghp.ci/https://github.com/distribution/distribution/releases/download/v${DISTRIBUTION_VERSION}/registry_${DISTRIBUTION_VERSION}_linux_${ARCH}.tar.gz && \
    tar -zxf registry_${DISTRIBUTION_VERSION}_linux_${ARCH}.tar.gz -C /tools && rm -rf registry_${DISTRIBUTION_VERSION}_linux_${ARCH}.tar.gz

ARG GITALY_VERSION=v17.5.0
RUN curl -O http://gitlab-ubi.s3.amazonaws.com/ubi-build-dependencies-${GITALY_VERSION}-ubi/gitaly.tar.gz && \
    tar -zxf gitaly.tar.gz

ARG GITLAB_SHELL_VERSION=v17.5.0
RUN curl -O http://gitlab-ubi.s3.amazonaws.com/ubi-build-dependencies-${GITLAB_SHELL_VERSION}-ubi/gitlab-shell.tar.gz && \
    tar -zxf gitlab-shell.tar.gz

ARG NATS_VERSION=v2.10.22
RUN if [ "$(uname -m)" = "x86_64" ]; then \
        ARCH="amd64"; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
        ARCH="arm64"; \
    else \
        echo "Unsupported architecture"; exit 1; \
    fi && \
    curl -O https://ghp.ci/https://github.com/nats-io/nats-server/releases/download/${NATS_VERSION}/nats-server-${NATS_VERSION}-linux-${ARCH}.tar.gz && \
    tar -zxf nats-server-${NATS_VERSION}-linux-${ARCH}.tar.gz --strip-components=1

RUN ssh-keygen -A

COPY bin .
ARG TARGETPLATFORM
RUN case ${TARGETPLATFORM} in \
        "linux/amd64") \
            cp builder_linux_amd64 /usr/bin/builder && \
            curl -L -o /usr/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
            curl -L -o helm.tar.gz  https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz \
            ;; \
        "linux/arm64") \
            cp builder_linux_arm64 /usr/bin/builder && \
            curl -L -o /usr/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" && \
            curl -L -o helm.tar.gz  https://get.helm.sh/helm-v3.16.2-linux-arm64.tar.gz \
            ;; \
        *) \
             echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
     esac

RUN tar -zxf helm.tar.gz -C /usr/bin --strip-components=1 && \
    chmod +x -R /usr/bin/*

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/csghub_server:base-1.0 AS server-builder
ENV GOPROXY=https://goproxy.cn,direct
WORKDIR /

ARG TAG=v1.0.0
RUN apt update && apt install -y git && \
    git clone -b $TAG --depth=1 https://ghp.ci/https://github.com/OpenCSGs/csghub-server.git csghub-server

RUN cd /csghub-server && CGO_ENABLED=1 GOOS=linux go build -v -o csghub-server ./cmd/csghub-server

FROM opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/go-node AS go-builder
ENV GOPROXY=https://goproxy.cn,direct
WORKDIR /

COPY logger .
RUN go build -o logger

RUN apt update && apt install -y git && \
    git clone -b v1.733.0 --depth=1 https://ghp.ci/https://github.com/casdoor/casdoor.git casdoor

RUN cd /casdoor/web && yarn install && yarn build
RUN cd /casdoor && CGO_ENABLED=0 GOOS=linux go build -o ./casdoor

ARG TAG=v1.0.0
RUN git clone -b $TAG --depth=1 https://ghp.ci/https://github.com/OpenCSGs/csghub.git csghub-portal

RUN cd /csghub-portal/frontend && yarn install && yarn build
RUN cd /csghub-portal && CGO_ENABLED=0 GOOS=linux go build -o ./csghub-portal ./cmd/csghub-portal

FROM debian:bookworm-slim
LABEL authors="opencsg"
ENV GIN_MODE=release \
    DOLLAR=$
WORKDIR /

# ============================================================
#                   Init Log Monitor Service
# ============================================================
COPY --from=go-builder /logger /usr/bin/logger

# ============================================================
#             Init PostgreSQL, Redis Services
# ============================================================
# Here are the instructions for installing the allowed programs
RUN apt update && \
    apt install -y --no-install-recommends bash curl gettext yq jq jo procps logrotate \
        libaprutil1 ca-certificates supervisor postgresql redis nginx libnginx-mod-stream dnsmasq && \
    pg_dropcluster 15 main && rm -rf /etc/postgresql

SHELL ["/bin/bash", "-c"]
COPY etc /etc
COPY scripts /scripts
# ============================================================
#                   Init Minio Services
# ============================================================
COPY --from=tools /tools/minio /usr/bin/minio
COPY --from=tools /tools/mc /usr/bin/mc

# ============================================================
#                     Init Registry Service
# ============================================================
COPY --from=tools /tools/registry /usr/bin/registry
COPY --from=tools /usr/bin/htpasswd /usr/bin/htpasswd

# ============================================================
#            Init Gitaly and Gitlab-Shell Service
# ============================================================
COPY --from=tools /tools/usr/local/bin/* /usr/bin/
COPY --from=tools /tools/srv/gitlab-shell/bin/* /usr/bin/
COPY --from=tools /etc/ssh/ssh_host_* /etc/ssh/

# ============================================================
#                     Init Nats Service
# ============================================================
COPY --from=tools /tools/nats-server /usr/bin/

# ============================================================
#                   Init Space Builder Service
# ============================================================
COPY --from=tools /usr/bin/builder /usr/bin/builder

# ============================================================
#                    Init Casdoor Service
# ============================================================
COPY --from=go-builder /casdoor/casdoor /usr/bin/casdoor
COPY --from=go-builder /casdoor/web/build /etc/casdoor/web/build

# ============================================================
#                     Init CSGHub Server Service
# ============================================================
ENV GIN_MODE=release
COPY --from=server-builder /csghub-server/csghub-server /usr/bin/
COPY --from=server-builder /csghub-server/builder/store/database/seeds /builder/store/database/seeds

# ============================================================
#                     Init CSGHub Server Service
# ============================================================
COPY --from=go-builder /csghub-portal/csghub-portal /usr/bin/csghub-portal

# ============================================================
#                      Install kubectl/helm
# ============================================================
COPY --from=tools /usr/bin/kubectl /usr/bin/kubectl
COPY --from=tools /usr/bin/helm /usr/bin/helm

# ============================================================
#                         ENTRYPOINT
# ============================================================
RUN useradd registry && \
    useradd minio && \
    useradd -m git && \
    useradd nats && \
    chmod +x -R /scripts && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/* && \
    chmod 0644 /etc/ssh/ssh_host_*

ENTRYPOINT ["/scripts/entrypoint.sh"]