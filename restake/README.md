# Install Restake

## 1. Install Docker, Restake and services

```sh
wget -O setup.sh https://raw.githubusercontent.com/trulacgc-tcnetwork/validator.tcnetwork.io/main/restake/setup.sh
chmod +x setup.sh && ./setup.sh
```

## 2. Configure hot wallet

Update your new .env file with your mnemonic, using command `sudo nano ~/restake/.env`

**Note**: You only need a single mnemonic for multiple Cosmos chains, and the script will check each network in the `networks.json` file for a matching bot address.

## 3. Overriding networks config locally

Create a `~/restake/src/networks.local.json` file and specify the networks you want to override. The below is just an example

```json
"cerberus": {
    "prettyName": "Cerberus",
    "restUrl": [
      "https://cerberus-api.skynetvalidators.com/"
    ],
    "rpcUrl": [
      "https://rpc.cosmos.directory/cerberus"
    ]
    "gasPrice": "0.025ucrbrus",
    "autostake": {
      "batchTxs": 100
    },
    "ownerAddress": "cerberusvaloper1380ee97fmsr9kfdmy80g6ptxj3k90g04tecq89",
    "authzSupport": true
  }
```

**Note**: Note that REStake requires a node with indexing enabled and minimum gas prices matching the `networks.json` gas price (or your local override).

## 4. Submiting your operator

- Clone repository <https://github.com/eco-stake/validator-registry> to your github
- Create new folder for your validator, and add 2 files to this folder, example:

  ```json
  tcnetwork
    chains.json
    profiles.json
  ```
  
- Update your operator information into `chains.json` file. Example:

  ```json
  {
    "name": "TC Network",
    "chains": [
      {
        "name": "cerberus",
        "address": "cerberusvaloper1380ee97fmsr9kfdmy80g6ptxj3k90g04tecq89",
        "restake": {
          "address": "cerberus19a9vcvzc8ld33psnq8dm0h4lh5v8seuwn4fjd8",
          "run_time": "every 1 hour",
          "minimum_reward": 1000000
        }
      }
    ]
  }
  ```

- Update your profile information into `profiles.json` file. Example:

  ```json
  {
    "name": "TC Network",
    "identity": "C149D23D5257C23C"
  }
  ```

- Submit your [Validator Registry](https://github.com/eco-stake/validator-registry) to that repository in a PR.

## Maintenance

- Update your local repository and pre-build your Docker containers with the following commands:

  ```sh
  git pull
  docker-compose run --rm app npm install
  docker-compose build --no-cache
  ```

- View all running containers

  ```sh
  docker-compose ps
  ```

- Stop all containers

  ```sh
  docker-compose down
  ```

- Manage individual containers

  ```sh
  docker-compose stop <container>
  docker-compose start <container>
  docker-compose restart <container>
  ```
