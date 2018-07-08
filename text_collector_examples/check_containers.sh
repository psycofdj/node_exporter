#!/bin/bash

l_found=0
for i in $(docker ps -a -q); do
  l_found=1
  l_name=$(docker inspect $i | jq -r .[].Name)
  l_name=${l_name:1}
  l_imageName=$(docker inspect $i | jq -r .[].Config.Image)
  l_imageID=$(docker inspect $i | jq -r .[].Image)
  docker pull ${l_imageName} 2>&1 > /dev/null
  l_newImageID=$(docker inspect ${l_imageName} --format '{{.Id}}')
  l_outdated=0
  if [ "${l_newImageID}" != "${l_imageID}" ]; then
      l_outdated=1
  fi
  cat - <<EOF
# HELP docker_container_outdated Number of created containers that runs an outdated image
# TYPE docker_container_outdated gauge
docker_container_outdated{container="${l_name}", image="${l_imageName}"} ${l_outdated}
EOF
done

if [ ${l_found} -eq 0 ];then
    cat - <<EOF
# HELP docker_container_outdated Number of created containers that runs an outdated image
# TYPE docker_container_outdated gauge
docker_container_outdated{container="${l_name}", image="${l_imageName}"} 0
EOF
fi
