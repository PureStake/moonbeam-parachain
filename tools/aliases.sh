#!/bin/bash

# Requires: sudo npm install -g @polkadot/api-cli
#
# 
#
#

# Alan is 5xxxx
# 1xxx for each type (relay vs parachain)
# 1xx for each node
# 42 for p2p
# 43 for http
# 44 for ws
if [ -z "$USER_PORT" ]; then
    export USER_PORT=30000
fi

export POLKADOT_PATH="$HOME/projects/polkadot"
export PARACHAIN_PATH="$HOME/projects/moonbeam-parachain"

export POLKADOT_BINARY="$POLKADOT_PATH/target/release/polkadot"
export PARACHAIN_BINARY="$PARACHAIN_PATH/target/release/moonbase-testnet"

export POLKADOT_SPEC_TEMPLATE="$PARACHAIN_PATH/specs/rococo-moonbeam-spec-template.json"
export POLKADOT_SPEC_PLAIN="$PARACHAIN_PATH/specs/rococo-moonbeam-spec-plain.json"
export POLKADOT_SPEC_RAW="$PARACHAIN_PATH/specs/rococo-moonbeam-spec-raw.json"

export PARACHAIN_SPEC_TEMPLATE="$PARACHAIN_PATH/specs/moonbase-testnet-parachain-spec-template.json"
export PARACHAIN_SPEC_PLAIN="$PARACHAIN_PATH/specs/moonbase-testnet-parachain-spec-plain.json"
export PARACHAIN_SPEC_RAW="$PARACHAIN_PATH/specs/moonbase-testnet-parachain-spec-raw.json"

alias relay_specs="echo ${POLKADOT_SPEC_TEMPLATE}; 
  $POLKADOT_BINARY build-spec --disable-default-bootnode --chain rococo-local  | grep '\"code\"' > /tmp/rococo.wasm
  sed -e '/\"<runtime_code>\"/{r /tmp/rococo.wasm' -e 'd}'  $POLKADOT_SPEC_TEMPLATE > $POLKADOT_SPEC_PLAIN
  echo $POLKADOT_SPEC_PLAIN generated
  $POLKADOT_BINARY build-spec --disable-default-bootnode --raw --chain $POLKADOT_SPEC_PLAIN > $POLKADOT_SPEC_RAW
  echo $POLKADOT_SPEC_RAW generated
  "
  
alias parachain_specs="echo ${PARACHAIN_SPEC_TEMPLATE}; 
  $PARACHAIN_BINARY build-spec --disable-default-bootnode  | grep '\"code\"' > /tmp/parachain.wasm
  sed -e '/\"<runtime_code>\"/{r /tmp/parachain.wasm' -e 'd}'  $PARACHAIN_SPEC_TEMPLATE > $PARACHAIN_SPEC_PLAIN
  echo $PARACHAIN_SPEC_PLAIN generated
  $PARACHAIN_BINARY build-spec --disable-default-bootnode --raw --chain $PARACHAIN_SPEC_PLAIN > $PARACHAIN_SPEC_RAW
  echo $PARACHAIN_SPEC_RAW generated
  "
export RELAY1_PORT=$((USER_PORT + 42))
alias relay1="
  echo 'charlie - p2p-port: $((RELAY1_PORT)), http-port: $((RELAY1_PORT + 1)) , ws-port: $((RELAY1_PORT + 2))';
  $POLKADOT_BINARY --chain $POLKADOT_SPEC_RAW \
    --node-key 1111111111111111111111111111111111111111111111111111111111111111 \
    --tmp \
    --execution Wasm \
    --port $((RELAY1_PORT)) \
    --rpc-port $((RELAY1_PORT + 1)) \
    --ws-port $((RELAY1_PORT + 2)) \
    --charlie \
    '-lrpc=trace'"

export RELAY2_PORT=$((RELAY1_PORT + 100))
alias relay2="
  echo 'bob - p2p-port: $((RELAY2_PORT)), http-port: $((RELAY2_PORT + 1)) , ws-port: $((RELAY2_PORT + 2))';
  $POLKADOT_BINARY --chain $POLKADOT_SPEC_RAW \
    --node-key 2222222222222222222222222222222222222222222222222222222222222222 \
    --tmp \
    --execution Wasm \
    --port $((RELAY2_PORT)) \
    --rpc-port $((RELAY2_PORT + 1)) \
    --ws-port $((RELAY2_PORT + 2)) \
    --bob \
    '-lrpc=trace' \
    --bootnodes /ip4/127.0.0.1/tcp/$((RELAY1_PORT))/p2p/12D3KooWPqT2nMDSiXUSx5D7fasaxhxKigVhcqfkKqrLghCq9jxz"

