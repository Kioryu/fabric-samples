#!/usr/bin/env bash

function fabDirRemove() {
    logInfo "remove()"
    sudo rm -rf channel-artifacts
    sudo rm -rf crypto-config
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