# LogisCoin
Shell script to install a [LogisCoin Masternode](https://www.logiscoin.cc/) on a Linux server running Ubuntu 14.04, 16.04 or 18.04. Use it on your own risk.

***
## Installation:
```
git clone https://github.com/lgsproject/lgs-install/
cd lgs-install
bash lgs-install.sh
```
***

## Desktop wallet setup

After the MN is up and running, you need to configure the desktop wallet accordingly. Here are the steps for Windows Wallet
1. Open the LogisCoin Coin Desktop Wallet.
2. Go to RECEIVE and create a New Address: **MN1**
3. Send **1000** **LogisCoin** to **MN1**.
4. Wait for 15 confirmations.
5. Go to **Tools -> "Debug console - Console"**
6. Type the following command: **masternode outputs**
7. Go to  ** Tools -> "Open Masternode Configuration File"
8. Add the following entry:
```
Alias Address Privkey TxHash Output_index
```
* Alias: **MN1**
* Address: **VPS_IP:PORT**
* Privkey: **Masternode Private Key**
* TxHash: **First value from Step 6**
* Output index:  **Second value from Step 6**
9. Save and close the file.
10. Go to **Masternode Tab**. If you tab is not shown, please enable it from: **Settings - Options - Wallet - Show Masternodes Tab**
11. Click **Update status** to see your node. If it is not shown, close the wallet and start it again. Make sure the wallet is unlocked.
12. Open **Debug Console** and type:
```
startmasternode "alias" "0" "MN1"
```
***

## Usage:
```
logiscoin-cli getinfo
logiscoin-cli mnsync status
logiscoin-cli masternode status
```
Also, if you want to check/start/stop **LogisCoin** , run one of the following commands as **root**:

**Ubuntu 16.04**:
```
systemctl status LogisCoin #To check the service is running.
systemctl start LogisCoin #To start LogisCoin service.
systemctl stop LogisCoin #To stop LogisCoin service.
systemctl is-enabled LogisCoin #To check whetether LogisCoin service is enabled on boot or not.
```
**Ubuntu 14.04**:  
```
/etc/init.d/LogisCoin start #To start LogisCoin service
/etc/init.d/LogisCoin stop #To stop LogisCoin service
/etc/init.d/LogisCoin restart #To restart LogisCoin service
```
***
