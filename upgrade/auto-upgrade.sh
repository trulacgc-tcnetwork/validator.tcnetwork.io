#!/bin/bash

YELLOW="\033[33m"
GREEN="\033[32m"
NORMAL="\033[0m"
HEALTH_CHECKS_ID=

USER=
NODE_DAEMON=
NODE_PORT=
NODE_SERVICE_NAME=

UPGRADE_OPTION=1
UPGRADE_HEIGHT=
UPGRADE_FOLDER=upgrade

# Option 1: upgrade by using daemon file
UPGRADE_PATH=
UPGRADE_FILE=
UPGRADE_UNZIP=

# Option 2: upgrade by building from source
NODE_REPO=
NODE_REPO_FOLDER=
NODE_VERSION=

function installService() {
  echo ""
  echo -e "$YELLOW Installing service... $NORMAL" && sleep 3

  if [ ! -f "/etc/systemd/system/auto-upgrade-$NODE_SERVICE_NAME.service" ]; then

    sudo tee /etc/systemd/system/auto-upgrade-$NODE_SERVICE_NAME.service <<EOF >/dev/null
  [Unit]
  Description=auto-upgrade-$NODE_SERVICE_NAME

  [Service]
  User=$USER
  ExecStart=/usr/local/bin/auto-upgrade-$NODE_SERVICE_NAME.sh

  [Install]
  WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable auto-upgrade-$NODE_SERVICE_NAME.service

    echo -e "$GREEN Installation service finished. $NORMAL" && sleep 1
  else
    echo -e "$YELLOW Service already exist... $NORMAL" && sleep 1
  fi
}

function installShell() {
  echo ""
  echo -e "$YELLOW Creating shell script... $NORMAL" && sleep 3

  if [ ! -f "/usr/local/bin/auto-upgrade-$NODE_SERVICE_NAME.sh" ]; then

    sudo tee /usr/local/bin/auto-upgrade-$NODE_SERVICE_NAME.sh <<EOF >/dev/null
#!/bin/bash

NODE_DAEMON=$NODE_DAEMON
NODE_PORT=$NODE_PORT
NODE_SERVICE_NAME=$NODE_SERVICE_NAME

UPGRADE_HEIGHT=$UPGRADE_HEIGHT
UPGRADE_FOLDER=$UPGRADE_FOLDER
CURL=curl

while true; do
  LATEST_HEIGHT=\$(\${CURL} -s localhost:$NODE_PORT/status | jq -r .result.sync_info.latest_block_height)

  echo \$LATEST_HEIGHT

  if [[ \$LATEST_HEIGHT == $UPGRADE_HEIGHT ]]; then
    echo -e "$GREEN !!! Upgrading chain... !!! $NORMAL"

    sudo systemctl stop $NODE_SERVICE_NAME && sleep 1
    sudo rm $(which $NODE_DAEMON)
    sudo mv $HOME/$UPGRADE_FOLDER/$NODE_DAEMON $(which $NODE_DAEMON)

    sudo systemctl start $NODE_SERVICE_NAME && sleep 1
    sudo journalctl -u $NODE_SERVICE_NAME -f -o cat

    echo -e "$GREEN !!! Upgrade done !!! $NORMAL"

    # using curl (10 second timeout, retry up to 2 times):
    \${CURL} -m 10 --retry 2 -d '{"upgrade":"successful"}' -H "Content-Type: application/json" -X POST https://hc-ping.com/$HEALTH_CHECKS_ID

  fi

  # remove after done upgraded
  if [[ \$LATEST_HEIGHT -gt $UPGRADE_HEIGHT ]]; then
    echo -e "$GREEN  !!! Remove service... !!! $NORMAL"

    sudo systemctl stop auto-upgrade-$NODE_SERVICE_NAME
    sudo systemctl disable auto-upgrade-$NODE_SERVICE_NAME
    sudo rm /etc/systemd/system/auto-upgrade-$NODE_SERVICE_NAME.service

    echo -e "$GREEN !!! Remove service done !!! $NORMAL"
  fi

  echo -e "$GREEN Auto upgrade is sleeping $NORMAL"
  sleep 30
done

EOF

    sudo chmod +x /usr/local/bin/auto-upgrade-$NODE_SERVICE_NAME.sh

    echo -e "$GREEN Create shell script finished. $NORMAL" && sleep 1
  else
    echo -e "$YELLOW shell script already exist... $NORMAL" && sleep 1
  fi
}

function downloadDaemon() {
  echo ""
  echo -e "$YELLOW Getting daemon... $NORMAL" && sleep 3

  cd $HOME
  sudo rm -rf $HOME/$UPGRADE_FOLDER
  mkdir $HOME/$UPGRADE_FOLDER

  if [ $UPGRADE_OPTION == 1 ]; then
    sudo wget $UPGRADE_PATH/$UPGRADE_FILE
    sudo tar xfv $UPGRADE_FILE

    sudo mv $HOME/$UPGRADE_UNZIP/$NODE_DAEMON $HOME/$UPGRADE_FOLDER/$NODE_DAEMON

    sudo rm $UPGRADE_FILE
    sudo rm -rf $UPGRADE_UNZIP

    echo -e "$GREEN Download daemon done! $NORMAL"
  else
    sudo rm -rf $HOME/$NODE_REPO_FOLDER
    git clone $NODE_REPO
    cd $NODE_REPO_FOLDER
    git checkout $NODE_VERSION
    make build

    sudo mv $HOME/$NODE_REPO_FOLDER/build/$NODE_DAEMON $HOME/$UPGRADE_FOLDER/$NODE_DAEMON

    echo -e "$GREEN Build daemon done! $NORMAL"
  fi
}

downloadDaemon
installShell
installService

echo ""
echo -e "$YELLOW Verify commands: $NORMAL"
echo -e "$GREEN 1. $HOME/$UPGRADE_FOLDER/$NODE_DAEMON version $NORMAL"
echo -e "$GREEN 2. sudo nano /usr/local/bin/auto-upgrade-$NODE_SERVICE_NAME.sh $NORMAL"
echo -e "$GREEN 3. sudo nano /etc/systemd/system/auto-upgrade-$NODE_SERVICE_NAME.service $NORMAL"
echo ""
echo -e "$YELLOW Start auto upgrade service: $NORMAL"
echo -e "$GREEN sudo systemctl start auto-upgrade-$NODE_SERVICE_NAME && sudo journalctl -u auto-upgrade-$NODE_SERVICE_NAME -f -o cat $NORMAL"
echo ""

# Running:
# sudo nano node-upgrade.sh
# sudo chmod +x node-upgrade.sh && ./node-upgrade.sh
