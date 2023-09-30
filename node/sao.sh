#!/bin/bash

# Go
GO_VERSION=1.19.4

# Node
NODE_REPO=https://github.com/SaoNetwork/sao-consensus.git
NODE_VERSION=v0.1.4
NODE_REPO_FOLDER=sao-consensus
NODE_DAEMON=saod
NODE_ID=sao-testnet1
NODE_DENOM=sao
NODE_FOLDER=.sao
NODE_GENESIS_ZIP=false
NODE_GENESIS_FILE=https://raw.githubusercontent.com/obajay/nodes-Guides/main/Sao/genesis.json
NODE_GENESIS_CHECKSUM=4df3995bbe58f769b5f312e3bcecfcd4779fc78fdd94519127c6b59a6da89d08
NODE_ADDR_BOOK=true
NODE_ADDR_BOOK_FILE=https://raw.githubusercontent.com/obajay/nodes-Guides/main/Sao/addrbook.json

# Service
NODE_SERVICE_NAME=sao

# Validator
VALIDATOR_DETAIL="Cosmos validator, Web3 builder, Staking & Tracking service provider. Testnet staking UI https://testnet.explorer.tcnetwork.io/"
VALIDATOR_WEBSITE=https://tcnetwork.io
VALIDATOR_IDENTITY=C149D23D5257C23C

# Snapshot
SNAPSHOT_PATH=https://ss-t.sao.nodestake.top/2023-04-28_2229510.tar.lz4

# Upgrade
UPGRADE_PATH=
UPGRADE_FILE=

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
  echo "[2] Install Go"
  echo "[3] Install Node"
  echo "[4] Setup Node"
  echo "[5] Setup Service"
  echo "[6] Create/Import Wallet"
  echo "[7] Create validator"
  echo "[8] Download Snapshot"
  echo "[9] Restart Service"
  echo ""
  echo "[A] Remove Node"
  echo "[B] Upgrade Node"
  echo "[X] Helpful commands"
  echo ""
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

  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt install curl chrony wget make gcc git jq build-essential snapd lz4 unzip -y
}

function installGo() {
  echo -e "\e[1m\e[32mInstalling Go... \e[0m" && sleep 1

  if [ ! -d "/usr/local/go" ]; then
    cd $HOME
    wget "https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go$GO_VERSION.linux-amd64.tar.gz"
    sudo rm "go$GO_VERSION.linux-amd64.tar.gz"

    echo -e "\e[1m\e[32mInstallation Go done. \e[0m" && sleep 1
  else
    echo -e "\e[1m\e[32mGo already installed with version: \e[0m" && sleep 1
  fi

  PATH_INCLUDES_GO=$(grep "$HOME/go/bin" $HOME/.profile)
  if [ -z "$PATH_INCLUDES_GO" ]; then
    echo "export GOROOT=/usr/local/go" >>$HOME/.profile
    echo "export GOPATH=$HOME/go" >>$HOME/.profile
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >>$HOME/.profile
  fi

  source $HOME/.profile
  go version

  echo -e "If go version return nothing, try to apply again: source $HOME/.profile" && sleep 1
}

function installNode() {
  # remove previous tools
  echo -e "\e[1m\e[32mRemoving previous installed tools... \e[0m" && sleep 1
  if [ -f "/usr/local/bin/$NODE_DAEMON" ]; then
    sudo rm -rf usr/local/bin/$NODE_DAEMON
  fi

  # Install binary
  echo -e "\e[1m\e[32mInstalling Node... \e[0m" && sleep 1
  cd $HOME

  git clone $NODE_REPO
  cd $NODE_REPO_FOLDER
  git checkout $NODE_VERSION
  make install

  echo -e "\e[1m\e[32mInstalling Node finished. \e[0m" && sleep 1
}

