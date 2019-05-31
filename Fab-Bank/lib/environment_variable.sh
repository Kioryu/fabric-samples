#!/usr/bin/env bash

export CONFIG_ROOT=/opt/gopath/src/github.com/hyperledger/fabric/peer

export ORDERER_CA=${CONFIG_ROOT}/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export ORG1_MSP=Org1MSP
export ORG2_MSP=Org2MSP
export ORG3_MSP=Org3MSP

export ORG1_CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export ORG2_CORE_PEER_ADDRESS=peer0.org2.example.com:8051
export ORG3_CORE_PEER_ADDRESS=peer0.org3.example.com:9051

export ORG1_MSP_ANCHORS=Org1MSPanchors
export ORG2_MSP_ANCHORS=Org2MSPanchors
export ORG3_MSP_ANCHORS=Org3MSPanchors

export CHANNEL_ALL_NAME=channelall
export CHANNEL_ALL_PROFILE=ChannelAll

export CHANNEL_VIP_NAME=channelvip
export CHANNEL_VIP_PROFILE=ChannelVIP

export CHANNEL_SECRET_NAME=channelsecret
export CHANNEL_SECRET_PROFILE=ChannelSecret

export ORG1_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export ORG2_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export ORG3_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp

export ORG1_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export ORG2_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export ORG3_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt

export PEER1_TLS_CERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
export PEER2_TLS_CERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt
export PEER3_TLS_CERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/server.crt

export PEER1_TLS_KEY_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
export PEER2_TLS_KEY_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key
export PEER3_TLS_KEY_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/server.key