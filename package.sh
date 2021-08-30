#!/bin/bash

if [ "$ROS_DISTRO" = "melodic" ]; then
  apt install -y -qq python-bloom dh-make tree > /dev/null
else
  apt install -y -qq python3-bloom dh-make tree > /dev/null
fi

run_package()
{
  if [ -z $1 ]; then
    BRANCH_NAME="master"
  else
    BRANCH_NAME=$1
  fi
  BRANCH_NAME="${BRANCH_NAME/_/-}"
  BRANCH_NAME="${BRANCH_NAME/\//-}"
  echo "$BRANCH_NAME"

  bloom-generate rosdebian --os-name ubuntu --ros-distro ${ROS_DISTRO}

  time=$(date "+%Y%m%d%H%M")

  string=$(sed -n '1p' debian/changelog)
  string=${string/\)/\~$time\)}
  
  if [ $BRANCH_NAME == "master" ]; then
    sed -i "1c $string" debian/changelog
  else
    string=${string/ \(/\-$BRANCH_NAME \(}
    sed -i "1c $string" debian/changelog

    sed -i "/^Source/ s/$/\-$BRANCH_NAME/" debian/control
    sed -i "/^Package/ s/$/\-$BRANCH_NAME/" debian/control

    sed -i "/dh_shlibdeps/ s/\/\//\-$BRANCH_NAME\/\//" debian/rules
  fi

  debian/rules binary 
}

echo "="
ls $BASEDIR/target_ws/src
echo "=="
ls $BASEDIR/target_ws/devel/share
ls $BASEDIR/target_ws/devel
tree $BASEDIR/target_ws/devel
echo "==="
source /opt/ros/${ROS_DISTRO}/setup.bash
source ${BASEDIR}/target_ws/devel/local_setup.bash
source ${BASEDIR}/target_ws/devel/setup.bash
echo "---"
env
echo "---"
if [ -z $2 ]; then
  echo "Single Package Mode"
  run_package
  cp ../ros-${ROS_DISTRO}* ./
else
  echo "Multi Package Mode"

  for x in $(ls .)
  do
    if [ -d "$x" ]; then
      cd $x
      run_package
      cd ..
    fi
  done
fi
