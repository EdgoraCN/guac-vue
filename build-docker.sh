export image=guac-vue
export tag=1.3.2
docker build -t registry.cn-beijing.aliyuncs.com/edgora-oss/$image --no-cache -f Dockerfile .

docker tag  registry.cn-beijing.aliyuncs.com/edgora-oss/$image  registry.cn-beijing.aliyuncs.com/edgora-oss/$image:$tag

docker push  registry.cn-beijing.aliyuncs.com/edgora-oss/$image

docker push  registry.cn-beijing.aliyuncs.com/edgora-oss/$image:$tag


docker tag  registry.cn-beijing.aliyuncs.com/edgora-oss/$image:$tag  edgora/$image:$tag
docker push edgora/$image:$tag
