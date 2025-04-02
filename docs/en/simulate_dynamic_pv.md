# Simulate Dynamic Persistent Volume  Installation Guide

> **Official Documentation：**
>
> - [kubernetes-sigs/sig-storage-local-static-provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner)
> - [Install local-volume-provisioner with helm](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner/blob/master/helm/README.md)
>
> _**Note:** This document is for reference only._

## Summary

This solution is only used when the user's local K8S environment does not support dynamic management of persistent volumes. This method can be used as a temporary alternative.

*Note: This solution is only applicable to testing.* 

## Steps

### Create StorageClass

```shell
# Create namespace
kubectl create ns kube-storage

# Create storage class
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

### Deploy local-volume-provisonerA

```shell
# Add helm repo
helm repo add sig-storage-local-static-provisioner https://kubernetes-sigs.github.io/sig-storage-local-static-provisioner

# Update helm repo
helm repo update

# Create resources file
helm template --debug sig-storage-local-static-provisioner/local-static-provisioner --namespace kube-storage | sed 's/registry.k8s.io/opencsg-registry.cn-beijing.cr.aliyuncs.com\/opencsg_public/g'> local-volume-provisioner.generated.yaml

# Apply resources file
kubectl apply -f local-volume-provisioner.generated.yaml
```

### Create Fake Disk

```shell
for flag in {a..z}; do
	mkdir -p /mnt/fake-disks/sd${flag} /mnt/fast-disks/sd${flag} 2>/dev/null
	mount --bind /mnt/fake-disks/sd${flag} /mnt/fast-disks/sd${flag}
	echo "/mnt/fake-disks/sd${flag} /mnt/fast-disks/sd${flag} none bind 0 0" >> /etc/fstab
done
```

_**Note:** This mounting method cannot strictly control the PV size, but it does not affect the test use._

### Functional Verification

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

# get pvc/pv
kubectl get pvc
```