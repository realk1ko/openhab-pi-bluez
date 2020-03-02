#!/bin/bash

TAG="2.5.2-armhf-debian"
IMAGE="openhab-pi-bluez:${TAG}"

docker build -t $IMAGE --build-arg TAG=$TAG .

