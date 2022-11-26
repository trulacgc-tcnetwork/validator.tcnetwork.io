#!/usr/bin/env bash

function main {
  echo -e "What would you like to install:\n\n1) Docker\n2) Restake\n (ex: \"1\" or \"Docker\"):"
  read input

  case $input in
    "1" | "Docker")
      installDocker
      exit 0
      ;;

    "2" | "Restake")
      installRestake
      exit 0
      ;;
    
    *) 
      echo -e "Invalid input - $input\n" 
      ;;
    esac
}

function installDocker {
  # Install Docker
  echo -e "\e[1m\e[32mChecking if Docker is installed... \e[0m" && sleep 1

  if ! command -v docker &> /dev/null
  then
    echo -e "\e[1m\e[32mInstalling Docker... \e[0m" && sleep 1

    sudo apt-get install ca-certificates curl gnupg lsb-release wget -y
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y

     echo -e "\e[1m\e[32mInstallation Docker finished... \e[0m" && sleep 1
  fi

  # Install Docker Compose
  echo -e "\e[1m\e[32mChecking if Docker Compose is installed ... \e[0m" && sleep 1

  docker compose version
  if [ $? -ne 0 ]
  then
    echo -e "\e[1m\e[32mInstalling Docker Compose v2.3.3 ... \e[0m" && sleep 1

    sudo curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    docker-compose --version
    # sudo chown $USER /var/run/docker.sock

    echo -e "\e[1m\e[32mInstallation Docker Compose finished... \e[0m" && sleep 1
  fi
}

function installRestake {
  # Install Restake Binary
  echo -e "\e[1m\e[32mChecking if Restake Binary is installed ... \e[0m" && sleep 1

  if [ ! -d "$HOME/restake" ]; 
  then
    echo -e "\e[1m\e[32mInstalling Restake binary... \e[0m" && sleep 1

    sudo git clone https://github.com/eco-stake/restake
    cd restake
    sudo cp .env.sample .env

    echo -e "\e[1m\e[32mInstallation Restake finished... \e[0m" && sleep 1
  fi

  # Install Restake Services
  if [ ! -f "/etc/systemd/system/restake.service" ]; 
  then
    echo -e "\e[1m\e[32mInstalling restake service... \e[0m" && sleep 1

    # create restake service
    sudo tee <<EOF >/dev/null /etc/systemd/system/restake.service
    [Unit]
    Description=stakebot service with docker compose
    Requires=docker.service
    After=docker.service
    Wants=restake.timer

    [Service]
    Type=oneshot
    WorkingDirectory=$HOME/restake
    ExecStart=/usr/bin/docker-compose run --rm app npm run autostake

    [Install]
    WantedBy=multi-user.target
EOF
  fi

  if [ ! -f "/etc/systemd/system/restake.timer" ]; 
  then
    echo -e "\e[1m\e[32mInstalling timer service... \e[0m" && sleep 1

    # create timer service
    sudo tee <<EOF >/dev/null /etc/systemd/system/restake.timer
    [Unit]
    Description=Restake bot timer

    [Timer]
    AccuracySec=1min
    OnCalendar=*-*-* *:00:00

    [Install]
    WantedBy=timers.target
EOF
  fi

  echo -e "\e[1m\e[32mEnable services... \e[0m" && sleep 1

  # Enable systemd service
  sudo systemctl daemon-reload
  sudo systemctl enable restake.service
  sudo systemctl enable restake.timer

  echo -e "\e[1m\e[32mInstallation services finished... \e[0m" && sleep 1
  
}

main
