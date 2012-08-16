#!/bin/bash

echo "running $0 $* ... "

if [ -z $1 ] || [ "$1" == "" ] || [ -z $2 ] || [ "$2" == "" ]; then
	echo " "
	echo "ERROR: This arguments needs two arguments to be run."
	echo "${0} CHROOT_FOLDER DEST_FOLDER"
	echo " "
	exit -1
fi

CHROOT_FOLDER="$1" 
DEST_FOLDER="${2}"
FULL_PATH="${CHROOT_FOLDER}/${DEST_FOLDER}/"
COMPILATION_PATH="/usr/share/CiaoDE"

# Info: DEST_FOLDER must point to $(CURDIR)/debian/tmp

# ensure folders exist.
mkdir -p ${CHROOT_FOLDER}
mkdir -p ${FULL_PATH}

for file in *; do
	if [ ! -z $file ] && [ ! "$file" == "" ] && [ ! "$file" == "debian" ] && [ ! "$file" == ".svn" ]; then
		mv -v $file ${COMPILATION_PATH} 2>&1 >> ${FULL_PATH}/files-moved.txt
	fi
done

# To save configurations for emacs and bash
mkdir -p /root
touch /root/.emacs
touch /root/.bashrc

pushd ${COMPILATION_PATH}
debian/ciao-prolog-configure-clean-build-and-install.sh ${COMPILATION_PATH}
popd

# Need to move files to the $FULL_PATH

mv ${CHROOT_FOLDER}/root/.emacs ${FULL_PATH}/add_to_.emacs
mv ${CHROOT_FOLDER}/root/.bashrc ${FULL_PATH}/add_to_.bashrc


