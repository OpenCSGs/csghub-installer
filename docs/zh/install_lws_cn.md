# LeaderWorkSet 安装指引

> **官方文档：**
>
> - [lws](https://github.com/kubernetes-sigs/lws)
>
> _**注意：**本文档仅供参考。_

## 安装说明

CSGHub 通过 lws 实现多机多卡部署推理服务。

## 安装步骤

### 安装 CRD 和 RBAC 资源

```shell
$ kubectl apply --server-side -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/lws/manifests.yaml
```

### 验证服务

```shell
$ kubectl get all -n lws-system
NAME                                          READY   STATUS    RESTARTS   AGE
pod/lws-controller-manager-6cd4b7dc75-24znc   1/1     Running   0          15h
pod/lws-controller-manager-6cd4b7dc75-kk9q2   1/1     Running   0          15h

NAME                                             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/lws-controller-manager-metrics-service   ClusterIP   10.100.3.7       <none>        8443/TCP   15h
service/lws-webhook-service                      ClusterIP   10.100.178.191   <none>        443/TCP    15h

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/lws-controller-manager   2/2     2            2           15h

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/lws-controller-manager-6cd4b7dc75   2         2         2       15h
```

确认所有服务正常运行。
