#!/bin/bash
# simple bash script for executing build

# root directory of NetHunter Mipad1[mocha] git repo (default is this script's location)
RDIR=$(pwd)

[ "$VER" ] ||
# version number
VER=$(cat "$RDIR/VERSION")

# directory containing cross-compile arm toolchain
TOOLCHAIN=$RDIR/../toolchain
CCACHE=$RDIR/../ccache
zImage=$RDIR/build/arch/arm/boot/zImage
CPU_THREADS=$(grep -c "processor" /proc/cpuinfo)
# amount of cpu threads to use in kernel make process
THREADS=$((CPU_THREADS + 1))
# directory cloning cross-compile arm toolchain

 if [ -d $TOOLCHAIN ] ; then
   echo "You have already toolchain..."
 else
  git clone https://github.com/RahulTheVirus/toolchain-4.X.git $TOOLCHAIN
  sudo find toolchain -type f -exec chmod a+rwx {} \;
  
 fi
############## SCARY NO-TOUCHY STUFF ###############

ABORT()
{
	[ "$1" ] && echo "Error: $*"
	exit 1
}

export ARCH=arm
export CROSS_COMPILE=$TOOLCHAIN/bin/arm-linux-gnueabihf-
export USE_CCACHE=1
export CCACHE_DIR=$CCACHE

[ -x "${CROSS_COMPILE}gcc" ] ||
ABORT "Unable to find gcc cross-compiler at location: ${CROSS_COMPILE}gcc"

[ "$TARGET" ] || TARGET=nethunter
[ "$1" ] && DEVICE=$1
[ "$DEVICE" ] || DEVICE=mocha

DEFCONFIG=${TARGET}_${DEVICE}_defconfig

[ -f "$RDIR/arch/$ARCH/configs/${DEFCONFIG}" ] ||
ABORT "Config $DEFCONFIG not found in $ARCH configs!"

export LOCALVERSION=-V$VER-$DEVICE

CLEAN_BUILD()
{
	echo "Cleaning build.."
	$RDIR/cleanup.sh
	echo " Done ! "

}

SETUP_BUILD()
{
	echo "Creating kernel config for $LOCALVERSION..."
	mkdir -p build
	if [ -d $CCACHE ] ; then
   echo "You have already ccache..."
  else 
	mkdir -p $CCACHE
	
fi
	
	make -C "$RDIR" O=build "$DEFCONFIG" \
		|| ABORT "Failed to set up build"
}

BUILD_KERNEL()
{
	echo "Starting build for $LOCALVERSION..."
	while ! make -C "$RDIR" O=build -j"$THREADS"; do
		read -rp "Build failed. Retry? " do_retry
		case $do_retry in
			Y|y) continue ;;
			*) return 1 ;;
		esac
	done
}

INSTALL_MODULES() {
	echo "Installing kernel modules to build/lib/modules..."
	make -C "$RDIR" O=build \
		INSTALL_MOD_PATH="." \
		INSTALL_MOD_STRIP=1 \
		modules_install
	rm build/lib/modules/*/build build/lib/modules/*/source
}

    CLEAN_BUILD &&
    SETUP_BUILD &&
    BUILD_KERNEL &&
    INSTALL_MODULES &&
echo "Finished building $LOCALVERSION!"

if [ -f $zImage ] ; then
   echo " "
   echo " "
   echo " Please  "
   echo " "
   echo " Collect zImage from build/arch/arm/boot"
   echo " "
   echo " Collect modules & firmware from build/lib"
   echo " "
   echo " You Can connect us on https://t.me/mipad1 "
   echo " "
   echo "                          Thanks& Regards! "
   echo "                            RahulTheVirus! "
   echo " "
else
    echo " "
    echo "Please Review & Fix the errors"
    echo " "
    echo "And try again.."
    echo " "
    echo " You Can connect us on https://t.me/mipad1 "
    echo " "
    echo "                          Thanks& Regards! "
    echo "                            RahulTheVirus! "
    echo " "

 fi
   
