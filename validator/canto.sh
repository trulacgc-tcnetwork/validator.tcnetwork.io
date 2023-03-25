#!/bin/bash

# Go
GO_VERSION=1.19.3

# Node
NODE_REPO=https://github.com/Canto-Network/Canto.git
NODE_VERSION=v5.0.0
NODE_REPO_FOLDER=Canto
NODE_DAEMON=cantod
NODE_ID=canto_7700-1
NODE_DENOM=acanto
NODE_FOLDER=.cantod
NODE_GENESIS_ZIP=false
NODE_GENESIS_FILE=https://github.com/Canto-Network/Canto/raw/genesis/Networks/Mainnet/genesis.json
NODE_ADDR_BOOK=true
NODE_ADDR_BOOK_FILE=https://snapshots.polkachu.com/addrbook/canto/addrbook.json

# Service
NODE_SERVICE_NAME=canto

# Validator
VALIDATOR_DETAIL="Cosmos validator, Web3 builder, Staking & Tracking service provider. Staking UI https://explorer.tcnetwork.io/"
VALIDATOR_WEBSITE=https://tcnetwork.io
VALIDATOR_IDENTITY=C149D23D5257C23C

# Snapshot
SNAPSHOT_PATH=https://snapshots.polkachu.com/snapshots/canto/canto_2780834.tar.lz4

