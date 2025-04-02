# Argo Workflow Installation Guide

> **Official Documentation:**
>
> - [argo workflow](https://argo-workflows.readthedocs.io/en/latest/)
>
> _**Note:** This document is for reference only._

## Steps

### Installing core components

The argo workflow component is used in csghub to support model evaluation services. Please use the following command to install it:

```shell
# Installing core components
kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/argo/argo.yaml

# Installing rbac
kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/argo/rbac.yaml
```

### Verify Services

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

Confirm that all services are running normally.
