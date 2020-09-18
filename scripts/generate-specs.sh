#!/bin/bash

if [ -z "$PARACHAIN_BINARY" ]; then
    PARACHAIN_BINARY="target/release/moonbase-testnet"
fi

if [ -z "$PARACHAIN_SPEC_TEMPLATE" ]; then
    PARACHAIN_SPEC_TEMPLATE="specs/moonbase-testnet-parachain-spec-template.json"
fi

if [ -z "$PARACHAIN_SPEC_PLAIN" ]; then
    PARACHAIN_SPEC_PLAIN="specs/moonbase-testnet-parachain-spec-plain.json"
fi

if [ -z "$PARACHAIN_SPEC_RAW" ]; then
    PARACHAIN_SPEC_RAW="specs/moonbase-testnet-parachain-spec-raw.json"
fi

if [ -z "$PARACHAIN_SPEC_TMP" ]; then
    PARACHAIN_SPEC_TMP="/tmp/moonbase-testnet-specs-tpm.json"
fi

if [ -z "$PARACHAIN_WASM" ]; then
    PARACHAIN_WASM="specs/parachain.wasm"
fi

if [ -z "$PARACHAIN_GENESIS" ]; then
    PARACHAIN_GENESIS="specs/parachain.genesis"
fi

if [ -z "$PARACHAIN_ID" ]; then
    PARACHAIN_ID=1000
fi

echo $PARACHAIN_SPEC_TMP
$PARACHAIN_BINARY build-spec --disable-default-bootnode  | grep '\"code\"' > $PARACHAIN_SPEC_TMP

echo ${PARACHAIN_SPEC_TEMPLATE}
sed -e '/\"<runtime_code>\"/{r /tmp/parachain.wasm' -e 'd}'  $PARACHAIN_SPEC_TEMPLATE > $PARACHAIN_SPEC_PLAIN
echo $PARACHAIN_SPEC_PLAIN generated

$PARACHAIN_BINARY build-spec --disable-default-bootnode --raw --chain $PARACHAIN_SPEC_PLAIN > $PARACHAIN_SPEC_RAW
echo $PARACHAIN_SPEC_RAW generated

$PARACHAIN_BINARY export-genesis-wasm --chain $PARACHAIN_SPEC_PLAIN > $PARACHAIN_WASM; 
echo $PARACHAIN_WASM generated

$PARACHAIN_BINARY export-genesis-state --parachain-id $PARACHAIN_ID  --chain $PARACHAIN_SPEC_PLAIN > $PARACHAIN_GENESIS;
echo $PARACHAIN_GENESIS generated
   