function initNode() {
  echo -e "\e[1m\e[32mInitialize Node... \e[0m" && sleep 1

  # Set Vars
  if [ ! $NODE_NAME ]; then
    read -p "[ENTER YOUR NODE NAME] > " NODE_NAME
    read -p "[ENTER YOUR NODE PORT] > " NODE_PORT
  fi

  echo ""
  echo -e "YOUR NODE NAME : \e[1m\e[31m$NODE_NAME\e[0m"
  echo -e "NODE CHAIN ID  : \e[1m\e[31m$NODE_ID\e[0m"
  echo -e "NODE PORT      : \e[1m\e[31m${NODE_PORT}657\e[0m"
  echo ""

  PROFILE_INCLUDED=$(grep "NODE_NAME" $HOME/.profile)
  if [ -z "$PROFILE_INCLUDED" ]; then
    echo "export NODE_NAME=\"${NODE_NAME}\"" >>$HOME/.profile
    echo "export NODE_PORT=${NODE_PORT}" >>$HOME/.profile
    source ~/.profile
  fi

  # Initialize Node
  if [ ! -d "$HOME/$NODE_FOLDER" ]; then
    $NODE_DAEMON init "$NODE_NAME" --chain-id=$NODE_ID

    # keyring
    $NODE_DAEMON config keyring-backend test
  fi

  # Download Genesis
  cd $HOME
  echo -e "\e[1m\e[32mDownloading Genesis File... \e[0m" && sleep 1

  if $NODE_GENESIS_ZIP; then
    echo "Downloading zip file..."
    curl -s $NODE_GENESIS_FILE -o $HOME/genesis.json.gz
    gunzip $HOME/genesis.json.gz
    sudo mv $HOME/genesis.json $HOME/$NODE_FOLDER/config
  else
    echo "Downloading plain genesis file..."
    wget -O $HOME/$NODE_FOLDER/config/genesis.json $NODE_GENESIS_FILE
  fi

  # Checksum Genesis
  # if [[ $(sha256sum "$HOME/$NODE_FOLDER/config/genesis.json" | cut -f 1 -d' ') == "$NODE_GENESIS_CHECKSUM" ]]; then
  #   echo "Genesis checksum is match"
  # else
  #   echo "Genesis checksum is not match"
  #   return 1
  # fi

  # Download addrbook
  if $NODE_ADDR_BOOK; then
    wget -O $HOME/$NODE_FOLDER/config/addrbook.json $NODE_ADDR_BOOK_FILE
  fi

  echo "Setting configuration..."
  CONFIG_PATH="$HOME/$NODE_FOLDER/config/config.toml"
  APP_PATH="$HOME/$NODE_FOLDER/config/app.toml"

  # seed
  echo "Setting Seed..."
  SEEDS=""
  sed -i.bak -e "s/^seeds =.*/seeds = \"$SEEDS\"/" $CONFIG_PATH

  # peer
  PEERS="099fae8829071292f6b1cfaa2b5d637da4aac1b9@203.23.128.181:26656"
  sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $CONFIG_PATH

  # log
  echo "Setting Log..."
  sed -i -e "s/^log_level *=.*/log_level = \"warn\"/" $CONFIG_PATH

  # indexer
  echo "Setting Indexer..."
  sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $CONFIG_PATH

  # prometheus
  echo "Setting Prometheus..."
  sed -i -e "s/prometheus = false/prometheus = false/" $CONFIG_PATH

  # inbound/outbound
  sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 50/g' $CONFIG_PATH
  sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 50/g' $CONFIG_PATH

  # port
  echo "Setting Port..."
  sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NODE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NODE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NODE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NODE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NODE_PORT}660\"%" $CONFIG_PATH
  sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NODE_PORT}317\"%; s%^address = \":8080\"%address = \":${NODE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NODE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NODE_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${NODE_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${NODE_PORT}546\"%" $APP_PATH

  # gas
  echo "Setting Minimum Gas..."
  sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025$NODE_DENOM\"/" $APP_PATH

  # pruning
  echo "Setting Prunching..."
  pruning="custom"
  pruning_keep_recent="100"
  pruning_keep_every="0"
  pruning_interval="10"
  sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $APP_PATH
  sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $APP_PATH
  sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $APP_PATH
  sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $APP_PATH

  # snapshot-interval
  echo "Setting Snapshot..."
  sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = 0/" $APP_PATH

  echo -e "\e[1m\e[32mInit Node successful. \e[0m"
}

function installService() {
  echo -e "\e[1m\e[32mInstalling service... \e[0m" && sleep 1

  if [ ! -f "/etc/systemd/system/$NODE_SERVICE_NAME.service" ]; then

    sudo tee /etc/systemd/system/$NODE_SERVICE_NAME.service <<EOF >/dev/null
  [Unit]
  Description=$NODE_SERVICE_NAME Node
  After=network.target

  [Service]
  User=$USER
  Type=simple
  ExecStart=$(which $NODE_DAEMON) start
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

function createImportWallet() {
  echo "Do you want to create or import wallet?"
  echo "[1] Create new wallet"
  echo "[2] Import wallet"
  echo ""

  read -p " > " ACTION_WALLET
  read -p "[ENTER YOUR AlIAS WALLET NAME] > " NODE_WALLET

  case $ACTION_WALLET in
  "1")
    $NODE_DAEMON keys add $NODE_WALLET
    ;;

  "2")
    $NODE_DAEMON keys add $NODE_WALLET --recover
    ;;

  *)
    echo "Invalid input - $input"
    return 1
    ;;
  esac

  echo "export NODE_WALLET=${NODE_WALLET}" >>$HOME/.profile
  source $HOME/.profile

  echo -e "\e[1m\e[32mCreate/Import wallet successful. \e[0m" && sleep 1
}

