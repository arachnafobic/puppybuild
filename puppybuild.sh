#!/bin/bash

printUsage() {
  echo "./puppybuild --build=<imagename>"
}

while [[ $# -gt 0 ]]
do
  argument="$1"
  case $argument in
    -b) buildTarget="$2"; shift 2;;
    --build=*) buildTarget="${argument#*=}"; shift;;
    -*) echo "Unkown argument: \"$argument\""; printUsage; exit 1;;
    *) break;;
  esac
done

leftover="$1"
# echo buildTarget $buildTarget
# echo appsDir $appsDir
# echo no-op args: $@

if [ -f ./scripts/$buildTarget.sh ] ; then
  echo "Now Running ./scripts/$buildTarget.sh"
  ./scripts/$buildTarget.sh
else
  echo "No script found to build $buildTarget."
fi
