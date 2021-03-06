#!/bin/bash
BUILD=ictm-upupbb

echo "Working inside chroot now"

# Woof-CE has been downloaded allready thanks to run_woof's bashrc.
# However, we need to make it non-interactive by replace all input checks
# with filled in variables.
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

# Copy a filled out DISTRO_SPECS to the build folder.
if [ ! -f DISTRO_SPECS.orig ]; then
  mv DISTRO_SPECS DISTRO_SPECS.orig
fi
cp -f ../tmp/DISTRO_SPECS .

# Run 0setup
# This will add the distributions package lists to the folder.
if [ ! -f .0setup.runsuccesfull ]; then
  ./0setup
  touch .0setup.runsuccesfull
fi

# Adjust DISTRO_PKGS_SPECS-ubuntu-bionic to activate/deactivate and add
# software to our liking.
# For this image specificly :
#  - We don't want pmcputemp and sudoku_slitaz
#  - We want nano and chromium-browser
if [ ! -f DISTRO_PKGS_SPECS-ubuntu-bionic.orig ]; then
  mv DISTRO_PKGS_SPECS-ubuntu-bionic DISTRO_PKGS_SPECS-ubuntu-bionic.orig
  sed 's+^yes|pmcputemp||exe,dev,doc,nls+no|pmcputemp||exe,dev,doc,nls+g' DISTRO_PKGS_SPECS-ubuntu-bionic.orig > DISTRO_PKGS_SPECS-ubuntu-bionic.tmp1
  sed 's+^yes|sudoku_slitaz||exe+no|sudoku_slitaz||exe+g' DISTRO_PKGS_SPECS-ubuntu-bionic.tmp1 > DISTRO_PKGS_SPECS-ubuntu-bionic.tmp2
  sed '/yes|nas|.*/iyes|nano|nano|exe' DISTRO_PKGS_SPECS-ubuntu-bionic.tmp2 > DISTRO_PKGS_SPECS-ubuntu-bionic.tmp3
  sed '/yes|cifs-utils|.*/iyes|chromium-browser|chromium-browser|exe\nyes|chromium-codecs-ffmpeg|chromium-codecs-ffmpeg|exe' DISTRO_PKGS_SPECS-ubuntu-bionic.tmp3 > DISTRO_PKGS_SPECS-ubuntu-bionic
  rm -f DISTRO_PKGS_SPECS-ubuntu-bionic.tmp1 DISTRO_PKGS_SPECS-ubuntu-bionic.tmp2 DISTRO_PKGS_SPECS-ubuntu-bionic.tmp3
fi

# libedit2_3.1-20170329-1_i386.deb specificly stalls when downloading at 91% on nearly every mirror
# To avoid issues, we supply a local copy here instead, so it will be skipped during the
# download phase.
if [ ! -f ../local-repositories/x86/packages-deb-bionic/libedit2_3.1-20170329-1_i386.deb ]; then
  cp ../tmp/libedit2_3.1-20170329-1_i386.deb ../local-repositories/x86/packages-deb-bionic/
fi

# Download all required packages.
if [ ! -f .1download.runsuccesfull ]; then
  ./1download
  touch .1download.runsuccesfull
fi

# Run setups for all packages.
if [ ! -f .2createpackages.runsuccesfull ]; then
  ./2createpackages -all
  touch .2createpackages.runsuccesfull
fi

# Copy all our file replacements to their respective locations
# Be sure to use cp -f so later runs will use updated files.
cp -f ../tmp/ubb-default.png packages-$BUILD/z_upupbbfix/usr/share/backgrounds/
cp -f ../tmp/upup-hints.txt packages-$BUILD/z_upupbbfix/opt/upup/
cp -f ../tmp/globicons packages-$BUILD/z_upupbbfix/root/.config/rox.sourceforge.net/ROX-Filer/
cp -f ../tmp/pb_Default packages-$BUILD/z_upupbbfix/root/.config/rox.sourceforge.net/ROX-Filer/
cp -f ../tmp/defaultbrowser rootfs-skeleton/usr/local/bin/
cp -f ../tmp/delayedrun rootfs-skeleton/usr/sbin/

if [ ! -f .sed_done ]; then
  # We're using chromium as default browser, so disable light.
  sed -i 's+^defaultbrowser=light+defaultbrowser=+g' _00build.conf
  # We want a custom desktop (pinboard), rox needs to activate this during xinit.
  sed -i '/^which $CURRENTWM && exec $CURRENTWM/i # Activate ICTM Desktop\nrox --pinboard Default\n' rootfs-skeleton/root/.xinitrc
  touch .sed_done
fi

# This image is intended to be used primarily in the netherlands,
# so we're making Amsterdam the default timezone.
cd rootfs-skeleton/etc
rm -f localtime
ln -s /usr/share/zoneinfo/Europe/Amsterdam localtime
cd ../..

# Originally, the build system only makes either an UEFI iso when it detects efi.img
# in the file system, otherwise it falls back to legacy.
# We want to create both, so a modified mk_iso.sh is supplied which adds switches for this.
if [ ! -f support/mk_iso.sh.orig ]; then
  mv support/mk_iso.sh support/mk_iso.sh.orig
fi
cp -f ../tmp/mk_iso.sh support/

# 3builddistro needs to be adjusted to call mk_iso.sh with our switches.
if [ ! -f 3builddistro.backup ]; then
  mv 3builddistro 3builddistro.backup
  sed 's+^\techo "Running ../support/mk_iso.sh"+\techo "Running ../support/mk_iso.sh --uefi"+g' 3builddistro.backup > 3builddistro.tmp1
  sed 's+^\t../support/mk_iso.sh || exit 1+\t../support/mk_iso.sh --uefi || exit 1+g' 3builddistro.tmp1 > 3builddistro.tmp2
  sed '/^\t..\/support\/mk_iso.sh --uefi.*/a\\techo "Running ..\/support\/mk_iso.sh --without-uefi"' 3builddistro.tmp2 > 3builddistro.tmp3
  sed '/echo "Running ..\/support\/mk_iso.sh --without-uefi"/a\\t..\/support\/mk_iso.sh --without-uefi || exit 1' 3builddistro.tmp3 > 3builddistro
  rm -f 3builddistro.tmp1 3builddistro.tmp2 3builddistro.tmp3
  chmod +x 3builddistro
fi

# When everything is in place, make the image.
# afterwards, copy them to run_woof
# puppylinux.sh's shell switch will use these for the
# enviroment instead of the original base images
if [ ! -f .3builddistro.runsuccesfull ]; then
  rm -Rf sandbox3 woof-output-$BUILD-19.03
  ./3builddistro
  cp -f woof-output-$BUILD-19.03/*.sfs ../run_woof/
  cp -f woof-output-$BUILD-19.03/*[0-9][\.]iso ../run_woof/
  touch .3builddistro.runsuccesfull
fi
