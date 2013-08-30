#!/bin/bash

echo "Generator for a simple initramfs root filesystem for some ARM targets"
CURDIR=`pwd`
STAGEDIR=${CURDIR}/stage
BUILDDIR=${CURDIR}/build
#ARM_CC_DIR=${CURDIR}/arm-2010q1
#ARM_CC_DIR=${CURDIR}/gcc-linaro-arm-linux-gnueabihf-2012.05-20120523_linux
ARM_CC_DIR=/var/linus/gcc-linaro-arm-linux-gnueabihf-4.8-2013.08_linux
#ARM_CC_PREFIX=arm-none-linux-gnueabi
#ARM_CC_PREFIX=arm-linux-gnueabi
ARM_CC_PREFIX=arm-linux-gnueabihf
ARM_STRIP=${ARM_CC_PREFIX}-strip
I486_CC_DIR=${CURDIR}/cross-compiler-i486
I486_CC_PREFIX=i486
I486_STRIP=${I486_CC_PREFIX}-strip
I586_CC_DIR=${CURDIR}/cross-compiler-i586
I586_CC_PREFIX=i586
I586_STRIP=${I586_CC_PREFIX}-strip
STRACEVER=strace-4.7
STRACE=${CURDIR}/${STRACEVER}

# Helper function to copy one level of files and then one level
# of links from a directory to another directory.
function clone_dir()
{
    SRCDIR=$1
    DSTDIR=$2
    FILES=`find ${SRCDIR} -maxdepth 1 -type f`
    for file in ${FILES} ; do
	BASE=`basename $file`
	cp $file ${DSTDIR}/${BASE}
	# ${STRIP} -s ${DSTDIR}/${BASE}
    done;
    # Clone links from the toolchain binary library dir
    LINKS=`find ${SRCDIR} -maxdepth 1 -type l`
    cd ${DSTDIR}
    for file in ${LINKS} ; do
	BASE=`basename $file`
	TARGET=`readlink $file`
	ln -s ${TARGET} ${BASE}
    done;
    cd ${CURDIR}
}

case $1 in
    "i486")
	echo "Building Intel i486 root filesystem"
	export ARCH=i486
	LIBCBASE=${I486_CC_DIR}
	CC_DIR=${I486_CC_DIR}
	CC_PREFIX=${I486_CC_PREFIX}
	STRIP=${I486_STRIP}
	CFLAGS="-march=i486 -mtune=i486 -m32"
	cp etc/inittab-pc etc/inittab
	echo "i486" > etc/hostname
	OUTFILE=${HOME}/rootfs-i486.cpio
	;;
    "i586")
	echo "Building Intel i586 Pentium root filesystem"
	export ARCH=i586
	LIBCBASE=${I586_CC_DIR}
	CC_DIR=${I586_CC_DIR}
	CC_PREFIX=${I586_CC_PREFIX}
	STRIP=${I586_STRIP}
	# Skip -mtune pentium-mmx for generic Pentium image
	CFLAGS="-march=i586 -mtune=pentium-mmx -m32"
	cp etc/inittab-pc etc/inittab
	echo "i586" > etc/hostname
	OUTFILE=${HOME}/rootfs-i586.cpio
	;;
    "integrator")
	echo "Building Integrator ARMv4 root filesystem"
	export ARCH=arm
	# Use ARMv4T base for Integrator rootfs builds
	LIBCBASE=${ARM_CC_DIR}/${ARM_CC_PREFIX}/libc/armv4t
	CC_DIR=${ARM_CC_DIR}
	CC_PREFIX=${ARM_CC_PREFIX}
	STRIP=${ARM_STRIP}
	CFLAGS="-msoft-float -marm -mabi=aapcs-linux -mthumb -mthumb-interwork -march=armv4t -mtune=arm9tdmi"
	cp etc/inittab-integrator etc/inittab
	echo "integrator" > etc/hostname
	OUTFILE=${HOME}/rootfs-integrator.cpio
	# Splash image for VGA console
	echo "file /etc/splash.ppm etc/splash-640x480-rgba5551.ppm 644 0 0" >> filelist-final.txt
	;;
    "msm8660")
	echo "Building Qualcomm MSM8660 root filesystem"
	export ARCH=arm
	LIBCBASE=${ARM_CC_DIR}/${ARM_CC_PREFIX}/libc
	CC_DIR=${ARM_CC_DIR}
	CC_PREFIX=${ARM_CC_PREFIX}
	STRIP=${ARM_STRIP}
	CFLAGS="-msoft-float -marm -mabi=aapcs-linux -mthumb -mthumb-interwork -march=armv5t -mtune=arm9tdmi"
	cp etc/inittab-msm8660 etc/inittab
	echo "Ux500" > etc/hostname
	OUTFILE=${HOME}/rootfs-msm8660.cpio
	;;
    "nhk8815")
	echo "Building Nomadik NHK8815 root filesystem"
	export ARCH=arm
	LIBCBASE=${ARM_CC_DIR}/${ARM_CC_PREFIX}/libc
	CC_DIR=${ARM_CC_DIR}
	CC_PREFIX=${ARM_CC_PREFIX}
	STRIP=${ARM_STRIP}
	CFLAGS="-msoft-float -marm -mabi=aapcs-linux -mthumb -mthumb-interwork -march=armv5t -mtune=arm9tdmi"
	cp etc/inittab-nhk8815 etc/inittab
	echo "NHK8815" > etc/hostname
	OUTFILE=${HOME}/rootfs-nhk8815.cpio
	;;
    "u300")
	echo "Building ST-Ericsson U300 root filesystem"
	export ARCH=arm
	LIBCBASE=${ARM_CC_DIR}/${ARM_CC_PREFIX}/libc
	CC_DIR=${ARM_CC_DIR}
	CC_PREFIX=${ARM_CC_PREFIX}
	STRIP=${ARM_STRIP}
	CFLAGS="-msoft-float -marm -mabi=aapcs-linux -mthumb -mthumb-interwork -march=armv5t -mtune=arm9tdmi"
	cp etc/inittab-u300 etc/inittab
	echo "U300" > etc/hostname
	OUTFILE=${HOME}/rootfs-u300.cpio
	;;
    "ux500")
	echo "Building ST-Ericsson Ux500 root filesystem"
	export ARCH=arm
	LIBCBASE=${ARM_CC_DIR}/${ARM_CC_PREFIX}/libc
	CC_DIR=${ARM_CC_DIR}
	CC_PREFIX=${ARM_CC_PREFIX}
	STRIP=${ARM_STRIP}
	CFLAGS="-marm -mabi=aapcs-linux -mthumb -mthumb-interwork -mcpu=cortex-a9"
	cp etc/inittab-ux500 etc/inittab
	echo "Ux500" > etc/hostname
	OUTFILE=${HOME}/rootfs-ux500.cpio
	;;
    "versatile")
	echo "Building ARM Versatile root filesystem"
	export ARCH=arm
	LIBCBASE=${ARM_CC_DIR}/${ARM_CC_PREFIX}/libc
	CC_DIR=${ARM_CC_DIR}
	CC_PREFIX=${ARM_CC_PREFIX}
	STRIP=${ARM_STRIP}
	CFLAGS="-msoft-float -marm -mabi=aapcs-linux -mthumb -mthumb-interwork -march=armv5t -mtune=arm9tdmi"
	cp etc/inittab-versatile etc/inittab
	echo "Versatile" > etc/hostname
	OUTFILE=${HOME}/rootfs-versatile.cpio
	;;
    *)
	echo "Usage: $0 [i486|integrator|msm8660|nhk8815|u300|ux500|versatile]"
	exit 1
	;;
