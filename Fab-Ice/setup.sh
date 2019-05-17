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
    sudo rm -rf channel-artifacts
    sudo rm -rf crypto-config
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
    ORDERER_CA="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
    sudo docker-compose -f docker-compose.yml up -d && \

    sudo docker exec \
    cli \
    peer channel create \
    -o orderer.example.com:7050 \
    -c channelall \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/channelall.tx \
    --cafile ${ORDERER_CA} && \

    sudo docker exec \
    cli \
    peer channel join \
    -b channelall.block \
    --cafile ${ORDERER_CA} && \

    sudo docker exec \
    cli \
    peer channel update \
    -o orderer.example.com:7050 \
    -c channelall \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/Org1MSPanchors_channelall.tx \
    --cafile ${ORDERER_CA} && \

     sudo docker exec \
     -e ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
     -it \
     cli bash
elif [[ ${MODE} == "rm" ]]; then
    sudo docker-compose -f docker-compose.yml down && \
    sudo docker rm $(sudo docker ps -aq)
    sudo docker volume rm $(sudo docker volume ls -qf dangling=true)
    remove
else
    logHelp
fi