function createValidator() {
  if [ ! $NODE_WALLET ]; then
    echo -e "\e[1m\e[32mPlease create/import wallet before create validator! \e[0m" && sleep 1
    return 1
  fi

  if [ ! $NODE_NAME ]; then
    echo -e "\e[1m\e[32mPlease setup node before create validator! \e[0m" && sleep 1
    return 1
  fi

  echo ""
  echo "Please define your information, leave empty to use default (TC Network)"
  read -p "[YOUR WEBSITE] > " YOUR_WEBSITE
  read -p "[YOUR IDENTITY] > " YOUR_IDENTITY
  read -p "[YOUR DESCRIPTION] > " YOUR_DETAIL

  if [[ $YOUR_WEBSITE = "" ]]; then
    YOUR_WEBSITE=$VALIDATOR_WEBSITE
  fi
  if [[ $YOUR_IDENTITY = "" ]]; then
    YOUR_IDENTITY=$VALIDATOR_IDENTITY
  fi
  if [[ $YOUR_DETAIL = "" ]]; then
    YOUR_DETAIL=$VALIDATOR_DETAIL
  fi

  echo -e "YOUR WEBSITE     : \e[1m\e[31m$YOUR_WEBSITE\e[0m"
  echo -e "NODE IDENTITY    : \e[1m\e[31m$YOUR_IDENTITY\e[0m"
  echo -e "NODE DESCRIPTION : \e[1m\e[31m$YOUR_DETAIL\e[0m"
  echo ""
  echo -e "\e[1m\e[32mCreating Valdiator Tx with wallet $NODE_WALLET... \e[0m" && sleep 1

  $NODE_DAEMON tx staking create-validator \
    --amount=1000000$NODE_DENOM \
    --pubkey=$($NODE_DAEMON tendermint show-validator) \
    --from="$NODE_WALLET" \
    --chain-id=$NODE_ID \
    --moniker="$NODE_NAME" \
    --commission-max-change-rate=0.01 \
    --commission-max-rate=0.10 \
    --commission-rate=0.05 \
    --details="$YOUR_DETAIL" \
    --website="$YOUR_WEBSITE" \
    --identity "$YOUR_IDENTITY" \
    --min-self-delegation="1000000" \
    --gas-prices="0.025$NODE_DENOM" \
    --gas="250000" \
    --node=tcp://127.0.0.1:${NODE_PORT}657

  echo -e "\e[1m\e[32mCreate Valdiator successful. \e[0m" && sleep 1
}

function downloadSnapshot() {
  if [[ $SNAPSHOT_PATH == "" ]]; then
    echo "Not existing Snapshot path to process."
    return 1
  fi

  echo -e "\e[1m\e[32mDownloading snapshot... \e[0m" && sleep 1

  sudo rm -rf $HOME/$NODE_FOLDER/data
  curl -L $SNAPSHOT_PATH | lz4 -dc - | tar -xf - -C $HOME/$NODE_FOLDER

  echo -e "\e[1m\e[32mDownload snapshot finished. \e[0m" && sleep 1
}

function restartService() {
  echo -e "\e[1m\e[32mRestarting service... \e[0m" && sleep 1

  sudo systemctl restart $NODE_SERVICE_NAME
  sudo systemctl status $NODE_SERVICE_NAME

  echo -e "\e[1m\e[32mStart service done... \e[0m" && sleep 1
  echo -e "\e[1m\e[32mRun command to check log: sudo journalctl -u $NODE_SERVICE_NAME -f -o cat \e[0m" && sleep 1
}

function removeNode() {
  echo -e "\e[1m\e[32mRemoving Node... \e[0m" && sleep 1

  if [ -f "/etc/systemd/system/$NODE_SERVICE_NAME.service" ]; then
    echo "Stop and remove service..."
    sudo systemctl stop $NODE_SERVICE_NAME
    sudo systemctl disable $NODE_SERVICE_NAME
    sudo rm /etc/systemd/system/$NODE_SERVICE_NAME.service
  fi

  echo "Removing Daemon..."
  if [ -f "$(which $NODE_DAEMON)" ]; then
    sudo rm -rf $(which $NODE_DAEMON)
  fi

  echo "Removing Node folder..."
  if [ -d "$HOME/$NODE_FOLDER" ]; then
    sudo rm -rf $HOME/$NODE_FOLDER
  fi

  echo "Removing Repo folder..."
  if [ -d "$HOME/$NODE_REPO_FOLDER" ]; then
    sudo rm -rf $HOME/$NODE_REPO_FOLDER
  fi

  echo "Removing environment variables..."
  unset NODE_NAME
  unset NODE_PORT

  echo -e "\e[1m\e[32mRemove Node successful. \e[0m" && sleep 1
}

