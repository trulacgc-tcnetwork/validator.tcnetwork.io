#!/bin/bash

# Go
GO_VERSION=1.19.4

# Node
NODE_REPO=https://github.com/anoma/namada
NODE_VERSION=v0.13.0
NODE_HASH=v0.1.4-abciplus
NODE_REPO_FOLDER=
NODE_DAEMON=
NODE_ID=
NODE_DENOM=
NODE_FOLDER=.namada
NODE_GENESIS_ZIP=false
NODE_GENESIS_FILE=
NODE_GENESIS_CHECKSUM=
NODE_ADDR_BOOK=true
NODE_ADDR_BOOK_FILE=

# Service
NODE_SERVICE_NAME=namada

# Validator
VALIDATOR_NAME="TC Network"
VALIDATOR_WALLET="tc-network"
VALIDATOR_DETAIL="Cosmos validator, Web3 builder, Staking & Tracking service provider. Testnet staking UI https://testnet.explorer.tcnetwork.io/"
VALIDATOR_WEBSITE=https://tcnetwork.io
VALIDATOR_IDENTITY=C149D23D5257C23C



function main {
  echo "                                        NODE INSTALLER                                       ";
  echo "";
  echo "▒███████▒ ▒███▒ ▒███▒    ▒███▒▒██████▒▒███████▒▒██▒         ▒██▒  ▒████▒   ▒█████▒ ▒███▒  ▒██▒";
  echo "   ▒█▒  ▒█▒      ▒█▒ █▒   ▒█▒ ▒█▒        ▒█▒    ▒█▒         ▒█▒ ▒█▒    ▒█▒ ▒█▒  ▒█▒ ▒█▒ ▒█▒   ";
  echo "   ▒█▒ ▒█▒       ▒█▒  █▒  ▒█▒ ▒███▒      ▒█▒     ▒█▒   ▒   ▒█▒ ▒█▒      ▒█▒▒█▒██▒   ▒█▒█▒     ";
  echo "   ▒█▒  ▒█▒      ▒█▒   █▒ ▒█▒ ▒█▒        ▒█▒      ▒█▒ ▒█▒ ▒█▒   ▒█▒    ▒█▒ ▒█▒ ▒█▒  ▒█▒ ▒█▒   ";
  echo "   ▒█▒    ▒███▒ ▒███▒    ▒███▒▒██████▒   ▒█▒       ▒██▒ ▒██▒      ▒████▒   ▒█▒  ▒██▒███▒  ▒██▒";
  echo "";
  echo "Select action by number to do (Example: \"1\"):";
  echo "";
  echo "[1] Install Library Dependencies";
  echo "[2] Install Go";
  echo "[3] Install Node";
  echo "[4] Setup Node";
  echo "[5] Setup Service";
  echo "[6] Create/Import Wallet";
  echo "[7] Create validator";
  echo "[8] Download Snapshot";
  echo "[9] Restart Service";
  echo "";
  echo "[A] Remove Node";
  echo "[B] Upgrade Node";
  echo "[X] Helpful commands";
  echo "";
  read -p "[SELECT] > " input

  case $input in
    "1")
      installDependency
      exit 0
      ;;
    "2")
      installGo
      exit 0
      ;;
    "3")
      installNode
      exit 0
      ;;
    "4")
      initNode
      exit 0
      ;;
    "5")
      installService
      exit 0
      ;;
    "6")
      createImportWallet
      exit 0
      ;;
    "7")
      createValidator
      exit 0
      ;;
    "8")
      downloadSnapshot
      exit 0
      ;;
    "9")
      restartService
      exit 0
      ;;
    "A")
      removeNode
      exit 0
      ;;
    "B")
      upgradeNode
      exit 0
      ;;
    "X")
      helpfullCommand
      exit 0
      ;;
    *)
      echo "Invalid input - $input\n"
      ;;
    esac
}

function installDependency() {
  echo -e "\e[1m\e[32mInstalling Dependency... \e[0m" && sleep 1

  cd $HOME
  sudo apt update && sudo apt upgrade -y
  sudo apt install curl tar wget clang pkg-config libssl-dev libclang-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
  sudo apt install -y uidmap dbus-user-session

  cd $HOME
    sudo apt update
    sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
    . $HOME/.cargo/env
    curl https://deb.nodesource.com/setup_16.x | sudo bash
    sudo apt install cargo nodejs -y < "/dev/null"
}

function installGo() {
  echo -e "\e[1m\e[32mInstalling Go... \e[0m" && sleep 1

  if ! [ -x "$(command -v go)" ]; then
    cd $HOME
    wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
    rm "go$ver.linux-amd64.tar.gz"
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
    source ~/.bash_profile
  fi

  echo -e "If go version return nothing, try to apply again: source $HOME/.profile" && sleep 1  
}

