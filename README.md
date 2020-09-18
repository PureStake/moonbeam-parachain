Those are the steps to reproduce it.
The scenario requires:
* 2 polkadot node for the relay
* 1 collator for the parachain
* multiple parachain node (no --validator)

 For simplicity, the relay node and specs are already compiled (linux) and included in the branch.
 (otherwise clone polkadot@26f1fa47 and `cargo build --release` it )


## Building the relay

```
git clone https://github.com/paritytech/polkadot
git checkout 26f1fa47
cargo build --release
```

copy the `target/release/polkadot` into moonbeam-parachain `relay` folder


## Running the 2 relays
relay 1:
```
relay/polkadot --chain specs/rococo-moonbeam-spec-raw.json \
  --node-key 1111111111111111111111111111111111111111111111111111111111111111 \
  --tmp \
  --port 55042 \
  --rpc-port 55043 \
  --ws-port 55044 \
  --charlie \
  '-linfo,evm=trace,ethereum=trace,rpc=trace'
```

relay 2:
```
relay/polkadot --chain specs/rococo-moonbeam-spec-raw.json \
  --node-key 2222222222222222222222222222222222222222222222222222222222222222 \
  --tmp \
  --port 55142 \
  --rpc-port 55143 \
  --ws-port 55144 \
  --charlie \
  '-linfo,evm=trace,ethereum=trace,rpc=trace' \
  --bootnodes /ip4/127.0.0.1/tcp/55042/p2p/12D3KooWPqT2nMDSiXUSx5D7fasaxhxKigVhcqfkKqrLghCq9jxz
```

## Getting the parachain

First you need to build it
```
cargo build --release
```

Generating the wasm and genesis state

```
target/release/moonbase-testnet export-genesis-wasm > specs/parachain.wasm
target/release/moonbase-testnet export-genesis-state --parachain-id 1000 --chain specs/moonbase-testnet-parachain-spec-plain.json > specs/parachain.genesis
```

## Running the parachain collator
```
target/release/moonbase-testnet \
  --node-key 3333333333333333333333333333333333333333333333333333333333333333 \
  --port 56042 \
  --rpc-port 56043 \
  --ws-port 56044 \
  --validator \
  --tmp \
  '-linfo,evm=trace,ethereum=trace,rpc=trace,state=trace' \
  --chain specs/moonbase-testnet-parachain-spec-plain.json \
  -- \
    --tmp \
    --port 56052 \
    --rpc-port 56053 \
    --ws-port 56054 \
    --bootnodes /ip4/127.0.0.1/tcp/55042/p2p/12D3KooWPqT2nMDSiXUSx5D7fasaxhxKigVhcqfkKqrLghCq9jxz \
    --bootnodes /ip4/127.0.0.1/tcp/55142/p2p/12D3KooWLdJAwPtyQ5RFnr9wGXsQzpf3P2SeqFbYkqbfVehLu4Ns \
    --chain specs/rococo-moonbeam-spec-raw.json
```

## Running the parachain rpc nodes
node 1:
```
target/release/moonbase-testnet \
  --node-key 4444444444444444444444444444444444444444444444444444444444444444 \
  --port 56142 \
  --rpc-port 56143 \
  --ws-port 56144 \
  --rpc-external \
  --tmp \
  --rpc-cors=all \
  '-linfo,evm=trace,ethereum=trace,rpc=trace,state=trace' \
  --chain specs/moonbase-testnet-parachain-spec-plain.json \
  --bootnodes /ip4/127.0.0.1/tcp/56042/p2p/12D3KooWBRFW3HkJCLKSWb4yG6iWRBpgNjbM4FFvNsL5T5JKTqrd \
  -- \
    --tmp \
    --port 56152 \
    --rpc-port 56153 \
    --ws-port 56154 \
    --bootnodes /ip4/127.0.0.1/tcp/55042/p2p/12D3KooWPqT2nMDSiXUSx5D7fasaxhxKigVhcqfkKqrLghCq9jxz \
    --bootnodes /ip4/127.0.0.1/tcp/55142/p2p/12D3KooWLdJAwPtyQ5RFnr9wGXsQzpf3P2SeqFbYkqbfVehLu4Ns \
    --chain specs/rococo-moonbeam-spec-raw.json
```

It is suggested to use `2> rpc_node1.log` for the nodes to reduce the visual log and spot faster when it fails.

node 2:
```
target/release/moonbase-testnet \
  --node-key 5555555555555555555555555555555555555555555555555555555555555555 \
  --port 56242 \
  --rpc-port 56243 \
  --ws-port 56244 \
  --rpc-external \
  --tmp \
  --rpc-cors=all \
  '-linfo,evm=trace,ethereum=trace,rpc=trace,state=trace' \
  --chain specs/moonbase-testnet-parachain-spec-plain.json \
  --bootnodes /ip4/127.0.0.1/tcp/56042/p2p/12D3KooWBRFW3HkJCLKSWb4yG6iWRBpgNjbM4FFvNsL5T5JKTqrd \
  -- \
    --tmp \
    --port 56252 \
    --rpc-port 56253 \
    --ws-port 56254 \
    --bootnodes /ip4/127.0.0.1/tcp/55042/p2p/12D3KooWPqT2nMDSiXUSx5D7fasaxhxKigVhcqfkKqrLghCq9jxz \
    --bootnodes /ip4/127.0.0.1/tcp/55142/p2p/12D3KooWLdJAwPtyQ5RFnr9wGXsQzpf3P2SeqFbYkqbfVehLu4Ns \
    --chain specs/rococo-moonbeam-spec-raw.json
```

node 3:
```
target/release/moonbase-testnet \
  --node-key 6666666666666666666666666666666666666666666666666666666666666666 \
  --port 56342 \
  --rpc-port 56343 \
  --ws-port 56344 \
  --rpc-external \
  --tmp \
  --rpc-cors=all \
  '-linfo,evm=trace,ethereum=trace,rpc=trace,state=trace' \
  --chain specs/moonbase-testnet-parachain-spec-plain.json \
  --bootnodes /ip4/127.0.0.1/tcp/56042/p2p/12D3KooWBRFW3HkJCLKSWb4yG6iWRBpgNjbM4FFvNsL5T5JKTqrd \
  -- \
    --tmp \
    --port 56352 \
    --rpc-port 56353 \
    --ws-port 56354 \
    --bootnodes /ip4/127.0.0.1/tcp/55042/p2p/12D3KooWPqT2nMDSiXUSx5D7fasaxhxKigVhcqfkKqrLghCq9jxz \
    --bootnodes /ip4/127.0.0.1/tcp/55142/p2p/12D3KooWLdJAwPtyQ5RFnr9wGXsQzpf3P2SeqFbYkqbfVehLu4Ns \
    --chain specs/rococo-moonbeam-spec-raw.json
```


## Register the parachain:

Installing the dependencies:
```
cd tools && npm install
```

### Registration
From within the `tools` folder
```
node_modules/.bin/polkadot-js-api \
--ws "ws://localhost:55044" \
--sudo \
--seed "0xe5be9a5092b81bca64be81d212e7f2f9eba183bb7a90954f7b76361f6edb5c0a" \
  tx.registrar.registerPara \
    1000 \
    "{\"scheduling\":\"Always\"}" \
    @../specs/parachain.wasm \
    "$(cat ../specs/parachain.genesis)"
```


### Running the tests
From within the `tools` folder

`node moonbeam_test/testscript.js `

In order to reproduce the bug, you need to keep running this script, until it fails