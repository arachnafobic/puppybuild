#!/bin/bash
BUILD=ictm-upupbb

echo "Working inside chroot now"

cd woof-CE
if [ ! -f merge2out.backup ]; then
  mv merge2out merge2out.backup
  sed 's+^\tread nTARGETARCH+\tnTARGETARCH=2+g' merge2out.backup > merge2out.tmp1
  sed 's+^\tread nCOMPATDISTRO+\tnCOMPATDISTRO=3+g' merge2out.tmp1 > merge2out.tmp2
  sed 's+^\tread nCOMPATVERSION+\tnCOMPATVERSION=2+g' merge2out.tmp2 > merge2out.tmp3
  sed 's+^read waitforit++g' merge2out.tmp3 > merge2out.tmp4
  sed 's+^read goforit++g' merge2out.tmp4 > merge2out
  chmod +x merge2out
  rm -f merge2out.tmp1 merge2out.tmp2 merge2out.tmp3 merge2out.tmp4
fi
if [ ! -d ../woof-out_x86_x86_ubuntu_upupbb ]; then
  ./merge2out
else
  echo "Previous merge detected, skipping..."
  echo "Remove build/$BUILD/woof-out_x86_x86_ubuntu_upupbb/ to remerge"
fi
cd ../woof-out_x86_x86_ubuntu_upupbb
if [ ! -f DISTRO_SPECS.orig ]; then
  mv DISTRO_SPECS DISTRO_SPECS.orig
  cp ../tmp/DISTRO_SPECS .
fi
if [ ! -f .0setup.runsuccesfull ]; then
  ./0setup
  touch .0setup.runsuccesfull
fi
if [ ! -f DISTRO_PKGS_SPECS-ubuntu-bionic.orig ]; then
  mv DISTRO_PKGS_SPECS-ubuntu-bionic DISTRO_PKGS_SPECS-ubuntu-bionic.orig
  sed 's+^yes|pmcputemp||exe,dev,doc,nls+no|pmcputemp||exe,dev,doc,nls+g' DISTRO_PKGS_SPECS-ubuntu-bionic.orig > DISTRO_PKGS_SPECS-ubuntu-bionic.tmp1
  sed 's+^yes|sudoku_slitaz||exe+no|sudoku_slitaz||exe+g' DISTRO_PKGS_SPECS-ubuntu-bionic.tmp1 > DISTRO_PKGS_SPECS-ubuntu-bionic.tmp2
  sed '/yes|nas|.*/iyes|nano|nano|exe' DISTRO_PKGS_SPECS-ubuntu-bionic.tmp2 > DISTRO_PKGS_SPECS-ubuntu-bionic.tmp3
  sed '/yes|cifs-utils|.*/iyes|chromium-browser|chromium-browser|exe\nyes|chromium-codecs-ffmpeg|chromium-codecs-ffmpeg|exe' DISTRO_PKGS_SPECS-ubuntu-bionic.tmp3 > DISTRO_PKGS_SPECS-ubuntu-bionic
  rm -f DISTRO_PKGS_SPECS-ubuntu-bionic.tmp1 DISTRO_PKGS_SPECS-ubuntu-bionic.tmp2 DISTRO_PKGS_SPECS-ubuntu-bionic.tmp3
fi
if [ ! -f ../local-repositories/x86/packages-deb-bionic/libedit2_3.1-20170329-1_i386.deb ]; then
  cd ../tmp/
  wget http://nl.archive.ubuntu.com/ubuntu/pool/main/libe/libedit/libedit2_3.1-20170329-1_i386.deb
  mv libedit2_3.1-20170329-1_i386.deb ../local-repositories/x86/packages-deb-bionic/
  cd ../woof-out_x86_x86_ubuntu_upupbb
fi
#if [ ! -f .1download.runsuccesfull ]; then
#  ./1download
#  touch .1download.runsuccesfull
#fi
#if [ ! -f .2createpackages.runsuccesfull ]; then
#  ./2createpackages
#  touch .2createpackages.runsuccesfull
#fi
