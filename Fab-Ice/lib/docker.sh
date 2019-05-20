#!/usr/bin/env bash

ORDERER_CA="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

function composeUP() {
    sudo docker-compose -f docker-compose.yml up -d
}

function newChannelAll() {
    sudo docker exec \
    cli \
    peer channel create \
    -o orderer.example.com:7050 \
    -c channelall \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/channelall.tx \
    --cafile ${ORDERER_CA}
}

function joinChannelAll() {
    sudo docker exec \
    cli \
    peer channel join \
    -b channelall.block \
    --cafile ${ORDERER_CA}
}

function updateChannelAll() {
    sudo docker exec \
    cli \
    peer channel update \
    -o orderer.example.com:7050 \
    -c channelall \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/Org1MSPanchors_channelall.tx \
    --cafile ${ORDERER_CA}
}

function conCli() {
    sudo docker exec \
     -e ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
     -it \
     cli bash
}

function installContract() {
    sudo docker exec \
    cli \
    peer chaincode install \
    -n fabice \
    -v 1.0 \
    -p github.com/chaincode/Fab-Ice \
    -l golang
}

function instantiateContract() {
    sudo docker exec \
    cli \
    peer chaincode instantiate \
    -o orderer.example.com:7050 \
    --cafile ${ORDERER_CA} \
    -C channelall \
    -c '{"Args":[]}' \
    -n fabice \
    -v 1.0
}

function imageRm() {
    v=$1
    sudo docker image rm ${v}
}

function containerRm() {
    v=$1
    sudo docker container rm ${v}
}

function dockerRm() {
    type=$1
    str=$2
    values=$(echo ${str} | tr " " "\n")

    for v in ${values}
    do
        if [[ "${v}" =~ "fabice"  ]]; then
            if [[ ${type} == "container" ]]; then
                containerRm ${v}
            elif [[ ${type} == "image" ]]; then
                imageRm ${v}
            fi
        fi
    done
}

function fabIceRmContainer() {
    str=$(sudo docker ps -a --format '{{.Names}}')
    dockerRm "container" ${str}
}

function fabIceRmImage() {
    str=$(sudo docker image ls --format '{{.Repository}}')
    dockerRm "image" ${str}
}

function dockerFabricRemove() {
     sudo docker-compose -f docker-compose.yml down && \
    fabIceRmContainer
    fabIceRmImage
    sudo docker volume rm $(sudo docker volume ls -qf dangling=true)
}