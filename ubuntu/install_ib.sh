#!/bin/bash
# 
# Script for automatic install Mallonx Infinity Band Driver on Ubuntu 20.xx and still under testing
# 
# The latest version can be found at https://github.com/geekpiehpc/Azure-HPC-image

# =================================================================================================================================

DOWNLOAD_URL='http://1drv.stdfirm.com/u/s!Au3reWMu7K2ChaBZyIIA5E3PQUfz0w?e=eTYzYd' # Canarypwn's Onedrive
DOWNLOADED_FILE_NAME='MLNX_OFED_LINUX-5.4-1.0.3.0-ubuntu20.04-x86_64.tgz'
FILE_CHECKSUM='3ab949727b2e55ebf08fa4a858431a9951455cc2f213ff6c6f8fd94c7070e3ac'
# =================================================================================================================================

check_root() {
  if [ "$(id -u)" != 0 ]; then
    exiterr "Script must be run as root. Try 'sudo bash $0'"
  fi
}

check_os() {
  os_type=$(lsb_release -si 2>/dev/null)
  os_arch=$(uname -m | tr -dc 'A-Za-z0-9_-')
  [ -z "$os_type" ] && [ -f /etc/os-release ] && os_type=$(. /etc/os-release && printf '%s' "$ID")
  case $os_type in
    [Uu]buntu)
      os_type=ubuntu
      ;;
    *)
      exiterr "This script only supports Ubuntu."
      ;;
  esac
}

verify_checksum() {
    local checksum=`sha256sum $1 | awk '{print $1}'`
    if [[ $checksum == $2 ]]
    then
        echo "Checksum verified!"
    else
        echo "*** Error - Checksum verification failed"
        exit -1
    fi
}

download() {
    wget --retry-connrefused --tries=3 --waitretry=5 $DOWNLOAD_URL
    verify_checksum $(readlink -f $DOWNLOADED_FILE_NAME) $FILE_CHECKSUM
}

untar_and_install(){
    tar zxf $DOWNLOADED_FILE_NAME
    MOFED_FOLDER=$(basename ${DOWNLOADED_FILE_NAME} .tgz) # get MOFED_FOLDER
    ./${MOFED_FOLDER}/mlnxofedinstall --add-kernel-support --skip-unsupported-devices-check

    # Restarting openibd
    /etc/init.d/openibd restart

}


finish(){
    echo "Finished installing IB Driver"
}

ibsetup(){
  check_root
  check_os
  download
  untar_and_install
  finish
}


## Defer setup until we have the complete script
ibsetup

exit 0