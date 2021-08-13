#!/bin/bash

if [ -z $1 ]; then
    echo "REPO_URL required"
    exit 1
else
    REPO_URL=$1
fi

apt install -y -qq curl

curl -s ${REPO_URL}/gpg-public.key | apt-key add -
echo "deb ${REPO_URL} ${ROS_DISTRO} stable nightly" | tee /etc/apt/sources.list.d/dynamicx.list

curl -s https://packages.osrfoundation.org/gazebo.key | apt-key add -
echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list

apt update

echo "yaml ${REPO_URL}/rosdep-${ROS_DISTRO}.yaml" | tee /etc/ros/rosdep/sources.list.d/50-dynamicx.list
rosdep update