esac
echo "OUTFILE = ${OUTFILE}"

echo "Check prerequisites..."
echo "Set up cross compiler at: ${CC_DIR}"
export PATH="$PATH:${CC_DIR}/bin"
echo -n "Check crosscompiler ... "
which ${CC_PREFIX}-gcc > /dev/null ; if [ ! $? -eq 0 ] ; then
    echo "ERROR: cross-compiler ${CC_PREFIX}-gcc not in PATH=$PATH!"
    echo "ABORTING."
    exit 1
else
    echo "OK"
fi

echo -n "gen_init_cpio ... "
which gen_init_cpio > /dev/null ; if [ ! $? -eq 0 ] ; then
    echo "ERROR: gen_init_cpio not in PATH=$PATH!"
    echo "Copy this binary from the Linux build tree."
    echo "Or set your PATH into the Linux kernel tree, I don't care..."
    echo "ABORTING."
    exit 1
else
    echo "OK"
fi

# Clone the busybox git if we don't have it...
if [ ! -d busybox ] ; then
    echo "It appears we're missing a busybox git, cloning it."
    git clone git://busybox.net/busybox.git busybox
    if [ ! -d busybox ] ; then
	echo "Failed. ABORTING."
	exit 1
    fi
fi

# Copy the template of static files to be used
cp filelist.txt filelist-final.txt

# Prep dirs
if [ -d ${STAGEDIR} ] ; then
    echo "Scrathing old ${STAGEDIR}"
    rm -rf ${STAGEDIR}
fi
if [ -d ${BUILDDIR} ] ; then
    echo "Scrathing old ${BUILDDIR}"
    rm -rf ${BUILDDIR}
fi
mkdir ${STAGEDIR}
mkdir ${STAGEDIR}/lib
mkdir ${STAGEDIR}/sbin
mkdir ${BUILDDIR}

# For using the git version
cd busybox
make O=${BUILDDIR} defconfig
echo "Configuring cross compiler etc..."
# Comment in this line to create a statically linked busybox
#sed -i "s/^#.*CONFIG_STATIC.*/CONFIG_STATIC=y/" ${BUILDDIR}/.config
sed -i -e "s/CONFIG_CROSS_COMPILER_PREFIX=\"\"/CONFIG_CROSS_COMPILER_PREFIX=\"${CC_PREFIX}-\"/g" ${BUILDDIR}/.config
sed -i -e "s/CONFIG_EXTRA_CFLAGS=\"\"/CONFIG_EXTRA_CFLAGS=\"${CFLAGS}\"/g" ${BUILDDIR}/.config
sed -i -e "s/CONFIG_PREFIX=\".*\"/CONFIG_PREFIX=\"..\/stage\"/g" ${BUILDDIR}/.config
#make O=${BUILDDIR} menuconfig
make O=${BUILDDIR}
make O=${BUILDDIR} install
cd ${CURDIR}

