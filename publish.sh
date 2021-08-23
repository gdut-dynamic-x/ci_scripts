#!/bin/sh

eval `ssh-agent -s`
echo "$SSH_PRIVATE_KEY" | ssh-add -
mkdir ~/.ssh
echo "$SSH_SERVER_HOSTKEYS" >> ~/.ssh/known_hosts

PACKAGES=$(/bin/ls . | grep ros-${ROS_DISTRO});

if [ -z $1 ]; then
  BRANCH_NAME="master"
else
  BRANCH_NAME=$1
fi

if [ $BRANCH_NAME = "master" ]; then
  COMPONENT_NAME=stable
else
  COMPONENT_NAME=nightly
fi

echo "Publish Packages to $COMPONENT_NAME"

ssh -p $REPO_SSH_PORT root@$REPO_SSH_HOST "" &> /dev/null
scp -P $REPO_SSH_PORT ./ros-${ROS_DISTRO}* root@$REPO_SSH_HOST:/repo/incoming/${ROS_DISTRO}/$COMPONENT_NAME
ssh -p $REPO_SSH_PORT root@$REPO_SSH_HOST "repo-process-include $ROS_DISTRO $COMPONENT_NAME"

for DEB_FILE in $PACKAGES; do
  ssh -p $REPO_SSH_PORT root@$REPO_SSH_HOST "rm /repo/incoming/$ROS_DISTRO/$COMPONENT_NAME/$DEB_FILE || true"
done
