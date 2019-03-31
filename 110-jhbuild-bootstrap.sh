#!/usr/bin/env bash
# 030-jhbuild-bootstrap.sh
# https://github.com/dehesselle/mibap
#
# Bootstrap the jhbuild environment.

SELF_DIR=$(cd $(dirname "$0"); pwd -P)
source $SELF_DIR/010-vars.sh

### create ramdisk as workspace ################################################

# FIXME: ejecting disk is not reliable
# This part will be reworked soon to make ramdisk usage optional.
diskutil eject $(diskutil info $RAMDISK | head -n 1 | awk '{ print $3 }')
diskutil erasevolume HFS+ "$RAMDISK" $(hdiutil attach -nomount ram://$(expr $RAMDISK_SIZE \* 1024 \* 2048))

### setup path #################################################################

# WARNING: Operations like this are the reason that you're supposed to use
# a dedicated machine for building. This script does not care for your
# data.
echo "export PATH=$BIN_DIR:/usr/bin:/bin:/usr/sbin:/sbin" > ~/.profile
source ~/.profile

### setup directories for jhbuild ##############################################

mkdir -p $TMP_DIR
mkdir -p $SRC_DIR/checkout     # extracted tarballs
mkdir -p $SRC_DIR/download     # downloaded tarballs

# WARNING: Operations like this are the reason that you're supposed to use
# a dedicated machine for building. This script does not care for your
# data.
rm -rf ~/.cache ~/.local ~/Source   # remove remnants of previous run
ln -sf $TMP_DIR ~/.cache   # link to our workspace
ln -sf $OPT_DIR ~/.local   # link to our workspace
ln -sf $SRC_DIR ~/Source   # link to our workspace

### install and configure jhbuild ##############################################

cd $WRK_DIR
bash <(curl -s $URL_GTK_OSX_BUILD_SETUP)   # run jhbuild setup script

JHBUILDRC=$HOME/.jhbuildrc-custom
if [ -f $JHBUILDRC ]; then   # remove previous configuration from end of file
  LINE_NO=$(grep -n "# And more..." $JHBUILDRC | awk -F ":" '{ print $1 }')
  head -n +$LINE_NO $JHBUILDRC >$JHBUILDRC.clean
  mv $JHBUILDRC.clean $JHBUILDRC
  unset LINE_NO
fi

# configure jhbuild
echo "checkoutroot = '$SRC_DIR/checkout'" >> $JHBUILDRC
echo "prefix = '$OPT_DIR'" >> $JHBUILDRC
echo "tarballdir = '$SRC_DIR/download'" >> $JHBUILDRC
echo "quiet_mode = True" >> $JHBUILDRC    # suppress all build output
echo "progress_bar = True" >> $JHBUILDRC
echo "moduleset = '$URL_GTK_OSX_MODULESET'" >> $JHBUILDRC

### bootstrap jhbuild environment ##############################################

jhbuild bootstrap