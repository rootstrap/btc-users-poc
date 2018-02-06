# Running a bitcoin node on amazon

## Instance requirements

- A `t2.small` (1vCPU, 2GB RAM) seems to be enough.
- Extra storage for the blockchain (blockchain is about 150GB atm).
- External ssh access for setup script (not needed afterwards).

## Script configuration

The script `amazon/install.sh` needs the the following configuration
variables to be edited:

- `HOST` - The SSH host we are going to be setting up as a bitcoin
  node. It could be an alias defined in `~/.ssh/config`.
- `BITCOIN_RPC_AUTH` - RPC authentication. For more information,
  see https://github.com/bitcoin/bitcoin/tree/master/share/rpcauth.
- `CALLBACK_HOST` - Web callback host (only the host).
- `CALLBACK_KEY` - Key used to send callbacks to the web.
- `BITCOIN_TESTNET` - Whether to use the testnet or not. Set to `1`
  to use the testnet.
- `DATA_DEVICE` - The device where the blockchain is goin to be stored.
  The script will partition/format this device (it will first try its
  best to determine if partitioning is needed, but it is not perfect,
  so make sure this is the correct device and you can afford losing
  its contents)
- `BITCOIN_USER` - The user which will run the bitcoind service. The
  script is going to create this user.
- `DATA_FS` - The filesystem to use on the new partition.
- `SWAP_FILE` - File to use a swapfile.
- `DATA_DIRECTORY` - Where to mount the data device.

## Running the script

After changing/reviewing the configuration, we are good to go, and the
script can be run with:

```
$ amazon/install.sh
```

When the script finishes, the server should be already running the
bitcoin service and be in the process of downloading the blockchain
data from the network.

## Running single steps

If we just want to run a single installation step, we could use the
same script. Please look at the scripts for the available functions, but
for example:

Review generated bitcoin configuration with current values:

```
$ amazon/install.sh generate-bitcoin-config
```

Write the bitcoin configuration with the latest values and restart
the bitcoind service:

```
$ amazon/install.sh reconfigure-bitcoin
```
