#!/bin/bash
NAME=sy_project_image
TAG=latest
mkdir -p source
# create a shared volume to store the ros_ws
docker volume create --driver local \
    --opt type="none" \
    --opt device="${PWD}/source/" \
    --opt o="bind" \
    "${NAME}_src_vol"

xhost +
docker run \
    --net=host \
    -it \
    --rm \
    --volume="${NAME}_src_vol:/home/ros/ros_ws/src/:rw" \
    "${NAME}:${TAG}