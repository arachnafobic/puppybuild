#!/bin/bash

printUsage() {
  echo "./puppybuild --build=<imagename>|--interactive=<imagename>"
  echo "   both cannot be used in 1 command"
}

buildTarget=""
interTarget=""
while [[ $# -gt 0 ]]
do
  argument="$1"
  case $argument in
    -b) buildTarget="$2"; shift 2;;
    --build=*) buildTarget="${argument#*=}"; shift;;
    -i) interTarget="$2"; shift 2;;
    --interactive=*) interTarget="${argument#*=}"; shift;;
    -*) echo "Unkown argument: \"$argument\""; printUsage; exit 1;;
    *) break;;
  esac
done
leftover="$1"

if [[ ! -z $buildTarget && ! -z $interTarget ]]; then
  printUsage;
  exit 1;
fi

if [[ ! -z $buildTarget && -z $interTarget ]]; then
  if [ -f ./scripts/$buildTarget-build.sh ] ; then
    echo "Now Running ./scripts/$buildTarget-build.sh"
    ./scripts/$buildTarget-build.sh || exit 1
    echo ""
    echo "Images have been made, they are located in:"
    echo "  build/$buildTarget/woof-out_x86_x86_ubuntu_upupbb/woof-output-ictm-upupbb-19.03/"
    echo ""
    echo "You can now run $0 --interactive=$buildTarget to access the chroot and make changes/rebuild the isos"
    echo ""
  else
    echo "No script found to build $buildTarget."
  fi
fi

if [[ -z $buildTarget && ! -z $interTarget ]]; then
  if [ -f ./scripts/$interTarget-interactive.sh ] ; then
    echo "Entering chroot enviroment for $interTarget..."
    ./scripts/$interTarget-interactive.sh || exit 1
    echo ""
    echo "Left chroot enviroment."
  fi
fi
