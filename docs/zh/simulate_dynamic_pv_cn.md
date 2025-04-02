# 模拟动态Persistent Volume安装指引

> **官方文档：**
>
> - [kubernetes-sigs/sig-storage-local-static-provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner)
> - [Install local-volume-provisioner with helm](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner/blob/master/helm/README.md)
>
> _**注意：**本文档仅供参考。_

## 说明

此方案仅使用于用户本地 K8S 环境不支持持久卷动态管理的情况，可以使用此种方式临时替代。

*注意：此方案仅适用于测试。*

## 配置步骤

### 创建 StorageClass

```shell
# 创建 namespace
kubectl create ns kube-storage

# 创建 storage class
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-disks
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
allowVolumeExpansion: true
EOF
```

### 部署 local-volume-provisoner

```shell
# 添加 helm 仓库
helm repo add sig-storage-local-static-provisioner https://kubernetes-sigs.github.io/sig-storage-local-static-provisioner

# 更新仓库
helm repo update

# 创建资源文件
helm template --debug sig-storage-local-static-provisioner/local-static-provisioner --namespace kube-storage | sed 's/registry.k8s.io/opencsg-registry.cn-beijing.cr.aliyuncs.com\/opencsg_public/g'> local-volume-provisioner.generated.yaml

# 应用资源文件
kubectl apply -f local-volume-provisioner.generated.yaml
```

### 创建虚拟磁盘

```shell
for flag in {a..z}; do
	mkdir -p /mnt/fake-disks/sd${flag} /mnt/fast-disks/sd${flag} 2>/dev/null
	mount --bind /mnt/fake-disks/sd${flag} /mnt/fast-disks/sd${flag}
	echo "/mnt/fake-disks/sd${flag} /mnt/fast-disks/sd${flag} none bind 0 0" >> /etc/fstab
done
```

_**注意：**此种挂载方式无法严格控制 PV 大小，但是不影响测试使用。_

### 功能验证

```shell
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: local-volume-example
  namespace: default
spec:
  serviceName: "local-volume-example-service"
  replicas: 1
  selector:
    matchLabels:
      app: local-volume-example
  template:
    metadata:
      labels:
        app: local-volume-example
    spec:
      containers:
      - name: local-volume-example
        image: busybox:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - name: example-storage
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: example-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
EOF

# 查看 pvc/pv
kubectl get pvc
```