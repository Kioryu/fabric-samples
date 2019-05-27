#!/usr/bin/env bash

MODE=$1

CHANNEL_ALL_NAME=channelall
CHANNEL_ALL_PROFILE=ChannelAll

CHANNEL_VIP_NAME=channelvip
CHANNEL_VIP_PROFILE=ChannelVIP

CHANNEL_SECRET_NAME=channelsecret
CHANNEL_SECRET_PROFILE=ChannelSecret

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

    ../bin/configtxgen -profile ${CHANNEL_ALL_PROFILE} -outputCreateChannelTx ./channel-artifacts/${CHANNEL_ALL_NAME}.tx -channelID ${CHANNEL_ALL_NAME}

    ../bin/configtxgen -profile ${CHANNEL_ALL_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors_${CHANNEL_ALL_NAME}.tx -channelID ${CHANNEL_ALL_NAME} -asOrg Org1MSP
    ../bin/configtxgen -profile ${CHANNEL_ALL_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors_${CHANNEL_ALL_NAME}.tx -channelID ${CHANNEL_ALL_NAME} -asOrg Org2MSP
    ../bin/configtxgen -profile ${CHANNEL_ALL_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors_${CHANNEL_ALL_NAME}.tx -channelID ${CHANNEL_ALL_NAME} -asOrg Org3MSP

    ../bin/configtxgen -profile ${CHANNEL_VIP_PROFILE} -outputCreateChannelTx ./channel-artifacts/${CHANNEL_VIP_NAME}.tx -channelID ${CHANNEL_VIP_NAME}

    ../bin/configtxgen -profile ${CHANNEL_VIP_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors_${CHANNEL_VIP_NAME}.tx -channelID ${CHANNEL_VIP_NAME} -asOrg Org1MSP
    ../bin/configtxgen -profile ${CHANNEL_VIP_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors_${CHANNEL_VIP_NAME}.tx -channelID ${CHANNEL_VIP_NAME} -asOrg Org2MSP

    ../bin/configtxgen -profile ${CHANNEL_SECRET_PROFILE} -outputCreateChannelTx ./channel-artifacts/${CHANNEL_SECRET_NAME}.tx -channelID ${CHANNEL_SECRET_NAME}

    ../bin/configtxgen -profile ${CHANNEL_SECRET_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors_${CHANNEL_SECRET_NAME}.tx -channelID ${CHANNEL_SECRET_NAME} -asOrg Org1MSP
}

if [[ ${MODE} == "rm" ]]; then
    rm -rf crypto-config
    rm -rf channel-artifacts
elif [[ ${MODE} == "build" ]]; then
    main
else
    helpOptions
fi