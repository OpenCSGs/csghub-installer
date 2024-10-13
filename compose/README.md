## 说明
CSGHub支持以compose方式部署，使用该方法需要注意如下几点：
1. compose方式部署的CSGhub实例可用于测试和试用，生产环境推荐使用helm chart方式安装。
1. compose方式部署的CSGHub实例不能直接使用依赖kubernetes平台的部分功能，比如应用空间，模型推理和模型微调。和kubernetes平台的对接配置部分不在compose部署方式范围之内。
1. 从CSGHub v0.9.0版本开始，CSGHub不再对gitea后端提供持续支持，推荐使用gitaly后端.
