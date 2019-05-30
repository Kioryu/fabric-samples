#!/usr/bin/env bash

CONFIG_ROOT=/opt/gopath/src/github.com/hyperledger/fabric/peer

ORG1_MSP=Org1MSP
ORG2_MSP=Org2MSP
ORG3_MSP=Org3MSP

ORG1_CORE_PEER_ADDRESS=peer0.org1.example.com:7051
ORG2_CORE_PEER_ADDRESS=peer0.org2.example.com:8051
ORG3_CORE_PEER_ADDRESS=peer0.org3.example.com:9051

ORG1_MSP_ANCHORS=Org1MSPanchors
ORG2_MSP_ANCHORS=Org2MSPanchors
ORG3_MSP_ANCHORS=Org3MSPanchors

CHANNEL_ALL_NAME=channelall
CHANNEL_ALL_PROFILE=ChannelAll

CHANNEL_VIP_NAME=channelvip
CHANNEL_VIP_PROFILE=ChannelVIP

CHANNEL_SECRET_NAME=channelsecret
CHANNEL_SECRET_PROFILE=ChannelSecret

ORG1_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
ORG2_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
ORG3_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp

ORG1_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
ORG2_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
ORG3_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt

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