export PARACHAIN_WASM="$PARACHAIN_PATH/specs/parachain.wasm"
export PARACHAIN_GENESIS="$PARACHAIN_PATH/specs/parachain.genesis"

export PARACHAIN_PORT=$((USER_PORT + 1000 + 42))
alias parachain="
    echo 'parachain (1000) - p2p-port: $((PARACHAIN_PORT)), http-port: $((PARACHAIN_PORT + 1)) , ws-port: $((PARACHAIN_PORT + 2))';
    $PARACHAIN_BINARY export-genesis-wasm > $PARACHAIN_WASM; 
    $PARACHAIN_BINARY export-genesis-state --parachain-id 1000 --chain $PARACHAIN_SPEC_PLAIN > $PARACHAIN_GENESIS;
    $PARACHAIN_BINARY \
      --node-key 3333333333333333333333333333333333333333333333333333333333333333 \
      --port $((PARACHAIN_PORT)) \
      --rpc-port $((PARACHAIN_PORT + 1)) \
      --ws-port $((PARACHAIN_PORT + 2)) \
      --validator \
      --tmp \
      --execution Wasm \
      '-linfo,evm=trace,ethereum=trace,rpc=trace' \
      --chain $PARACHAIN_SPEC_PLAIN  \
      -- \
        --execution Wasm \
        --tmp \
        --bootnodes /ip4/127.0.0.1/tcp/$((RELAY1_PORT))/p2p/12D3KooWPqT2nMDSiXUSx5D7fasaxhxKigVhcqfkKqrLghCq9jxz \
        --bootnodes /ip4/127.0.0.1/tcp/$((RELAY2_PORT))/p2p/12D3KooWLdJAwPtyQ5RFnr9wGXsQzpf3P2SeqFbYkqbfVehLu4Ns \
        --chain $POLKADOT_SPEC_RAW"

export RPC_NODE_PORT=$((PARACHAIN_PORT + 100))
alias rpc_node="
    echo 'parachain (1000) - p2p-port: $((RPC_NODE_PORT)), http-port: $((RPC_NODE_PORT + 1)) , ws-port: $((RPC_NODE_PORT + 2))';
    $PARACHAIN_BINARY \
      --node-key 4444444444444444444444444444444444444444444444444444444444444444 \
      --port $((RPC_NODE_PORT)) \
      --rpc-port $((RPC_NODE_PORT + 1)) \
      --ws-port $((RPC_NODE_PORT + 2)) \
      --rpc-external \
      --tmp \
      --rpc-cors=all \
      --execution Wasm \
      '-linfo,evm=trace,ethereum=trace,rpc=trace' \
      --chain $PARACHAIN_SPEC_PLAIN  \
      --bootnodes /ip4/127.0.0.1/tcp/$((PARACHAIN_PORT))/p2p/12D3KooWBRFW3HkJCLKSWb4yG6iWRBpgNjbM4FFvNsL5T5JKTqrd \
      -- \
        --execution Wasm \
        --tmp \
        --port $((RPC_NODE_PORT + 10)) \
        --rpc-port $((RPC_NODE_PORT + 10 + 1)) \
        --ws-port $((RPC_NODE_PORT + 10 + 2)) \
        --bootnodes /ip4/127.0.0.1/tcp/$((RELAY1_PORT))/p2p/12D3KooWPqT2nMDSiXUSx5D7fasaxhxKigVhcqfkKqrLghCq9jxz \
        --bootnodes /ip4/127.0.0.1/tcp/$((RELAY2_PORT))/p2p/12D3KooWLdJAwPtyQ5RFnr9wGXsQzpf3P2SeqFbYkqbfVehLu4Ns \
        --chain $POLKADOT_SPEC_RAW"

alias register_parachain='
    [ -z "$SUDO_SEED" ] && echo "Missing SUDO_SEED" || 
    polkadot-js-api \
        --ws "ws://localhost:$((RELAY1_PORT + 2))" \
        --sudo \
        --seed "$SUDO_SEED" \
        tx.registrar.registerPara \
            1000 \
            "{\"scheduling\":\"Always\"}" \
            @"$PARACHAIN_WASM" \
            "$(cat $PARACHAIN_GENESIS)"
'