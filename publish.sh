#!/bin/sh

eval `ssh-agent -s`
echo "$SSH_PRIVATE_KEY" | ssh-add -
mkdir ~/.ssh
echo "$SSH_SERVER_HOSTKEYS" >> ~/.ssh/known_hosts

NOETIC_PACKAGES=$(/bin/ls . | grep ros-noetic);
MELODIC_PACKAGES=$(/bin/ls . | grep ros-melodic);

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

scp -P $REPO_SSH_PORT ./ros-noetic* root@$REPO_SSH_HOST:/repo/incoming/noetic/$COMPONENT_NAME
scp -P $REPO_SSH_PORT ./ros-melodic* root@$REPO_SSH_HOST:/repo/incoming/melodic/$COMPONENT_NAME
ssh -p $REPO_SSH_PORT root@$REPO_SSH_HOST COMPONENT_NAME=$COMPONENT_NAME "repo-process-include melodic $COMPONENT_NAME"
ssh -p $REPO_SSH_PORT root@$REPO_SSH_HOST COMPONENT_NAME=$COMPONENT_NAME "repo-process-include noetic $COMPONENT_NAME"

for DEB_FILE in $NOETIC_PACKAGES; do
  ssh -p $REPO_SSH_PORT root@$REPO_SSH_HOST "rm /repo/incoming/noetic/$COMPONENT_NAME/$DEB_FILE || true"
done
for DEB_FILE in $MELODIC_PACKAGES; do
  ssh -p $REPO_SSH_PORT root@$REPO_SSH_HOST "rm /repo/incoming/melodic/$COMPONENT_NAME/$DEB_FILE || true"
done