function installNode() {
  echo -e "\e[1m\e[32mSetting variables... \e[0m" && sleep 1

  echo "export NAMADA_TAG=$NODE_VERSION" >> ~/.bash_profile
  echo "export TM_HASH=$NODE_HASH" >> ~/.bash_profile
  echo "export CHAIN_ID=$NODE_ID" >> ~/.bash_profile
  echo "export VALIDATOR_ALIAS=$VALIDATOR_NAME" >> ~/.bash_profile
  echo "export WALLET=$VALIDATOR_WALLET" >> ~/.bash_profile

  source ~/.bash_profile
  echo -e "\e[1m\e[32mSetting variables finished. \e[0m" && sleep 1

  echo -e "\e[1m\e[32mInstalling node... \e[0m" && sleep 1
  cd $HOME && git clone https://github.com/anoma/namada && cd namada && git checkout $NAMADA_TAG
  make build-release
  cargo --version

  cd $HOME && git clone https://github.com/heliaxdev/tendermint && cd tendermint && git checkout $TM_HASH
  make build

  cd $HOME && cp $HOME/tendermint/build/tendermint  /usr/local/bin/tendermint && cp "$HOME/namada/target/release/namada" /usr/local/bin/namada && cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac && cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan && cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw
  tendermint version
  namada --version

  echo -e "\e[1m\e[32mInstalling node finished... \e[0m" && sleep 1
}

#run fullnode
function initNode() {
  cd $HOME && namada client utils join-network --chain-id $CHAIN_ID

  cd $HOME && wget https://github.com/heliaxdev/anoma-network-config/releases/download/public-testnet-1.0.05ab4adb9db/public-testnet-1.0.05ab4adb9db.tar.gz
  tar xvzf "$HOME/public-testnet-1.0.05ab4adb9db.tar.gz"
}

function installService() {
  echo -e "\e[1m\e[32mInstalling service... \e[0m" && sleep 1

  if [ ! -f "/etc/systemd/system/$NODE_SERVICE_NAME.service" ]; then

sudo tee <<EOF >/dev/null /etc/systemd/system/$NODE_SERVICE_NAME.service
  [Unit]
  Description=$NODE_SERVICE_NAME Node
  After=network-online.target

  [Service]
  User=$USER
  WorkingDirectory=$HOME/$NODE_FOLDER
  Environment=NAMADA_LOG=debug
  Environment=NAMADA_TM_STDOUT=true
  ExecStart=/usr/local/bin/namada --base-dir=$HOME/$NODE_FOLDER node ledger run 
  StandardOutput=syslog
  StandardError=syslog
  Restart=on-failure
  RestartSec=3
  LimitNOFILE=65535

  [Install]
  WantedBy=multi-user.target
EOF

    # Enable systemd service
    echo -e "\e[1m\e[32mEnable service... \e[0m" && sleep 1

    sudo systemctl daemon-reload
    sudo systemctl enable $NODE_SERVICE_NAME.service

    echo -e "\e[1m\e[32mInstallation service finished. \e[0m" && sleep 1
  else
    echo -e "\e[1m\e[32mService already exist... \e[0m" && sleep 1
  fi
}

#Make wallet and run validator
function createImportWallet() {
  cd $HOME
  namada wallet address gen --alias $WALLET

  echo -e "\e[1m\e[32mCreate/Import wallet successful. \e[0m" && sleep 1
}


#waiting full synchronization then ctrl+c

namadac transfer \
    --token NAM \
    --amount 1000 \
    --source faucet \
    --target $WALLET \
    --signer $WALLET
  
#enter validator

namada client init-validator --alias $VALIDATOR_ALIAS --source $WALLET --commission-rate 0.05 --max-commission-rate-change 0.01 --gas-limit 10000000

#enter pass

cd $HOME
namadac transfer \
    --token NAM \
    --amount 1000 \
    --source faucet \
    --target $VALIDATOR_ALIAS \
    --signer $VALIDATOR_ALIAS
	
#use faucet again because min stake 1000 and you need some more NAM
namadac transfer \
    --token NAM \
    --amount 1000 \
    --source faucet \
    --target $VALIDATOR_ALIAS \
    --signer $VALIDATOR_ALIAS
	
#check balance
namada client balance --owner $VALIDATOR_ALIAS --token NAM

#stake your funds
namada client bond \
  --validator $VALIDATOR_ALIAS \
  --amount 1500 \
  --gas-limit 10000000
  
#print your validator address
export WALLET_ADDRESS=`cat "$HOME/.namada/public-testnet-1.0.05ab4adb9db/wallet.toml" | grep address`
echo -e '\n\e[45mYour wallet:' $WALLET_ADDRESS '\e[0m\n'

#waiting more than 2 epoch and check your status
namada client bonded-stake

#UPDATE for new release
cd $HOME/namada
NEWTAG=v0.12.2
git fetch
git checkout $NEWTAG
make build-release
cd $HOME && sudo systemctl stop namadad
rm /usr/local/bin/namada /usr/local/bin/namadac /usr/local/bin/namadan /usr/local/bin/namadaw
cd $HOME && cp "$HOME/namada/target/release/namada" /usr/local/bin/namada && cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac && cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan && cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw
sudo systemctl restart namadad
namada --version
sudo journalctl -u namadad -f -o cat