# Upgrade
UPGRADE_PATH=
UPGRADE_FILE=


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
    echo "export GOROOT=/usr/local/go" >> $HOME/.profile
    echo "export GOPATH=$HOME/go" >> $HOME/.profile
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.profile
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

  sudo mv $HOME/go/bin/cantod /usr/local/bin
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

  echo "export NODE_NAME=\"${NODE_NAME}\"" >> $HOME/.profile
  echo "export NODE_PORT=${NODE_PORT}" >> $HOME/.profile
  echo "export NODE_ID=${NODE_ID}" >> $HOME/.profile
  source ~/.profile
  
  # Initialize Node
  echo -e "\e[1m\e[32mInit Chain... \e[0m" && sleep 1
  $NODE_DAEMON init "$NODE_NAME" --chain-id=$NODE_ID

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
    #curl -s $NODE_GENESIS_FILE > $HOME/$NODE_FOLDER/config/genesis.json
    wget -O genesis.json $NODE_GENESIS_FILE --inet4-only
    mv genesis.json $HOME/$NODE_FOLDER/config
  fi


  # Download addrbook
  if $NODE_ADDR_BOOK; then
    #wget -O $HOME/$NODE_FOLDER/config/addrbook.json $NODE_ADDR_BOOK_FILE
    wget -O addrbook.json $NODE_ADDR_BOOK_FILE --inet4-only
    mv addrbook.json $HOME/$NODE_FOLDER/config
  fi

  echo "Setting configuration..."
  CONFIG_PATH="$HOME/$NODE_FOLDER/config/config.toml"
  APP_PATH="$HOME/$NODE_FOLDER/config/app.toml"

  # seed
  echo "Setting Seed..."
  SEEDS="ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:15556"
  sed -i.bak "s/^seeds *=.*/seeds = \"$SEEDS\"/;" $CONFIG_PATH

  # peer
  PEERS="744294d2ecf5ddf14065be6d325e68dcbdf0c646@66.172.36.136:51656,f9fc759eb2fa4eb2159825cae149ba1065efa236@66.172.36.134:51656,81f89cfa6dd6ec4cb2ee297e67dd4613657c4194@88.198.32.17:30656,bea21c6cc721726a486dbd7f14c5e81ee12f6eaa@35.83.23.119:26656,f9f8f88dfde1bacca2f152089bb20c600dbb9d04@43.204.152.200:26656,510e68d0b0ccb903663637547bf641961c4c9987@185.229.119.216:26656,2d7826e04685c4afb7baf6a045a3098c1306e1cc@5.9.108.156:35095,8cb9419ede1d830e78b4dd1318bdbd4e6be000d7@144.76.27.79:36656,f886849e7f563c5c3e4f5a666be76a2184b246ef@85.10.203.235:26676,76789b7d030697abbb9b0f1bed103abb4a66c029@138.201.85.176:26676,a441b9fec8006f28fb2add0517fa823b886834d6@5.79.79.80:35095,1d3ab5cc05452e29d8dafb4f96fcf3841c485287@51.210.223.185:35095,9723b0dac535d9e5c28e62413ddda54386ff8955@138.201.249.155:26656,174f015f606fd1f139447158b81a1824f6352854@65.108.75.107:16656,8b2ac4899b5a0b6e289850bde707f45421d1e9a4@213.239.207.175:30656,43393ba9763a9b1b95785330c5059811e5ed7f91@95.217.122.80:17656,685c48cbc2ba54e20f49645d48b0878d6944d8e4@65.109.94.221:32656,978a3730fc791492c009ff380d8e8bb25997da1b@65.109.65.210:29656,b8cc93a20982f6e7dd0201757c642d2ddc76eee9@148.251.53.202:26656,484e252942ffcc0c6e31278ac0f47a3ca1317aef@142.132.238.165:26656,352bcc8169f459440fdb49bfb70904df114caf0c@66.206.17.178:26656,ab88f189db7825f376050a034d8bf0028442cfc3@34.89.161.101:26656,61c8c3dce43e7221a5dab1a3c86366f34d2edddd@213.239.215.77:26656,876a17aa48201ec9b8937d81e28b44bfcb4d318c@15.235.115.149:10004,6085683689776e7103ea5ea87c0f74d9a69e21a2@167.235.200.184:26656,f724d16c43147bad59a036f243aa79c6f4455d2d@23.88.69.167:26858,cdad27c5be53788cbf42dd1336adeabc253b6e52@38.242.251.238:26656,82956d94714ded8fd785acb498a0aeb7aafad7ff@85.17.6.142:26656,5401995b201605a03d9e1fd0460cbef49218bbf5@65.108.126.46:32656,6ed040a6d393738c1bbeebd200c2e2f660614907@135.181.222.179:28656,bedcf918f53967cd37a0d03e67997d1b40c6c152@5.161.113.61:26656,8f21e61a2a81c96e5b761b256cd5c9d13a325281@86.48.2.82:26656,f74639c33b7647b0462e634974147c20505747a6@213.239.216.252:23656,9188d4b9b9e1a7e86ac6a0e6bee343e4c5f6fa25@114.32.170.200:26656,e6d62aa5215719eb1b7434e19bca4e7f62923ef4@65.108.106.172:58656,edb42b3caf26aa9c37362bb53f3d0e6038683ead@34.134.123.237:26656,c9e39b78c37b1bd360676d1e68f40a1f6c36d528@109.236.86.96:36656,69c21a89c74d08cb4a3c463dc813fe279fe4f080@51.79.160.214:26656,4fb5a871a1f263752da75e323e2ed73ed315a17f@95.214.52.138:26666,5e55b3bbab81818dd7c9e0c34c25f64377e2ea6c@104.248.2.163:26656,54316791649b65af344432bf4bd31f46df0cb79c@51.195.234.49:27756,4ff352af6db6e68fc6913e82589c4c8dbfc88f6c@35.76.185.2:26656,64172382922c636354387436d7e3b494b1abf577@46.10.221.196:26656,5ce67581ef51b30c70212a870f2e5ede27c31929@65.109.20.109:26656,ebd18bdf64ac9b8d0e38ab8706fcf9ee1d54e70a@95.217.35.186:60656,6e7e9341fba194988d448393b2d77464107385c5@65.108.199.222:22496,514497b0bf03a0620af9d2d3e6fe540aed0b3b21@65.21.132.27:48356,a0a165866cf5408ed26459ff91e3968807fb13dd@152.228.215.7:26656,855dc3bfa1303bc8de211181918de78f1d9be7c8@67.205.146.202:26656,8e4d886e7c333e73cdf1f0271b05511a1866d515@65.109.49.163:56656,439d6746ec2ddeb03a4328e9ab1d0806e5d46ccd@34.252.21.196:26656,351895b765826f7f3d0b3eb5a968cf90fe310968@176.9.188.12:26656,325eaed0931fc7d743c6ee9b124bca334ff8dc2c@65.109.92.241:21216,be84f739a3581e0b37b4e06716e9e136bb5ab746@35.232.184.57:26656,c6a2c0ed97f3a7c61073b758191d7375aad56163@34.67.27.129:26656,6f811ea67bcf1275ef55e0535630af783f767344@95.214.53.178:26656,c7e5de7911802a8c7f80c046ad93152476898d56@202.61.194.254:36656,1797a6e3a45ea538dc669e296e5f76a3b510d101@65.109.29.150:26656,81fc7f83e9961790a279a1fbe3e2835cea032d0c@37.252.184.229:26656,3b25a50bf0fd8f5e776d2e17f4a0d75883bca7fb@65.108.227.42:26656,f15b2375cbfb2b9200096e311b8a1f703e7c2a68@149.102.153.162:26656,1959b9014fa0bd0eda445f84ef5dfe1195956cd0@77.37.176.99:26666,f7f18e32fdba70c28eeb82ec6c0e94707355798c@148.251.41.20:26656,80e65f207db973bc98d5b02daf5db0607b0a382e@66.172.36.133:51656,26c20d0d4875abfbb9269e5cd57e8f9245ff4c71@65.108.126.35:27656,0c65eb53eb5c328f8b2c74f4a2892ff501db671c@146.190.53.223:26656,74346567ad07541f8163be580c2b6667a1f97fe5@95.214.53.105:36656,0ea8451a880b469be9f94a379dc2b63ea829d16a@208.91.106.29:26656,42e5c9923c06e2100a19814c2fffbbdea641032d@15.235.114.194:10456,2ba20f6ff6be62590447ec964bb51bd67460f492@5.9.107.174:36656,6b90bb94063007ff88c14585debd84ababd7d637@65.108.79.198:26766,35dc11c325e6d8df6b92833d1087c0e2f8ce10d2@35.224.200.13:26656,469a2a16c0f8274ace1a587961f0693f4652f77c@167.172.146.235:26656,16a92f17853f21032161829ef567c66bd483e387@137.184.225.205:26656,ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@135.181.5.219:15556"
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
  sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $CONFIG_PATH
  sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $CONFIG_PATH

  # port
  echo "Setting Port..."
  sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NODE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NODE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NODE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NODE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NODE_PORT}660\"%" $CONFIG_PATH
  sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NODE_PORT}317\"%; s%^address = \":8080\"%address = \":${NODE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NODE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NODE_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${NODE_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${NODE_PORT}546\"%" $APP_PATH

  # gas
  echo "Setting Minimum Gas..."
  sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0001$NODE_DENOM\"/" $APP_PATH

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

sudo tee <<EOF >/dev/null /etc/systemd/system/$NODE_SERVICE_NAME.service
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
  echo "";

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

  echo "export NODE_WALLET=${NODE_WALLET}" >> $HOME/.profile
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
  --fees="30000000000000000$NODE_DENOM" \
  --gas="300000" \
  --node=tcp://127.0.0.1:${NODE_PORT}657

  echo -e "\e[1m\e[32mCreate Valdiator successful. \e[0m" && sleep 1
}

function downloadSnapshot() {
  if [[ $SNAPSHOT_PATH == "" ]]; then
    echo "Not existing Snapshot path to process."
    return 1
  fi

  echo -e "\e[1m\e[32mDownloading snapshot... \e[0m" && sleep 1

  $NODE_DAEMON tendermint unsafe-reset-all --home $HOME/$NODE_FOLDER --keep-addr-book
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
  sudo mv $HOME/upgrade/bin/$NODE_DAEMON $HOME/go/bin
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
    echo "export NODE_NAME=${NODE_NAME}" >> $HOME/.profile
    echo "export NODE_PORT=${NODE_PORT}" >> $HOME/.profile
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
# On Ubuntu: sudo chmod +x node.sh && ./node.sh
