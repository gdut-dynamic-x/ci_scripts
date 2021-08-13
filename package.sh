#!/bin/bash

if [ "$ROS_DISTRO" = "melodic" ]; then
  apt install -y -qq python-bloom dh-make
else
  apt install -y -qq python3-bloom dh-make
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

  lsblk
  mkdir debian

  bloom-generate rosdebian --os-name ubuntu --ros-distro ${ROS_DISTRO}

  if [ $BRANCH_NAME != "master" ]; then
    time=$(date "+%Y%m%d%H%M")

    string=$(sed -n '1p' debian/changelog)
    string=${string/\)/\~$time\)}
    string=${string/ \(/\-$BRANCH_NAME \(}
    sed -i "1c $string" debian/changelog

    sed -i "/^Source/ s/$/\-$BRANCH_NAME/" debian/control
    sed -i "/^Package/ s/$/\-$BRANCH_NAME/" debian/control

    sed -i "/dh_shlibdeps/ s/\/\//\-$BRANCH_NAME\/\//" debian/rules
  fi

  ls -l .
  
  debian/rules binary 
}

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
