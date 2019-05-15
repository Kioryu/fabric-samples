#!/usr/bin/env bash

MODE=$1

function logInfo() {
    echo "[ INFO ] $1"
}

function logHelp() {
    echo "<MODE>"
    echo "  1. setup.sh build"
    echo "  2. setup.sh run"
    echo "  3. setup.sh rm"
    echo
}

function remove() {
    logInfo "remove()"
    rm -rf channel-artifacts
    rm -rf crypto-config
    echo
}

function generateCerts() {
    logInfo "generateCerts()"
    ../bin/cryptogen generate --config=./crypto-config.yaml
    echo
}

function newGenesis() {
    logInfo "newGenesis()"
    ../bin/configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block
}

function newChannel() {
    logInfo "newChannel()"
    CHANNEL_NAME=channelall
    CHANNEL_PROFILE=ChannelAll

    ../bin/configtxgen -profile ${CHANNEL_PROFILE} -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID ${CHANNEL_NAME}
    ../bin/configtxgen -profile ${CHANNEL_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors_${CHANNEL_NAME}.tx -channelID ${CHANNEL_NAME} -asOrg Org1MSP
}

if [[ ${MODE} == "build" ]]; then
    mkdir channel-artifacts
    generateCerts
    newGenesis
    newChannel
elif [[ ${MODE} == "run" ]]; then
    sudo docker-compose -f docker-compose.yml up -d && \
    sudo docker exec -it cli bash
elif [[ ${MODE} == "rm" ]]; then
    sudo docker-compose -f docker-compose.yml down && \
    sudo docker rm $(docker ps -aq)
    remove
else
    logHelp
fi