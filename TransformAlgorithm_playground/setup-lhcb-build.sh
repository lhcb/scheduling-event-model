#!/bin/bash
#
# Usage: ./setup-lhcb-build.sh  install-directory
#
# Copyright (C) 2015 Wilco Baan Hofman <wilcobh@nikhef.nl>
#
# Public domain license, use any way you see fit.
#
# This will only build using SLC 6, set up an environment like in
# install-slc6-schroot.sh to build the LHCb code.
#
# To build, source setup.sh, then just make configure and make install for
# all projects.

log() {
        if [ "$1" = "INFO" ]; then
                printf "\033[0;32m$2..\033[0m\n"
        elif [ "$1" = "WARN" ]; then
                printf "\033[0;33m$2.\033[0m\n"
        elif [ "$1" = "ERR" ]; then
                printf "\033[0;31m$2.\033[0m\n"
        fi
}

# Check for required binaries on the host
if [ \! -x "$(which git 2>/dev/null)" ] ; then
        log ERR "Git is not installed"
        exit 1
fi
if [ \! -x "$(which ninja 2>/dev/null)" -a ! -e /afs/cern.ch/sw/lcg/contrib/ninja/1.4.0/x86_64-slc6/ninja ] ; then
        log WARN "Ninja is not installed. Will Install Ninja "
        build_ninja=1
fi
if [ "$(whoami)" = "root" ];then
        log ERR "You are root. Run as user"
        exit 1
fi

# Check arguments
if [ "$1" = "" ];then
        echo -e "Usage: $0 work-directory"
        exit 1
fi
DST="$1"

# Convert the DST to an absolute path
if [ "$(echo ${DST}|cut -c1)" != "/" ] ; then
        DST="${PWD}/${DST}"
fi

if [ -d "${DST}" ];then
        log ERR "work-directory already exists"
        exit 1
fi


# Do the actual work:
log INFO "Creating work directory ${DST}"

mkdir -p ${DST}
cd ${DST}

cat << EOF > setup.sh
#!/bin/sh
export USE_CMAKE=1
export LC_ALL="C"
export CMTCONFIG=x86_64-slc6-gcc49-opt
export CMAKEFLAGS="-DCMAKE_USE_CCACHE=ON"
if [ -e /cvmfs/lhcb.cern.ch/lib ] ; then
  export MYSITEROOT="/cvmfs/lhcb.cern.ch/lib"
  source \${MYSITEROOT}/lhcb/LBSCRIPTS/prod/InstallArea/scripts/LbLogin.sh --mysiteroot \${MYSITEROOT}  --cmtconfig \${CMTCONFIG}
else
  source /afs/cern.ch/lhcb/software/releases/LBSCRIPTS/prod/InstallArea/scripts/LbLogin.sh --cmtconfig \${CMTCONFIG}
fi
export CMTPROJECTPATH=${DST}:\${CMTPROJECTPATH}
export CMAKE_PREFIX_PATH=${DST}/Gaudi/cmake:\$CMAKE_PREFIX_PATH
unset VERBOSE
EOF

if [ -n "${build_ninja}" ];then
    log INFO "Ninja not found -- checking out and building ninja"
    git clone git://github.com/martine/ninja.git ninja-build
    ( cd ninja-build ; git checkout release ; ./configure.py --bootstrap )
    cp ninja-build/ninja $DST/ninja
    rm -rf ninja-build
    echo "export PATH=${DST}:\$PATH" >> setup.sh
else
    echo 'export PATH=$PATH:/afs/cern.ch/sw/lcg/contrib/ninja/1.4.0/x86_64-slc6' >> setup.sh
fi

cat <<EOF >Makefile
projects=Gaudi LHCb Lbcom Rec Brunel

all: \$(projects)

%: %/Makefile %/toolchain.cmake
	\$(MAKE) -C \$@ install

%/Makefile:
	ln -s ../Gaudi/Makefile-cmake.mk \$@

%/toolchain.cmake:
	ln -s \${LBUTILSROOT}/data/toolchain.cmake \$@

clean:
	for proj in \$(projects) ; do \$(MAKE) -C \$\${proj} \$@ ; done

purge:
	for proj in \$(projects) ; do \$(MAKE) -C \$\${proj} \$@ ; done

Gaudi: .FORCE
LHCb: Gaudi .FORCE
Lbcom: LHCb .FORCE
Rec: Lbcom .FORCE
Brunel: Rec .FORCE

.FORCE:
	@#dummy
EOF

log INFO "Getting Gaudi"
git clone ssh://git@gitlab.cern.ch:7999/graven/Gaudi.git -b Paris2015

for project in LHCb Lbcom Rec Brunel;do
	log INFO "Getting ${project}"
	git clone ssh://git@gitlab.cern.ch:7999/graven/${project}.git -b Paris2015
done
log INFO "Done.\n\nTo build: go to the ${DST} directory, then do:\n\n"
echo "source setup.sh"
echo "make"

