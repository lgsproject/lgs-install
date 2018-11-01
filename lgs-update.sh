#!/bin/bash

CONFIG_FILE='logiscoin.conf'
CONFIGFOLDER='/root/.logiscoin'
COIN_DAEMON='/usr/local/bin/logiscoind'
COIN_CLI='/usr/local/bin/logiscoin-cli'
#COIN_REPO='https://github.com/lgsproject/LogisCoin/releases/download/v2.0.0.0/logiscoin-2.0.0-x86_64-linux-gnu.tar.gz'
COIN_REPO='https://logiscoin.cc/files/logiscoin-2.0.0-x86_64-linux-gnu.tar.gz'
COIN_NAME='LogisCoin'
COIN_PORT=48484

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

progressfilt () {
  local flag=false c count cr=$'\r' nl=$'\n'
  while IFS='' read -d '' -rn 1 c
  do
    if $flag
    then
      printf '%c' "$c"
    else
      if [[ $c != $cr && $c != $nl ]]
      then
        count=0
      else
        ((count++))
        if ((count > 1))
        then
          flag=true
        fi
      fi
    fi
  done
}

function compile_node() {

  echo -e "Stop the $COIN_NAME wallet daemon"
  if (( $UBUNTU_VERSION == 16 || $UBUNTU_VERSION == 18 )); then
    systemctl stop $COIN_NAME.service
  else
    /etc/init.d/$COIN_NAME stop
  fi
  sleep 7
  
  echo -e "Remove the old $COIN_NAME wallet from the system"
  rm -f /usr/local/bin/logiscoin* >/dev/null 2>&1
  rm $CONFIGFOLDER/mnpayments.dat >/dev/null 2>&1
  rm $CONFIGFOLDER/fee_estimates.dat >/dev/null 2>&1
  rm $CONFIGFOLDER/peers.dat >/dev/null 2>&1
  rm $CONFIGFOLDER/budget.dat >/dev/null 2>&1
  rm $CONFIGFOLDER/mncache.dat >/dev/null 2>&1
  rm $CONFIGFOLDER/debug.log >/dev/null 2>&1
  rm $CONFIGFOLDER/db.log >/dev/null 2>&1
  sleep 5
  clear
  
  echo -e "Prepare to download a new wallet of $COIN_NAME"
  TMP_FOLDER=$(mktemp -d)
  cd $TMP_FOLDER
  wget --progress=bar:force $COIN_REPO 2>&1 | progressfilt
  compile_error
  COIN_ZIP=$(echo $COIN_REPO | awk -F'/' '{print $NF}')
  COIN_VER=$(echo $COIN_ZIP | awk -F'/' '{print $NF}' | sed -n 's/.*\([0-9]\.[0-9]\.[0-9]\).*/\1/p')
  COIN_DIR=$(echo ${COIN_NAME,,}-$COIN_VER)
  tar xvzf $COIN_ZIP --strip=2 ${COIN_DIR}/bin/${COIN_NAME,,}d ${COIN_DIR}/bin/${COIN_NAME,,}-cli>/dev/null 2>&1
  compile_error
  rm -f $COIN_ZIP >/dev/null 2>&1
  cp logiscoin* /usr/local/bin >/dev/null 2>&1
  compile_error
  strip $COIN_DAEMON $COIN_CLI
  cd - >/dev/null 2>&1
  rm -rf $TMP_FOLDER >/dev/null 2>&1
  clear
  
  echo -e "Start the $COIN_NAME wallet daemon"
  if (( $UBUNTU_VERSION == 16 || $UBUNTU_VERSION == 18 )); then
    systemctl start $COIN_NAME.service
  else
    /etc/init.d/$COIN_NAME start
  fi
  sleep 7
  clear
}

function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}

function detect_ubuntu() {
 if [[ $(lsb_release -d) == *18.04* ]]; then
   UBUNTU_VERSION=18
 elif [[ $(lsb_release -d) == *16.04* ]]; then
   UBUNTU_VERSION=16
 elif [[ $(lsb_release -d) == *14.04* ]]; then
   UBUNTU_VERSION=14
else
   echo -e "${RED}You are not running Ubuntu 14.04, 16.04 or 18.04 Installation is cancelled.${NC}"
   exit 1
fi
}

function checks() {
 detect_ubuntu 
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi
}

function prepare_system() {
echo -e "Prepare the system to update ${GREEN}$COIN_NAME${NC} master node."
apt-get update >/dev/null 2>&1
apt-get install -y wget curl ufw binutils >/dev/null 2>&1
}

function important_information() {
 echo
 echo -e "================================================================================"
 echo -e "$COIN_NAME Masternode wallet is update and running, listening on port ${RED}$COIN_PORT${NC}."
 echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 if (( $UBUNTU_VERSION == 16 || $UBUNTU_VERSION == 18 )); then
   echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
   echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
   echo -e "Status: ${RED}systemctl status $COIN_NAME.service${NC}"
 else
   echo -e "Start: ${RED}/etc/init.d/$COIN_NAME start${NC}"
   echo -e "Stop: ${RED}/etc/init.d/$COIN_NAME stop${NC}"
   echo -e "Status: ${RED}/etc/init.d/$COIN_NAME status${NC}"
 fi
 echo -e "Check if $COIN_NAME is running by using the following command:\n${RED}ps -ef | grep $COIN_DAEMON | grep -v grep${NC}"
 echo -e "Now update your local wallet (Windows/Mac) and run Masternode from local wallet."
 echo -e "================================================================================"
}

##### Main #####
clear

checks
prepare_system
compile_node
important_information
