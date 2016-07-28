#!/bin/bash
baseDir=/opt/baseOTSdaq
Base=hgcal_daq
Products=otsdaq_productarea
V=e10

if [ ! -d "${Products}" ];then
    echo "[INFO] OTSdaq product area ${Products} not found: creating it now" 
    mkdir ${baseDir}/${Products}
    cd ${baseDir}/${Products}
    curl http://scisoft.fnal.gov/scisoft/packages/ups/v5_2_0/ups-5.2.0-Linux64bit%2B2.6-2.12.tar.bz2|tar -jx
    curl http://scisoft.fnal.gov/scisoft/packages/mrb/v1_07_01/mrb-1.07.01-noarch.tar.bz2|tar -jx
    curl http://scisoft.fnal.gov/scisoft/packages/xerces_c/v3_1_3/xerces_c-3.1.3-slf6-x86_64-${V}-prof.tar.bz2|tar -jx
    curl http://scisoft.fnal.gov/scisoft/packages/artdaq_mfextensions/v1_01_00/artdaq_mfextensions-1.01.00-slf6-x86_64-${V}-s35-prof.tar.bz2|tar -jx
    curl http://scisoft.fnal.gov/scisoft/packages/qt/v5_4_2b/qt-5.4.2b-slf6-x86_64-${V}.tar.bz2|tar -jx
    source ./setup 
    curl http://scisoft.fnal.gov/scisoft/bundles/tools/pullProducts -o pullProducts

    if [ ! -e "$baseDir/otsdaq-externals.tar.bz2" ];then
	cp /afs/cern.ch/user/u/uplegger/public/otsdaq-externals.tar.bz2 ${baseDir}
        cp /afs/cern.ch/user/u/uplegger/public/mongodb-3.0.7-e10-version.tar.bz2 ${baseDir}
    fi

    cp ${baseDir}/otsdaq-externals.tar.bz2 otsdaq-externals.tar.bz2
    cp ${baseDir}/mongodb-3.0.7-e10-version.tar.bz2 mongodb-3.0.7-e10-version.tar.bz2 

    tar -xjvf otsdaq-externals.tar.bz2 
    rm mongodb-3.0.7-slf6-x86_64-e10-prof.tar.bz2 
   
    for file in *.bz2; do tar -xjvf $file; done

    chmod +x pullProducts
# slf6 should be changed to slf7 or u14 if needed.
    ./pullProducts . slf6 artdaq-v1_13_00 s35-${V} prof
    rm -f *.bz2
else
    echo "[INFO] Product area ${Products} found"
    cd ${baseDir}/${Products}
    source ./setup
fi

cd ${baseDir}

if [ ! -d "${Base}" ];then
    mkdir ${Base}
     cd ${Base}
    source ${baseDir}/${Products}/setup # e.g. /data/ups/setup
    setup git
    setup gitflow
    setup mrb
    export MRB_PROJECT=otsdaq
    MRB_VERSION_=v1_00_04
    MRB_Q_=${V}:s35:prof
    mrb newDev -v ${MRB_VERSION_} -q ${MRB_Q_}
    source ${baseDir}/${Base}/localProducts_${MRB_PROJECT}_${MRB_VERSION_}_`echo ${MRB_Q_} | sed 's|:|_|g'`/setup
    . $Base/local*/setup
    cd $MRB_SOURCE
    
    mrb gitCheckout -b develop http://cdcvs.fnal.gov/projects/otsdaq
    mrb gitCheckout -b develop -d otsdaq_demo http://cdcvs.fnal.gov/projects/otsdaq-demo
    mrb gitCheckout -b develop -d otsdaq_utilities http://cdcvs.fnal.gov/projects/otsdaq-utilities
    mrb gitCheckout -b lukhanin-wip2 -d artdaq_database http://cdcvs.fnal.gov/projects/artdaq-utilities-database # Needed for now, should be removed soon
    
# Extract the XDAQ product shipped with OTSDAQ, as well as the special version of ARTDAQ
    cd ${baseDir}/${Products}
    for file in $MRB_SOURCE/otsdaq_demo/*.bz2;do tar -xf $file;done

# Setup smc_compiler because it has problems
    setup smc_compiler v6_1_0

else
    cd ${baseDir}/${Base}
    source ${baseDir}/${Products}/setup # e.g. /data/ups/setup
    setup git
    setup smc_compiler v6_1_0
    setup gitflow
    setup mrb
    export MRB_PROJECT=otsdaq
    MRB_VERSION_=v1_00_04
    MRB_Q_=${V}:s35:prof
    source ${baseDir}/${Base}/localProducts_${MRB_PROJECT}_${MRB_VERSION_}_`echo ${MRB_Q_} | sed 's|:|_|g'`/setup
    source  ${baseDir}/$Base/local*/setup 
    cd $MRB_SOURCE

fi

cd $MRB_BUILDDIR
source mrbSetEnv
export CETPKG_J=24
mrb build    # VERBOSE=1 <hit enter>