# First the flat library where arch-independent stuff will
# end up
clone_dir ${LIBCBASE}/lib ${STAGEDIR}/lib

# The C library may be in a per-arch subdir (multiarch)
# OR it may not...
if [ -d ${LIBCBASE}/lib/${ARM_CC_PREFIX} ] ; then
    mkdir -p ${STAGEDIR}/lib/${ARM_CC_PREFIX}
    echo "dir /lib/${ARM_CC_PREFIX} 755 0 0" >> filelist-final.txt
    clone_dir ${LIBCBASE}/lib/${ARM_CC_PREFIX} ${STAGEDIR}/lib/${ARM_CC_PREFIX}
fi

# Add files by searching stage directory
BINFILES=`find ${STAGEDIR}/bin -maxdepth 1 -type f`
for file in ${BINFILES} ; do
    BASE=`basename $file`
    echo "file /bin/${BASE} $file 755 0 0" >> filelist-final.txt
done;
SBINFILES=`find ${STAGEDIR}/sbin -maxdepth 1 -type f`
for file in ${SBINFILES} ; do
    BASE=`basename $file`
    echo "file /sbin/${BASE} $file 755 0 0" >> filelist-final.txt
done;
LIBFILES=`find ${STAGEDIR}/lib -maxdepth 1 -type f`
for file in ${LIBFILES} ; do
    BASE=`basename $file`
    echo "file /lib/${BASE} $file 755 0 0" >> filelist-final.txt
done;
LIBLINKS=`find ${STAGEDIR}/lib -maxdepth 1 -type l`
for file in ${LIBLINKS} ; do
    BASE=`basename $file`
    TARGET=`readlink $file`
    echo "slink /lib/${BASE} ${TARGET} 755 0 0" >> filelist-final.txt
done;

# Add multiarch libarary dir
if [ -d ${STAGEDIR}/lib/${ARM_CC_PREFIX} ] ; then
echo "dir /lib/${ARM_CC_PREFIX} 755 0 0" >> filelist-final.txt
CLIBFILES=`find ${STAGEDIR}/lib/${ARM_CC_PREFIX} -maxdepth 1 -type f`
for file in ${CLIBFILES} ; do
    BASE=`basename $file`
    echo "file /lib/${ARM_CC_PREFIX}/${BASE} $file 755 0 0" >> filelist-final.txt
done;
CLIBLINKS=`find ${STAGEDIR}/lib/${ARM_CC_PREFIX} -maxdepth 1 -type l`
for file in ${CLIBLINKS} ; do
    BASE=`basename $file`
    TARGET=`readlink $file`
    echo "slink /lib/${ARM_CC_PREFIX}/${BASE} ${TARGET} 755 0 0" >> filelist-final.txt
done;
fi

# Add links by searching stage directory
LINKSBIN=`find ${STAGEDIR}/bin -maxdepth 1 -type l`
for file in ${LINKSBIN} ; do
    BASE=`basename $file`
    TARGET=`readlink $file`
    echo "slink /bin/${BASE} ${TARGET} 755 0 0" >> filelist-final.txt
done;
LINKSSBIN=`find ${STAGEDIR}/sbin -maxdepth 1 -type l`
for file in ${LINKSSBIN} ; do
    BASE=`basename $file`
    TARGET=`readlink $file`
    echo "slink /sbin/${BASE} ${TARGET} 755 0 0" >> filelist-final.txt
done;
LINKSUSRBIN=`find ${STAGEDIR}/usr/bin -maxdepth 1 -type l`
for file in ${LINKSUSRBIN} ; do
    BASE=`basename $file`
    TARGET=`readlink $file`
    echo "slink /usr/bin/${BASE} ${TARGET} 755 0 0" >> filelist-final.txt
done;
LINKSUSRSBIN=`find ${STAGEDIR}/usr/sbin -maxdepth 1 -type l`
for file in ${LINKSUSRSBIN} ; do
    BASE=`basename $file`
    TARGET=`readlink $file`
    echo "slink /sbin/${BASE} ${TARGET} 755 0 0" >> filelist-final.txt
done;

echo "Compiling fbtest..."
${CC_PREFIX}-gcc ${CFLAGS} -o ${STAGEDIR}/usr/bin/fbtest fbtest/fbtest.c
echo "file /usr/bin/fbtest ${STAGEDIR}/usr/bin/fbtest 755 0 0" >> filelist-final.txt

gen_init_cpio filelist-final.txt > ${HOME}/rootfs.cpio
#rm filelist-final.txt
if [ -f ${HOME}/rootfs.cpio ] ; then
    mv ${HOME}/rootfs.cpio ${OUTFILE}
fi
echo "New rootfs ready in ${OUTFILE}"
