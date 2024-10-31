# CSGHUB ALL-IN-ONE

## Summary

This is a project that manages all components of csghub in a unified way. Currently, the overall image is relatively large and will be optimized later.

## Build

```shell
docker build -t opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/csghub-all-in-one:v1.0.0 .
```

## Usage

```shell
docker run -it -d --name csghub --hostname csghub \
    -p 80:80 \
    -p 2222:2222 \
    -p 8000:8000 \
    -p 9000:9000 \
    -e SERVER_DOMAIN=<ip address> \
    -v /srv/opt:/var/opt \
    -v /srv/log:/var/log \
    opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/csghub-all-in-one:v1.0.0
```

Login:

- Access address: `http://<ip address>`
- Username: `root`
- Password: `Um9vdEAxMjM0NTY=`