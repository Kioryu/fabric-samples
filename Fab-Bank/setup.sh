#!/usr/bin/env bash

MODE=$1

function infoLog(){
    echo "[INFO] : $1"
}

function helpOptions(){
    echo "=================="
    echo "1. setup.sh build"
    echo "2. setup.sh rm"
    echo "=================="
}

function main() {
    mkdir channel-artifacts

    ../bin/cryptogen generate --config=./crypto-config.yaml

    ../bin/configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block
}

if [[ ${MODE} == "rm" ]]; then
    rm -rf crypto-config
    rm -rf channel-artifacts
elif [[ ${MODE} == "build" ]]; then
    main
else
    helpOptions
fi