function upgradeNode() {
  if [[ $UPGRADE_PATH == "" ]]; then
    echo "Not existing download path to process."
    return 1
  fi

  if [[ $UPGRADE_FILE == "" ]]; then
    echo "Not existing download file to process."
    return 1
  fi

  echo -e "\e[1m\e[32Downloading snapshot... \e[0m" && sleep 1

  sudo mkdir $HOME/upgrade && cd $HOME/upgrade
  sudo wget $UPGRADE_PATH/$UPGRADE_FILE
  sudo tar xfv $UPGRADE_FILE

  echo -e "\e[1m\e[32Shutting down node... \e[0m" && sleep 1
  sudo systemctl stop $NODE_SERVICE_NAME
  sudo systemctl status $NODE_SERVICE_NAME

  echo -e "\e[1m\e[32Upgrading node... \e[0m" && sleep 1
  sudo rm $HOME/go/bin/$NODE_DAEMON
  sudo mv $HOME/upgrade/bin/$NODE_DAEMON $HOME/go/bin/nibid
  sudo rm -rf $HOME/upgrade

  echo -e "\e[1m\e[32Restarting node... \e[0m" && sleep 1
  sudo systemctl restart $NODE_SERVICE_NAME

  echo "\e[1m\e[32Upgrade node finished. \e[0m"
  echo "\e[1m\e[32mRun command to check log: sudo journalctl -u $NODE_SERVICE_NAME -f -o cat \e[0m"
}

function helpfullCommand() {
  VALIDATOR_ADDRESS=$($NODE_DAEMON keys show $NODE_WALLET --bech val -a)

  echo "Check log:"
  echo "sudo journalctl -u $NODE_SERVICE_NAME -f -o cat"
  echo ""
  echo "Check sync status:"
  echo "curl -s localhost:${NODE_PORT}657/status | jq -r .result.sync_info"
  echo ""
  echo "Unjail validator:"
  echo "$NODE_DAEMON tx slashing unjail --from $NODE_WALLET --chain-id $NODE_ID --node tcp://127.0.0.1:${NODE_PORT}657 --fees 10000$NODE_DENOM -y"
  echo ""
  echo "Withdraw reward and commission:"
  echo "$NODE_DAEMON tx distribution withdraw-rewards $VALIDATOR_ADDRESS --from $NODE_WALLET --chain-id $NODE_ID --node tcp://127.0.0.1:${NODE_PORT}657 --commission -y"
  echo ""
  echo "Delegate:"
  echo "$NODE_DAEMON tx staking delegate $VALIDATOR_ADDRESS 1000000$NODE_DENOM --from $NODE_WALLET --chain-id $NODE_ID --node tcp://127.0.0.1:${NODE_PORT}657 -y"
  echo ""
  echo "Vote proposal X"
  echo "$NODE_DAEMON tx gov vote X yes|no|abstain|nowithveto --from $NODE_WALLET --chain-id $NODE_ID --node tcp://127.0.0.1:${NODE_PORT}657 -y"
  echo ""
}

function checksum() {
  NODE_FOLDER=.ollo
  NODE_GENESIS_CHECKSUM=4852e73a212318cabaa6bf264e18e8aeeb42ee1e428addc0855341fad5dc7dae

  if [[ $(sha256sum "$HOME/$NODE_FOLDER/config/genesis.json" | cut -f 1 -d' ') == "$NODE_GENESIS_CHECKSUM" ]]; then
    echo "Genesis checksum is match"
  else
    echo "Genesis checksum is not match"
    return 1
  fi
}

function checkProfile() {
  PROFILE_INCLUDED=$(grep "NODE_NAME" $HOME/.profile)
  if [ -z "$PROFILE_INCLUDED" ]; then
    echo "add to profile"
    echo "export NODE_NAME=${NODE_NAME}" >>$HOME/.profile
    echo "export NODE_PORT=${NODE_PORT}" >>$HOME/.profile
    source $HOME/.profile
  else
    echo "already added to bash profile"
  fi
}

main

# Test
# checksum
# checkProfile

# Run:
# On Mac: sh node-tool.sh
# On Ubuntu: sudo chmod +x node-tool.sh && ./node-tool.sh

# FAUCET_URL="https://faucet.testnet-2.nibiru.fi/"
# ADDR="nibi1pzfy45z6ysd9c0fp83fczt6zhusulr45vcxww3" # X MUN
# ADDR="nibi15a6my3yy7re9aspur592pdw0wdd4fvxakk92pz" #   Defund
# ADDR="nibi1xr5980r6e7cy3u3pfm5xq2ruh5d3xy6akafmp0" #   Gitopia
# ADDR="nibi16re2zprhnekq62qmcuh7v0dxtsa7le3n3s49ke" # X HyperSign
# curl -X POST -d '{"address": "'"$ADDR"'", "coins": ["10000000unibi","100000000000unusd"]}' $FAUCET_URL
