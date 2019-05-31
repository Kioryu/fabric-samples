#!/usr/bin/env bash

function fabricBuild(){
    sudo mkdir channel-artifacts

    fabricGenerateCerts

    fabricNewGenesis

    fabricNewChannel ${CHANNEL_ALL_PROFILE} ${CHANNEL_ALL_NAME}
    fabricNewMSP ${CHANNEL_ALL_PROFILE} ${CHANNEL_ALL_NAME} ${ORG1_MSP} ${ORG1_MSP_ANCHORS}
    fabricNewMSP ${CHANNEL_ALL_PROFILE} ${CHANNEL_ALL_NAME} ${ORG2_MSP} ${ORG2_MSP_ANCHORS}
    fabricNewMSP ${CHANNEL_ALL_PROFILE} ${CHANNEL_ALL_NAME} ${ORG3_MSP} ${ORG3_MSP_ANCHORS}

    fabricNewChannel ${CHANNEL_VIP_PROFILE} ${CHANNEL_VIP_NAME}
    fabricNewMSP ${CHANNEL_VIP_PROFILE} ${CHANNEL_VIP_NAME} ${ORG1_MSP} ${ORG1_MSP_ANCHORS}
    fabricNewMSP ${CHANNEL_VIP_PROFILE} ${CHANNEL_VIP_NAME} ${ORG2_MSP} ${ORG2_MSP_ANCHORS}

    fabricNewChannel ${CHANNEL_SECRET_PROFILE} ${CHANNEL_SECRET_NAME}
    fabricNewMSP ${CHANNEL_SECRET_PROFILE} ${CHANNEL_SECRET_NAME} ${ORG1_MSP} ${ORG1_MSP_ANCHORS}
}

function fabricRmDir(){
    sudo rm -rf channel-artifacts
    sudo rm -rf crypto-config
}

function fabricGenerateCerts(){
    ../bin/cryptogen generate --config=./crypto-config.yaml
}

function fabricNewGenesis() {
    ../bin/configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block
}

function fabricNewChannel() {
    CHANNEL_PROFILE=$1
    CHANNEL_NAME=$2

    ../bin/configtxgen -profile ${CHANNEL_PROFILE} -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID ${CHANNEL_NAME}
}

function fabricNewMSP(){
    CHANNEL_PROFILE=$1
    CHANNEL_NAME=$2
    ORG_MSP=$3
    ORG_MSP_ANCHORS=$4

    ../bin/configtxgen -profile ${CHANNEL_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/${ORG_MSP_ANCHORS}_${CHANNEL_NAME}.tx -channelID ${CHANNEL_NAME} -asOrg ${ORG_MSP}
}