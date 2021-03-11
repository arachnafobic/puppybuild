#!/bin/bash
BUILD=ictm-upupbb

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
if [ ! -f run_woof.conf ]; then
  cp ../../../customfiles/$BUILD/run_woof.conf .
fi
if [ ! -f upupbb_19.03.iso ]; then
  echo "Downloading baseimage"
  wget -O upupbb_19.03.iso http://distro.ibiblio.org/puppylinux/puppy-bionic/bionicpup32/bionicpup32-8.0-uefi.iso
fi
if [ ! -f devx_upupbb_19.03.sfs ]; then
  echo "Downloading devx"
  wget http://distro.ibiblio.org/puppylinux/puppy-bionic/bionicpup32/devx_upupbb_19.03.sfs
fi

if [ ! -f run_woof.backup ]; then
  mv run_woof run_woof.backup
  sed 's+/bin/bash -i+/bin/bash -i /root/share/tmp/ictm-upupbb-chroot.sh+g' run_woof.backup > run_woof
  chmod +x run_woof
fi
if [ ! -f bashrc.backup ]; then
  mv bashrc bashrc.backup
  sed 's+^\tread YESNO+\tYESNO=Y+g' bashrc.backup > bashrc.tmp
  sed 's+^\t\tread USERNAME+\t\tUSERNAME=+g' bashrc.tmp > bashrc
  rm -f bashrc.tmp
fi
SCRIPT_PATH="`realpath ..`"
APPDIR_PATH="${SCRIPT_PATH%/*/run_woof_helper}"
if [ ! -d $APPDIR_PATH/tmp ]; then
  mkdir $APPDIR_PATH/tmp
fi
cp -f ../../../scripts/ictm-upupbb-chroot.sh $APPDIR_PATH/tmp/.
cp -f ../../../customfiles/$BUILD/* $APPDIR_PATH/tmp/.

echo "Setting up and Switching to the chroot for building"
echo "Running: ./run_woof ./upupbb-19.03.iso ./devx_upupbb_19.03.sfs $APPDIR_PATH"
./run_woof ./upupbb_19.03.iso ./devx_upupbb_19.03.sfs $APPDIR_PATH
