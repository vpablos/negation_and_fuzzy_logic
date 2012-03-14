#!/bin/bash

# set -x

if [ -z "$1" ] || [ "$1" == "" ]; then
	echo " "
	echo "This is an utility to build Ciao Prolog debian packages."
	echo "usage: $0 SVN_REVISION_CIAO "
	echo "example: $0 14440 "
	echo " "
	exit 0
else
	REVISION="$1"
fi;

# Compilation script.
CIAOSETUP=./ciaosetup

# Repositories urls.
REPOS_1=svn+ssh://clip.dia.fi.upm.es/home/clip/SvnReps/Systems/CiaoDE/trunk
# REPOS_2=https://babel.ls.fi.upm.es/svn/negation_and_fuzzy_logic/ciao-debian/
# SVNREPO_2=svn+ssh://clip.dia.fi.upm.es/home/egallego/clip/repos/ciao-debian/

FOLDER_NAME=~/secured/tests/CiaoDE_trunk

# Ensure folder exists and has a pristine copy.
# rm -fR $FOLDER_NAME
mkdir -p $FOLDER_NAME
pushd $FOLDER_NAME

# Update and export the Ciao's repository
echo " "
if [ -d .svn ]; then
	echo "updating CIAO to revision $REVISION from $REPOS_1"
	svn revert -R .
	svn update --revision $REVISION
else
	echo "checking out CIAO to revision $REVISION from $REPOS_1"
	svn co $REPOS_1 . --revision $REVISION
fi
popd
echo " "

echo " "
$(CIAOSETUP) clean
echo " "
$(CIAOSETUP) clean_config
echo " "
$(CIAOSETUP) realclean
echo " "
$(CIAOSETUP) braveclean
echo " "

# exit 0

$(CIAOSETUP) configure \
    --stop-if-error=yes \
#    --registration_type=all \
    --registration_type=user \
#    --instype=global \
    --instype=local
#    --prefix=/usr \
    --prefix=~/secured/local \
    --execmode=755 
    --datamode=644 
#    --installgroup=root \
#    --update_bashrc=no \
    --update_bashrc=yes \
    --dotbashrc=~/.bashrc \
    --update_cshrc=no \
    --install_prolog_name=no \
    --install_emacs_support=yes \
    --install_xemacs_support=no \
    --update_dotemacs=yes \
    --dotemacs=~/.emacs \
    --emacsinitdir=~/.emacs.d \
    --update_dotxemacs=no \
    --htmldir=~/public_html/ciao-manual \
    --htmlurl=http://localhost/ciao-manual \
    --docdir=~/secured/local/share/doc/ciao-prolog \
    --mandir=~/secured/local/share/man \
    --infodir=~/secured/local/share/info \
    --web_images_path=~/secured/local/share/doc/ciao-prolog/html \
    --with_mysql=yes \
    --mysql_client_directory=/usr/lib \
    --with_gsl=no --with_ppl=no \
    --with_java_interface=yes \
    --with_ant=yes \
    --optimizing_compiler=yes \
    --use_threads=yes \
    --use_posix_locks=no \
    --and_parallel_execution=no \
    --par_back=no \
    --tabled_execution=no \
#    --optim_level=normal \
    --optim_level=optimized \
    --with_chr=yes \
    --with_ciaoppcl=no \
    --compress_lib=no \
    --unused_pred_warnings=yes \
    --runtime_checks=no \
    --set_flag_options=yes 

./$(CIAOSETUP) build
./$(CIAOSETUP) docs

