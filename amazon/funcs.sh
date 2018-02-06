#!/usr/bin/env bash

error() {
  echo " * $@" >&2
  exit 1
}

require-arg() {
  FUNCTION=$1
  VALUE=$2
  NAME=$3

  if [ "${VALUE}" == "" ]; then
    error "Missing argument ${NAME} for ${FUNCTION}"
  fi
}

sudo() {
  # Just a safeguard to avoid mistakes.
  error 'sudo called on local machine, aborting.'
}

cmd() {
  echo " >> Running: $@" >&2
  ssh ${HOST} $@
}

copy() {
  echo "  > Copying [local] $1 -> [remote] $2"
  if ! scp $1 ${HOST}:$2; then
    error "Error copying file"
  fi
}

failsafe() {
  STEP=$1
  shift

  if ! cmd $@; then
    echo " * Failed step: $STEP." >&2
    echo "     > Command: $@" >&2

    exit 2
  fi
}

setup-swap-file() {
  require-arg 'setup-swap-file' $1 'FILE'
  require-arg 'setup-swap-file' $2 'SIZE'

  FILE=$1 # /swapfile
  SIZE=$2 # 1024

  FREE=$(failsafe 'Get memory information' free -h)

  if ! echo "${FREE}" | grep -iE 'swap:\s+0B' > /dev/null; then
    # We already have swap, skip.
    return 0
  fi

  FSTAB=$(failsafe 'Read fstab file' sudo cat /etc/fstab)
  if echo "${FSTAB}" | grep 'swap' > /dev/null; then
    # Swap exists but it's off, turn it on.
    failsafe 'Mount swap' sudo swapon -a
    return 0
  fi

  failsafe 'Create swap file' \
    sudo dd if=/dev/zero of=${FILE} bs=1M count=${SIZE}
  failsafe 'Format swap file' \
    sudo mkswap ${FILE}

  cmd sudo chown root:root ${FILE}
  cmd sudo chmod 0600 ${FILE}

  echo "${FILE} swap swap defaults 0 0" | failsafe 'Add swap to fstab' \
    sudo tee -a /etc/fstab > /dev/null

  failsafe 'Mount swap' sudo swapon -a

  echo 10 | failsafe 'Set swappiness value' \
    sudo tee /proc/sys/vm/swappiness > /dev/null
  echo vm.swappiness = 10 | failsafe 'Persist swappiness value' \
    sudo tee -a /etc/sysctl.conf > /dev/null
}

create-data-partition() {
  require-arg 'create-data-partition' $1 'DEVICE'
  require-arg 'create-data-partition' $2 'FS'
  require-arg 'create-data-partition' $3 'DIRECTORY'

  DEVICE=$1 # xvdb
  FS=$2 # ext4
  DIRECTORY=$3 # /data

  DEVICES_DATA=$(failsafe 'List devices' lsblk)

  DEVICES=$(echo "${DEVICES_DATA}" | grep -E 'disk.$' | awk '{print $1}')
  PARTITIONS=$(echo "${DEVICES_DATA}" | grep -E 'part.$' | awk '{print $1}')

  if echo "${PARTITIONS}" | grep "${DEVICE}1" > /dev/null; then
    # Partition already exists, skip.
    return 0
  fi

  if ! echo "${DEVICES}" | grep ${DEVICE} > /dev/null; then
    # The device does not exist, we cannot continue.

    echo " * ${DEVICE} is not available on target system."
    echo " > Found devices: " ${DEVICES}
    exit -1
  fi

  failsafe 'Create disk label' \
    sudo parted /dev/${DEVICE} -s -- mklabel msdos

  failsafe 'Create data partition' \
    sudo parted /dev/${DEVICE} -s -- mkpart primary 0% 100%

  failsafe 'Format data partition' \
    sudo mkfs -t ${FS} "/dev/${DEVICE}1"

  MOUNTS=$(failsafe 'List mounts' mount)
  if echo "${MOUNTS}" | grep ${DEVICE}; then
    # Device is already mounted, skip.
    return 0
  fi

  FSTAB=$(failsafe 'Read fstab' cat /etc/fstab)
  if ! echo "${FSTAB}" | grep ${DEVICE} > /dev/null; then
    FSTAB_LINE="/dev/${DEVICE}1 ${DIRECTORY} ${FS} defaults 0 0"

    echo "${FSTAB_LINE}" | failsafe 'Add data device to fstab' \
      sudo tee -a /etc/fstab > /dev/null
  fi

  failsafe 'Create data directory' \
    sudo mkdir -p ${DIRECTORY}

  failsafe 'Mount data filesystem' \
    sudo mount -a
}

create-system-account() {
  NAME=$1 # bitcoin
  DIRECTORY=$2 # /data/bitcoin

  failsafe "Create ${NAME} account" \
    sudo adduser --system --group --shell /bin/bash \
      --home ${DIRECTORY} ${NAME}
}

start-service() {
  NAME=$1

  failsafe 'Reload systemd daemons' \
    sudo systemctl daemon-reload

  failsafe "Enable ${NAME} service" sudo systemctl enable ${NAME}
  failsafe "Start ${NAME} service" sudo systemctl start ${NAME}
}

restart-service() {
  NAME=$1

  failsafe "Restart ${NAME} service" sudo systemctl restart ${NAME}
}
