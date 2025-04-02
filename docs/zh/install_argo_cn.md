# Argo Workflow 安装指引

> **官方文档：**
>
> - [argo workflow](https://argo-workflows.readthedocs.io/en/latest/)
>
> _**注意：**本文档仅供参考。_

## 安装步骤

### 安装核心组件

argo workflow组件在csghub中用于支持模型评测服务。请使用如下命令进行安装：

```shell
# 安装核心组件
kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/argo/argo.yaml

# 安装rbac组件
kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/argo/rbac.yaml
```

### 验证服务

```shell
$ kubectl -n argo get all 
NAME                                       READY   STATUS    RESTARTS   AGE
pod/argo-server-6d885749b-mb7rl            1/1     Running   0          5d7h
pod/workflow-controller-85ff8b9949-64rcv   1/1     Running   0          5d7h

NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/argo-server   ClusterIP   10.109.204.164   <none>        2746/TCP   5d7h

NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/argo-server           1/1     1            1           5d7h
deployment.apps/workflow-controller   1/1     1            1           5d7h

NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/argo-server-6d885749b            1         1         1       5d7h
replicaset.apps/workflow-controller-85ff8b9949   1         1         1       5d7h
```

确认所有服务正常运行。
