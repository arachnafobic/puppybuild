#!/bin/bash
BUILD=ictm-upupbb

# This script is suppose to setup run_woof, modify it to be non interactive
# and place everything needed for the actual build phase inside folders that
# can be reached from inside the chroot. Which should be build/$BUILD/.

cd build
if [ ! -d $BUILD ]; then
  mkdir $BUILD
fi
cd $BUILD
if [ ! -d run_woof ]; then
  echo "installing run_woof into $PWD"
  git clone https://github.com/puppylinux-woof-CE/run_woof
fi
cd run_woof
cp -f ../../../customfiles/$BUILD/run_woof.conf .

# If puppybuild.sh was executed with switches for local images, grab them here
# otherwise, download the base images.
if [ ! -f upupbb_19.03.iso ]; then
  if [ ! -z $BUILD_ISO ]; then
    echo "Using local $BUILD_ISO as baseimage"
    cp $BUILD_ISO upupbb_19.03.iso
  else
    echo "Downloading baseimage"
    wget -O upupbb_19.03.iso http://distro.ibiblio.org/puppylinux/puppy-bionic/bionicpup32/bionicpup32-8.0-uefi.iso
  fi
fi
if [ ! -f devx_upupbb_19.03.sfs ]; then
  if [ ! -z $BUILD_DEVX ]; then
    echo "Using local $BUILD_DEVX as base devx"
    cp $BUILD_DEVX devx_upupbb_19.03.sfs
  else
    echo "Downloading devx"
    wget http://distro.ibiblio.org/puppylinux/puppy-bionic/bionicpup32/devx_upupbb_19.03.sfs
  fi
fi

# Modify run_woof so it starts the chroot with a script instead of beeing interactive.
# We keep the original file for use with the --shell option from puppybuild.sh
if [ ! -f run_woof.backup ]; then
  mv run_woof run_woof.backup
  sed 's+/bin/bash -i+/bin/bash -i /root/share/tmp/ictm-upupbb-chroot.sh+g' run_woof.backup > run_woof
  chmod +x run_woof
fi

# bashrc will install woof-ce and setup mounts inside the chroot upon logging into it.
# it has interactive questions however for updating woof-ce if it allready exists.
# Since we want this to be non-interactive, change the input reads to filled out variables.
if [ ! -f bashrc.backup ]; then
  mv bashrc bashrc.backup
  sed 's+^\tread YESNO+\tYESNO=Y+g' bashrc.backup > bashrc.tmp
  sed 's+^\t\tread USERNAME+\t\tUSERNAME=+g' bashrc.tmp > bashrc
  rm -f bashrc.tmp
fi

# Create a tmp folder at the root of the chroot and copy both the chroot build script and
# the contents of customfiles/$BUILD into it.
# Use cp -f so any updates to these files will always overwrite previous copies.
SCRIPT_PATH="`realpath ..`"
APPDIR_PATH="${SCRIPT_PATH%/*/run_woof_helper}"
if [ ! -d $APPDIR_PATH/tmp ]; then
  mkdir $APPDIR_PATH/tmp
fi
cp -f ../../../scripts/ictm-upupbb-chroot.sh $APPDIR_PATH/tmp/.
cp -f ../../../customfiles/$BUILD/* $APPDIR_PATH/tmp/.

# Into the chroot we go.
echo "Setting up and Switching to the chroot for building"
echo "Running: ./run_woof ./upupbb-19.03.iso ./devx_upupbb_19.03.sfs $APPDIR_PATH"
./run_woof ./upupbb_19.03.iso ./devx_upupbb_19.03.sfs $APPDIR_PATH
