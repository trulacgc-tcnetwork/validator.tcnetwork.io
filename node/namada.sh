#!/bin/bash

# Go
GO_VERSION=1.20.5

# Node
NODE_REPO=https://github.com/anoma/namada
NODE_VERSION=v0.28.0
CBFT_VERSION=v0.37.2
CHAIN_ID=public-testnet-15.0dacadb8d663

NODE_HASH=
NODE_REPO_FOLDER=
NODE_DAEMON=

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
VALIDATOR_WALLET="tc network"
VALIDATOR_DETAIL="Cosmos validator, Web3 builder, Staking & Tracking service provider. Testnet staking UI https://testnet.explorer.tcnetwork.io/"
VALIDATOR_WEBSITE=https://tcnetwork.io
VALIDATOR_IDENTITY=C149D23D5257C23C

function main {
  echo "                                        NODE INSTALLER                                       "
  echo ""
  echo "▒███████▒ ▒███▒ ▒███▒    ▒███▒▒██████▒▒███████▒▒██▒         ▒██▒  ▒████▒   ▒█████▒ ▒███▒  ▒██▒"
  echo "   ▒█▒  ▒█▒      ▒█▒ █▒   ▒█▒ ▒█▒        ▒█▒    ▒█▒         ▒█▒ ▒█▒    ▒█▒ ▒█▒  ▒█▒ ▒█▒ ▒█▒   "
  echo "   ▒█▒ ▒█▒       ▒█▒  █▒  ▒█▒ ▒███▒      ▒█▒     ▒█▒   ▒   ▒█▒ ▒█▒      ▒█▒▒█▒██▒   ▒█▒█▒     "
  echo "   ▒█▒  ▒█▒      ▒█▒   █▒ ▒█▒ ▒█▒        ▒█▒      ▒█▒ ▒█▒ ▒█▒   ▒█▒    ▒█▒ ▒█▒ ▒█▒  ▒█▒ ▒█▒   "
  echo "   ▒█▒    ▒███▒ ▒███▒    ▒███▒▒██████▒   ▒█▒       ▒██▒ ▒██▒      ▒████▒   ▒█▒  ▒██▒███▒  ▒██▒"
  echo ""
  echo "Select action by number to do (Example: \"1\"):"
  echo ""
  echo "[1] Install Library Dependencies"
  echo "[2] Install Cargo & Node"
  echo "[3] Install Go"
  echo "[4] Install ProtoBuffer"
  echo "[5] Install Node"
  echo "[6] Join Network"
  echo "[7] Install Service"
  echo "[8] Restart Service"

  echo ""
  echo "[A] Remove Node"
  echo "[X] Helpful commands"
  echo ""
  read -p "[SELECT] > " input

  case $input in
  "1")
    installDependency
    exit 0
    ;;
  "2")
    installCargoNode
    exit 0
    ;;
  "3")
    installGo
    exit 0
    ;;
  "4")
    installProtoBuffer
    exit 0
    ;;
  "5")
    installNode
    exit 0
    ;;
  "6")
    joinNetwork
    exit 0
    ;;
  "7")
    installService
    exit 0
    ;;
  "8")
    restartService
    exit 0
    ;;
  "A")
    removeNode
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
  sudo apt install curl tar wget clang pkg-config git make libssl-dev libclang-dev libclang-12-dev -y
  sudo apt install jq build-essential bsdmainutils ncdu gcc git-core chrony liblz4-tool -y
  sudo apt install original-awk uidmap dbus-user-session protobuf-compiler unzip -y
  sudo apt install libudev-dev
}

function installCargoNode() {
  cd $HOME
  sudo apt update
  sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
  . $HOME/.cargo/env
  curl https://deb.nodesource.com/setup_18.x | sudo bash
  sudo apt install cargo nodejs -y <"/dev/null"

  echo -e "\e[1m\e[32mInstall Dependency successful. \e[0m" && sleep 1
  cargo --version
  node -v
}

function installGo() {
  echo -e "\e[1m\e[32mInstalling Go... \e[0m" && sleep 1

  if ! [ -x "$(command -v go)" ]; then
    cd $HOME
    wget "https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go$GO_VERSION.linux-amd64.tar.gz"
    rm "go$GO_VERSION.linux-amd64.tar.gz"
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >>~/.bash_profile
    source ~/.bash_profile
  fi

  go version

  echo -e "If go version return nothing, try to apply again: source $HOME/.profile" && sleep 1
}

