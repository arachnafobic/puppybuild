#!/bin/bash

printUsage() {
  echo "$0 --build=<imagename>|--shell=<imagename> [--iso=<localimage> --devx=<localimage>]"
  echo "   both build and shell cannot be used in 1 command."
  echo "   iso and devx optional only when building,"
  echo "   when specified these images will be used instead off downloading base images."
}

# Grab commandline switches
buildTarget=""
shellTarget=""
while [[ $# -gt 0 ]]
do
  argument="$1"
  case $argument in
    -b) buildTarget="$2"; shift 2;;
    --build=*) buildTarget="${argument#*=}"; shift;;
    -s) shellTarget="$2"; shift 2;;
    --shell=*) shellTarget="${argument#*=}"; shift;;
    -i) isoTarget=`readlink -m "$2"`; shift 2;;
    --iso=*) isoTarget=`readlink -m "${argument#*=}"`; shift;;
    -x) devxTarget=`readlink -m "$2"`; shift 2;;
    --devx=*) devxTarget=`readlink -m "${argument#*=}"`; shift;;
    -*) echo "Unkown argument: \"$argument\""; printUsage; exit 1;;
    *) break;;
  esac
done
leftover="$1"

# puppy linux has to be build inside an existing puppy enviroment.
# for this run_woof needs a puppy iso and devx to use for mounts inside a chroot
# the build script has to either use supplied local files or has to include
# downloads for these, prefferably beeing able to use either.

# check if supplied images are present on the FS.
if [ ! -z $isoTarget ]; then
  if [ ! -f $isoTarget ]; then
    echo "ISO image $isoTarget not found"
    exit 1;
  fi
fi
if [ ! -z $devxTarget ]; then
  if [ ! -f $devxTarget ]; then
    echo "devx image $devxTarget not found"
    exit 1;
  fi
fi

# We can't both build an image and enter the shell for it interactivly.
if [[ ! -z $buildTarget && ! -z $shellTarget ]]; then
  printUsage;
  exit 1;
fi

# Nothing to do without build or shell switches
if [[ -z $buildTarget && -z $shellTarget ]]; then
  printUsage;
  exit 1;
fi

# ready to run the build script.
# this script will activate the chroot by installing, setting up and using run_woof
# afterwards a 2nd script has to exist to run inside this chroot.
# $BUILD_ISO and $BUILD_DEVX are to be used to initialize run_woof if they aren't empty
# download backup steps should exist.
if [[ ! -z $buildTarget && -z $shellTarget ]]; then
  if [ -f ./scripts/$buildTarget-build.sh ] ; then
    echo "Now Running BUILD_ISO=$isoTarget BUILD_DEVX=$devxTarget ./scripts/$buildTarget-build.sh"
    BUILD_ISO=$isoTarget BUILD_DEVX=$devxTarget ./scripts/$buildTarget-build.sh || exit 1
    echo ""
    echo "Images have been made, they are located in:"
    echo "  build/$buildTarget/woof-out_x86_x86_ubuntu_upupbb/woof-output-ictm-upupbb-19.03/"
    echo ""
    echo "You can now run $0 --shell=$buildTarget to access the chroot and make changes/rebuild the isos"
    echo ""
  else
    echo "No script found to build $buildTarget."
  fi
fi

# this script is used when entering an interactive shell inside the chroot for the image.
# it should check to ensure the build phase has been completed first.
if [[ -z $buildTarget && ! -z $shellTarget ]]; then
  if [ -f ./scripts/$shellTarget-shell.sh ] ; then
    echo "Entering chroot enviroment for $shellTarget..."
    ./scripts/$shellTarget-shell.sh || exit 1
    echo ""
    echo "Left chroot enviroment."
  fi
fi
