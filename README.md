# Cosmos Tooling

This repo provide shell scripts for seting up node automatically just by one-click running that we are prepared, as well as the guide for running auto-compound service from Restake.

## Node Installer

### 1. Download script

Download sript: https://github.com/tcnetworkio/validator.tcnetwork.io

### 2. Running script

Copy the script and run it on your server.
Example:
```sh
sh gitopia.sh
```
Select action by number to install your node following step by step as below:

 **Remember to write your mnemonic phrase in a safe place, 
 It is the only way to recover your account if you ever forget your password.**


  ```
  [1] Install Library Dependencies
  [2] Install Go
  [3] Install Node
  [4] Setup Node
  [5] Setup Service
  [6] Create/Import Wallet
  [7] Create validator
  [8] Download Snapshot
  [9] Restart Service
  ```


You have to do some step before run `[7] Create validator ` as below:
 - You have to wait for your node sync to latest block. 
 - You can check status by this command: `curl -s localhost:60657/status | jq -r .result.sync_info`
 - You need to go to discord or faucet page to get the faucet first and then you run step `[7] Create validator ` 

This is step for you in case want to remove or upgrade your node:

  ```
  [A] Remove Node
  [B] Upgrade Node
  ```

## Install Restake

TBD

## Install Auto-compound service

TBD
