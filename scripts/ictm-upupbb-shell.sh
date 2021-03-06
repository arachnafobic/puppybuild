#!/bin/bash
BUILD=ictm-upupbb

notBuild() {
  echo "$BUILD has not been build yet."
}

# Ensure the build process has completed succesfully once.
cd build
if [ ! -d $BUILD ]; then
  notBuild;
  exit 1;
fi
cd $BUILD
if [ ! -d run_woof ]; then
  notBuild;
  exit 1;
fi
if [ ! -d woof-out_x86_x86_ubuntu_upupbb/woof-output-$BUILD-19.03 ]; then
  notBuild;
  exit 1;
fi
cd run_woof

# Determine the iso and devx files.
BUILD_ISO=`ls -1 $BUILD*.iso`
BUILD_DEVX=`ls -1 devx_$BUILD*.sfs`
SCRIPT_PATH="`realpath ..`"
APPDIR_PATH="${SCRIPT_PATH%/*/run_woof_helper}"

# Start the chroot enviroment.
./run_woof.backup $BUILD_ISO $BUILD_DEVX $APPDIR_PATH
