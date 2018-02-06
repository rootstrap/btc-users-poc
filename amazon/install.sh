#!/usr/bin/env bash

. ./amazon/funcs.sh

# Review configuration values:
#
HOST=bitcoin-node
# user: rpcxuser
# pass: tnEL1pADcm9ebBLXXsQKxyhdHlv67cdPkh3yd8T3EZs=
BITCOIN_RPC_AUTH='rpcxuser:215548918cf3fcdc26edb9122de037ed$0f4ae538749af4a12faa12a70f3a86402c5f9042bd695bcadd52256eab7aa06e'
CALLBACK_HOST=crypto-exchange-poc.herokuapp.com
CALLBACK_KEY=HRdIflAdDf-OPjRz5wBiJi2BwavkpwbmQz5cl8YID4g=
# if set to "1", use the test network
BITCOIN_TESTNET=1
# Device used to store the blockchain,
# check `lsblk` to see available devices.
DATA_DEVICE=xvdb
BITCOIN_USER=bitcoin
DATA_FS=ext4
SWAP_FILE=/swapfile
DATA_DIRECTORY=/data
# -------------------------------------------------------

# This directory must be under $DATA_DIRECTORY
BITCOIN_DIRECTORY=${DATA_DIRECTORY}/bitcoin

install-bitcoin() {
  failsafe 'Add bitcoin repository' \
    sudo add-apt-repository -y ppa:bitcoin/bitcoin

  failsafe 'Update apt cache' \
    sudo apt-get update -y

  failsafe 'install bitcoind package' \
    sudo apt-get install bitcoind -y
}

generate-bitcoin-config() {
  TESTNET="#testnet=0"

  if [ "${BITCOIN_TESTNET}" == "1" ]; then
    TESTNET="testnet=1"
  fi

  cat <<EOF
server=1
${TESTNET}
daemon=1
rpcport=8332
walletnotify=${BITCOIN_DIRECTORY}/bin/post ${CALLBACK_HOST} ${CALLBACK_KEY} btc/%s
# TODO: Use rpcauth instead
rpcauth=${BITCOIN_RPC_AUTH}
# TODO
rpcallowip=::/0
EOF
}

generate-bitcoind-service() {
  cat <<EOF
[Unit]
Description=Bitcoin node service
After=network.target

[Service]
User=${BITCOIN_USER}
Restart=always
Type=forking
ExecStart=/usr/bin/bitcoind

[Install]
WantedBy=multi-user.target
EOF
}

write-bitcoin-config() {
  CONFIG=$(generate-bitcoin-config)
  CONFIG_FILE="${BITCOIN_DIRECTORY}/.bitcoin/bitcoin.conf"

  echo "${CONFIG}" | failsafe 'Store bitcoin configuration' \
    sudo -u ${BITCOIN_USER} tee ${CONFIG_FILE} > /dev/null

  failsafe 'Set bitcoin configuration permissions' \
    sudo -u ${BITCOIN_USER} chmod 0600 ${CONFIG_FILE}
}

configure-bitcoin() {
  failsafe 'Create bitcoin configuration directory' \
    sudo -u ${BITCOIN_USER} mkdir -p "${BITCOIN_DIRECTORY}/.bitcoin"

  write-bitcoin-config

  generate-bitcoind-service | failsafe 'Create bitcoind service' \
    sudo tee /etc/systemd/system/bitcoind.service > /dev/null
}

reconfigure-bitcoin() {
  write-bitcoin-config
  restart-service bitcoind
}

generate-post-script() {
  cat <<EOF
#!/usr/bin/env bash

CALLBACK_HOST=\$1
CALLBACK_KEY=\$2
CALLBACK_PATH=\$3

curl --silent --show-error -H "Api-Key: \${CALLBACK_KEY}" -X POST \\
  https://\${CALLBACK_HOST}/callbacks/\${CALLBACK_PATH}
EOF
}

install-post-util() {
  failsafe 'Create ~/bin directory' \
    sudo -u ${BITCOIN_USER} mkdir -p ${BITCOIN_DIRECTORY}/bin

  generate-post-script | failsafe 'Write post script' \
    sudo -u ${BITCOIN_USER} tee ${BITCOIN_DIRECTORY}/bin/post > /dev/null

  failsafe 'Make post script executable' \
    sudo -u ${BITCOIN_USER} chmod +x ${BITCOIN_DIRECTORY}/bin/post
}

if [ "$1" == "" ]; then
  install-bitcoin
  setup-swap-file ${SWAP_FILE} 1024
  create-data-partition ${DATA_DEVICE} ${DATA_FS} ${DATA_DIRECTORY}
  create-system-account ${BITCOIN_USER} ${BITCOIN_DIRECTORY}
  install-post-script
  configure-bitcoin

  start-service bitcoind

  echo >&2
  echo ' Bitcoin configuration complete.' >&2
else
  $@
fi
