#!/bin/bash

#########################################################
#########################################################
#      						 	#
# 	  Copyright (c) 2016, Nachiket.Namjoshi	      	#
# 			 All rights reserved.	      	#
# 						        #
#       	Whyred Kernel Build Script 	        #
#########################################################
#########################################################

#For Time Calculation
BUILD_START=$(date +"%s")

# Housekeeping
blue='\033[0;34m'
cyan='\033[0;36m'
green='\033[1;32m'
red='\033[0;31m'
nocol='\033[0m'

#
# Configure following according to your system
#

# Directories
ANYKERNEL_DIR="../AnyKernel2"
OUT_DIR="obj"
KERN_IMG=$PWD/$OUT_DIR/arch/arm64/boot/Image.gz-dtb
Whyred_VERSION="Alpha"

# Device Spceifics
export KBUILD_BUILD_USER="Subhrajyoti"
export KBUILD_BUILD_HOST="Beast"

########################
## Start Build Script ##
########################

# Remove Last builds
rm -rf $ANYKERNEL_DIR/*.zip
rm -rf $ANYKERNEL_DIR/Image.gz-dtb

compile_kernel ()
{
echo -e "$green ********************************************************************************************** $nocol"
echo "                    "
echo "                                   Compiling Whyred-Kernel                    "
echo "                    "
echo -e "$green ********************************************************************************************** $nocol"
make clean O=$OUT_DIR && make mrproper O=$OUT_DIR
make whyred_defconfig O=$OUT_DIR ARCH=arm64
make -j$(nproc --all) O=$OUT_DIR \
                      ARCH=arm64 \
		      CC="$HOME/clang/bin/clang" \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
		      CROSS_COMPILE="$HOME/gcc/bin/aarch64-linux-android-"


if ! [ -a $KERN_IMG ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
zipping
}

zipping() {

# make new zip
cp $KERN_IMG $ANYKERNEL_DIR/Image.gz-dtb
cd $ANYKERNEL_DIR
zip -r Heliox-whyred-$Whyred_VERSION-$(date +"%Y%m%d")-$(date +"%H%M%S").zip *

}

compile_kernel
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$blue Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
echo -e "$red zImage size (bytes): $(stat -c%s $KERN_IMG) $nocol"

