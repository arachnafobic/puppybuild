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
./merge2out
