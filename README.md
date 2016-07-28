# TestBeamDAQ
To install OTSDaq, run the script (based on instructions [here](https://cdcvs.fnal.gov/redmine/projects/otsdaq/wiki/Instructions_for_using_MRB_with_OTSDAQ)), then follow the [instructions](https://cdcvs.fnal.gov/redmine/projects/hgcal/wiki) for setting up HGCAL DAQ.

Packages required for building petalinux image:
libstdc++\*.i686 bzip2-devel.i686 zlib-devel.i686 ncurses\*.i686 libstdc++-devel.i686 syslinux-tftpboot ncurses-devel.i686 libselinux.i686

Commands used after installing packages:
```
mkdir /tftpboot
chown root:daq /tftpboot/
chmod 770 /tftpboot/
```

Commands to run OTSDaq on machine in bulding 27 lab:
```
cd /opt/baseOTSdaq/hgcal\_daq/srcs/otsdaq\_hgcal
source setup_mrb.sh
StartOTS
```