function installProtoBuffer() {
  echo -e "\e[1m\e[32mInstalling ProtoBuffer... \e[0m" && sleep 1

  cd $HOME && rustup update
  PROTOC_ZIP=protoc-23.3-linux-x86_64.zip
  curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v23.3/$PROTOC_ZIP
  sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
  sudo unzip -o $PROTOC_ZIP -d /usr/local 'include/*'
  rm -f $PROTOC_ZIP

  echo -e "\e[1m\e[32mInstall ProtoBuffer successful. \e[0m" && sleep 1
  protoc --version
}

function installNode() {
  echo -e "\e[1m\e[32mSetting variables... \e[0m" && sleep 1

  #CHECK your vars in /.bash_profile and change if they not correctly
  sed -i '/public-testnet/d' "$HOME/.bash_profile"
  sed -i '/NAMADA_TAG/d' "$HOME/.bash_profile"
  sed -i '/WALLET_ADDRESS/d' "$HOME/.bash_profile"
  sed -i '/CBFT/d' "$HOME/.bash_profile"

  #Setting up vars
  echo "export NAMADA_TAG=$NODE_VERSION" >>~/.bash_profile
  echo "export CBFT=$CBFT_VERSION" >>~/.bash_profile
  echo "export NAMADA_CHAIN_ID=$CHAIN_ID" >>~/.bash_profile
  echo "export VALIDATOR_ALIAS=$VALIDATOR_NAME" >>~/.bash_profile
  echo "export WALLET=$VALIDATOR_WALLET" >>~/.bash_profile
  echo "export BASE_DIR=$HOME/.local/share/namada" >>~/.bash_profile

  source ~/.bash_profile
  echo -e "\e[1m\e[32mSetting variables finished. \e[0m" && sleep 1

  echo -e "\e[1m\e[32mInstalling node... \e[0m" && sleep 1
  cd $HOME && git clone https://github.com/anoma/namada && cd namada && git checkout $NAMADA_TAG
  make build-release

  echo -e "\e[1m\e[32mInstalling cometbft... \e[0m" && sleep 1
  cd $HOME && git clone https://github.com/cometbft/cometbft.git && cd cometbft && git checkout $CBFT
  make build

  cd $HOME
  sudo cp $HOME/cometbft/build/cometbft /usr/local/bin/cometbft
  sudo cp $HOME/namada/target/release/* /usr/local/bin

  cometbft version
  namada --version

  echo -e "\e[1m\e[32mInstalling node finished... \e[0m" && sleep 1
}

function joinNetwork() {
  cd $HOME
  namadac utils join-network --chain-id $CHAIN_ID --pre-genesis-path "$HOME/.local/share/namada/pre-genesis/$VALIDATOR_ALIAS"
}

function installService() {
  echo -e "\e[1m\e[32mInstalling service... \e[0m" && sleep 1

  if [ ! -f "/etc/systemd/system/$NODE_SERVICE_NAME.service" ]; then

    sudo tee /etc/systemd/system/$NODE_SERVICE_NAME.service >/dev/null <<EOF
[Unit]
Description=$NODE_SERVICE_NAME
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.local/share/namada
Environment=TM_LOG_LEVEL=p2p:none,pex:error
Environment=NAMADA_CMT_STDOUT=true
ExecStart=/usr/local/bin/namada node ledger run 
StandardOutput=syslog
StandardError=syslog
Restart=always
RestartSec=10
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

function restartService() {
  echo -e "\e[1m\e[32mRestarting service... \e[0m" && sleep 1

  sudo systemctl restart $NODE_SERVICE_NAME
  sudo systemctl status $NODE_SERVICE_NAME

  echo -e "\e[1m\e[32mStart service done... \e[0m" && sleep 1
  echo -e "\e[1m\e[32mRun command to check log: sudo journalctl -u $NODE_SERVICE_NAME -f -o cat \e[0m" && sleep 1
}

function removeNode() {
  cd $HOME && mkdir $HOME/namada_backup
  cp -r $HOME/.local/share/namada/pre-genesis $HOME/namada_backup/
  sudo systemctl stop $NODE_SERVICE_NAME
  sudo systemctl disable $NODE_SERVICE_NAME
  rm /etc/systemd/system/namada* -rf
  rm $(which namada) -rf
  rm /usr/local/bin/namada* /usr/local/bin/cometbft -rf
  rm $HOME/.namada* -rf
  rm $HOME/.local/share/namada -rf
  rm $HOME/namada -rf
  rm $HOME/cometbft -rf
}

function helpfullCommand() {

}
