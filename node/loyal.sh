#!/bin/bash

# Go
GO_VERSION=1.19.3

# Node
NODE_REPO=https://github.com/LoyalLabs/loyal.git
NODE_VERSION=v0.25.1.2
NODE_REPO_FOLDER=loyal
NODE_DAEMON=loyald
NODE_ID=loyal-1
NODE_DENOM=ulyl
NODE_FOLDER=.loyal
NODE_GENESIS_ZIP=false
NODE_GENESIS_FILE=https://snapshots.nodeist.net/t/loyal/genesis.json
NODE_ADDR_BOOK=true
NODE_ADDR_BOOK_FILE=https://snapshots.nodeist.net/t/loyal/addrbook.json

# Service
NODE_SERVICE_NAME=loyal

# Validator
VALIDATOR_DETAIL="Cosmos validator, Web3 builder, Staking & Tracking service provider. Testnet staking UI https://testnet.explorer.tcnetwork.io/"
VALIDATOR_WEBSITE=https://tcnetwork.io
VALIDATOR_IDENTITY=C149D23D5257C23C

# Snapshot
SNAPSHOT_PATH=https://snap.nodeist.net/t/loyal/loyal.tar.lz4

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
    echo "export NODE_NAME=\"${NODE_NAME}\"" >> $HOME/.profile
    echo "export NODE_PORT=${NODE_PORT}" >> $HOME/.profile
    source ~/.profile
  fi
  
  # Initialize Node
  if [ ! -d "$HOME/$NODE_FOLDER" ]; then
    $NODE_DAEMON init "$NODE_NAME" --chain-id=$NODE_ID

    # keyring
    #$NODE_DAEMON config keyring-backend test
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
  SEEDS="7490c272d1c9db40b7b9b61b0df3bb4365cb63a6@loyal-seed.netdots.net:26656,b66ecdf36bb19a9af0460b3ae0901aece93ae006@pubnode1.joinloyal.io:26656"
  sed -i.bak "s/^seeds *=.*/seeds = \"$SEEDS\"/;" $CONFIG_PATH

  # peer
  PEERS="ecd750c265d8f0854ab8dc99a1d982ad5e386715@142.132.201.130:26656,6ba67d63da4123161c1f733cdce9a46f6819b72c@109.123.243.66:2566,af4add23aaca23dba019a125705e2ee6cc24bc35@50.21.186.177:2566,26c25bda862ce6fac0bc6d80d39f459731b75cf5@167.71.49.253:2566,4db7eaa882227c2e46e1b3afcca549a37011c949@206.189.107.87:2566,b4b86c326d90f84ced139ba3b5b32d59bef991c8@75.119.155.131:2566,eba2cf14a6eeee4e8189437fc1ab198fc4ca9cb2@146.190.92.134:2566,49c0f05a1a47f4d020d3e8c8c7e67f03e44fa5d7@198.71.61.239:2566,5d01d9faba0a63efc0c65fad4ec97faae1e1679e@103.134.154.155:2566,694f8f64eefcbfaf4f71b5bb33e38122eb6cf47e@38.242.250.113:2566,3a403bb556cfff0cdad14e3ad00cce5fdd290900@185.249.227.145:2566,b7b0caefa01734cff2fc893c77210e28c9c6013f@185.187.235.77:2566,436a58f8113421d6c7bb0dd84a80e88c14e42602@74.208.28.77:2566,41b9269fcc221578180c67d7713f09136b2ec55c@161.35.71.117:2566,6de4b209afffb810700ac5407656ac8d0acb5d33@149.102.155.26:2566,93f7fd3ffe867eefd40c406a34c871af4246d764@82.208.22.11:2566,7d6d384efdd87902801f2d7badb6d36b511eb6f2@194.180.176.20:2566,2d235a3110b3973469681df1e7c470b51cee6334@161.35.160.28:2566,45b081644640aced493058a125331493ceaf60dd@95.217.109.218:26656,fe976760ee833422f4efd72277c4157c92e57fff@74.208.187.2:2566,1a06e4b54fc91976410d691b261302573ae69326@109.123.253.188:2566,f6153ac4a479a5ef661439ac01017a5c1f109c5e@165.232.163.114:2566,eb1a5b11389e5e656df59c967446a830251a5bdd@206.189.91.39:2566,9bfc334b222f3585eee673767d3f5684c52f9f40@161.35.150.115:2566,bc09e5bc8a7f5a49a9c50fee927e3227e5645dcc@108.175.1.164:2566,99b577e46e21f2b86922c9e7a308a57cf9a6db81@194.163.133.221:2566,918ccbcc42b478acc9981d0cf812b391c4075d31@185.182.186.164:2566,6e4ea2b999ba27be826ad9a24c46a4345a8059e2@203.194.114.13:2566,91e863e3e069aa7b25b0a9d0b3644128c981c0f8@198.251.69.66:2566,f38217783e4d091022c7f18e2233b6d57f708755@159.223.41.80:2566,44cd1d4227859d62b34d4dc9402958d1a121faea@157.245.198.145:2566,7d65add543debfe636907e31dd464db05f8b01a8@185.135.137.136:2566,5d08d10e66b349f2287605d9a110a6489130ace0@159.203.46.245:2566,dfa87287bf12faf2d20e27e98c3feffa0c1c9aba@144.126.134.126:26656,85b69e705cad315b04fe793688cad0b8b2307acc@165.22.105.131:2566,566a6732853a5fd69f8bbe3523fdb49122b3a3fe@185.227.134.71:2566,b00a09236eec12427ad91e4c505f69a301ad9f06@185.197.250.215:2566,f59a01234898131f90c28f300629899f1de14870@45.118.134.182:2566,f15a7901ea4a3b318ebc196915b72c3cf54dc6d6@18.236.110.150:26656,4dee73af0dfcf44523e82b7b20fcb48ffea5138c@162.19.93.127:26656,f58d11aa983a75bdfbc043e270b5013b214dcdf2@46.101.160.143:2566,5cbf8aaf33a6d19d26844d284fd36155b6884c1f@109.123.252.33:2566,1adb7ae663df538cea1069627dca98cccc6f10b3@185.208.207.45:2566,c903358a838861f5573e3c4f8033bee90b8ee4a7@202.61.245.42:26656,46d7346990632fb50d072a62396ce20235224b2d@167.71.130.148:2566,dbb485929f41f6cd96dc7abccb65f0f9d73180a1@185.250.36.53:2566,9d3e2a92c38d499ae0b891563728460d87495feb@198.71.61.63:2566,573451cb9eef7a8532f3c866fa25ec600dc1fa7c@188.166.220.12:2566,c549997c59be890f12a9d86f89b3ccb9a858ee64@193.203.15.48:2566,c9b5c9ac6758bcf5dcddd108d3fc5f7805a70f71@217.160.64.238:2566,4672a416b94050e346037dedbbe9807fbc1b0a9f@198.251.69.78:2566,0f47d3c784ab55288a780201a3f38066f702fe3a@135.181.176.109:48656,e1f5095129734c057236244a3ce10a081c8fc808@161.35.16.250:2566,d36ea61b7cfe99c3c8180b36cd3a7f163d2e8247@167.172.80.202:656,47d3710a2c9dfb172d346c1f89ca969c68a49a0c@68.183.225.213:2566,33522141b1b448be235f43ea4b929b1123acc4e5@141.95.20.161:2566,2deb6d31df7c5b45c085e0fcd080216a329e4cb2@20.150.211.158:2566,bec3f84206b7ef1f22f106813e453253a837098c@3.0.188.79:2566,42dde3808998a521d606a0a431d22dfd22cf4f8d@185.208.207.157:2566,a02180c3867e828e3ab399917067cb576e3ad17b@209.126.2.153:2566,68e2fae4bf533ece9fc0f6e9171240b0a751155f@74.208.93.113:2566,2e3768f50014361c43e7e02a738cace6bb7ced5d@149.102.159.250:2566,0b2113702b974e608a85ee73e1f94cbc5921fe85@149.102.129.254:2566,7d618e8a62db21be043ccf633848276b9c28155a@137.184.66.60:2566,dc5b20991c29d676052c649ee5ee5d93e47bf997@167.99.73.177:2566,056011f128eb099993db18c4fcdf66d19007a1e8@20.255.163.130:2566,bd0bf5f49d8d6a93b6323b5eb45b4d6c43b9a359@104.248.155.156:2566,d02267e0d1185018c22505fa00c9cce3fb84cf76@149.102.134.132:2566,461ddc6d315e933d5cdb0d7f6b8d413f11539d0b@159.65.155.162:2566,ba6a0c785556cbd9890807701e6ac8bfd74ad38a@51.79.142.103:2566,2c1b2391b57cd8ae7ee153cc904940030aa6febe@188.166.182.8:2566,7ae44eeb15e320c84598c90455886c7ce7668610@185.250.36.115:2566,e29830e9bf062870680c9224551200b97923da40@86.48.5.254:2566,44f6d13a5051ea0f172d1a9bc5b551e0f9cc8e60@134.209.240.61:2566,25d8f9021ebc39ac1add5b5b9e9e23c3ee2a2d1a@194.195.87.15:2566,3ff4c3b74e55e317ba252fb0bd055c637ed013d5@128.199.14.31:2566,1567d01330f71d6e3cd664afc971c44c708988b9@38.242.254.103:2566,9bfeb1aa2b4b8a436d1e9e52983fdd46506a7763@157.245.56.207:2566,554b1abba9bd8742cffa4c688616cfdeef20ab9b@165.22.103.11:2566,0e9beebff7c5f0c92efa62334b31264e80918565@34.88.158.195:2566,0c83ae3e4038ac48c536077a2c9c4c3a52f54be9@154.26.138.224:2566,c0fd8b4025d0d09f19175798e8acffaa2a84d53b@185.209.229.125:2566,e3d902a329288a698f7262f91a16fd34f78422e9@38.242.228.93:2566,e2de511e6c2fc480ece68710ecb76e8df5a8789c@20.57.18.219:2566,367b20be2ac6e0a57d355a24e1d04ef8b0ff223e@159.223.203.127:2566,9fa6c4f5e0f3a73a668befcde07b7dfb3119b1c4@161.35.215.48:2566,3e6393e17ee68b19f11b0e60c8e37616f34deeb2@109.123.252.193:2566,20706b9486e8ac0a0864099800b631233118b31b@74.208.130.160:2566,54d64f3030c9ced899159a10cbefa501cdd9c34b@38.242.130.204:2566,7490c272d1c9db40b7b9b61b0df3bb4365cb63a6@54.80.32.192:26656,15295ec304006d18e3a909e4c27df28b88c149f1@206.189.92.7:2566"
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

  $NODE_DAEMON tendermint unsafe-reset-all --home $HOME/$NODE_FOLDER --keep-addr-book
  curl -L $SNAPSHOT_PATH | lz4 -dc - | tar -xf - -C $HOME/$NODE_FOLDER --strip-components 2

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
