#!/bin/bash

image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.5-a3-release20260121"
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.3.rc2-a3-release20260109"

docker_name=lts-test-$(echo $image | cut -d: -f2)

docker run -itd --privileged --network=host --shm-size=16g \
--name ${docker_name} \
-v /mnt:/mnt \
-v /home:/home \
-v /data/ascend-ci-share-pkking-sglang:/root/.cache \
-v /data:/data \
-v /usr/local/sbin:/usr/local/sbin \
-v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
-v /usr/local/Ascend/firmware:/usr/local/Ascend/firmware \
-v /etc/asceng_install.info:/etc/asceng_install.info \
-v /var/queue_scheduler:/var/queue_scheduler \
--device=/dev/davinci0 \
--device=/dev/davinci1 \
--device=/dev/davinci2 \
--device=/dev/davinci3 \
--device=/dev/davinci4 \
--device=/dev/davinci5 \
--device=/dev/davinci6 \
--device=/dev/davinci7 \
--device=/dev/davinci8 \
--device=/dev/davinci9 \
--device=/dev/davinci10 \
--device=/dev/davinci11 \
--device=/dev/davinci12 \
--device=/dev/davinci13 \
--device=/dev/davinci14 \
--device=/dev/davinci15 \
--device=/dev/davinci_manager \
--device=/dev/hisi_hdc \
--entrypoint=bash \
--env HF_ENDPOINT=https://hf-mirror.com \
${image}

docker exec -it -uroot $docker_name /bin/bash
