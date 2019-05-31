#!/usr/bin/env bash

function dockerAttach() {
    PEER_LOCALMSPID=$1
    PEER_ADDRESS=$2
    PEER_MSPCONFIGPATH=$3
    PEER_TLS_ROOTCERT_FILE=$4
    PEER_TLS_CERT_FILE=$5
    PEER_TLS_KEY_FILE=$6

    sudo docker exec \
    -e CORE_PEER_LOCALMSPID=${PEER_LOCALMSPID} \
    -e CORE_PEER_ADDRESS=${PEER_ADDRESS} \
    -e CORE_PEER_MSPCONFIGPATH=${PEER_MSPCONFIGPATH} \
    -e CORE_PEER_TLS_CERT_FILE=${PEER_TLS_CERT_FILE} \
    -e CORE_PEER_TLS_KEY_FILE=${PEER_TLS_KEY_FILE} \
    -e CORE_PEER_TLS_ROOTCERT_FILE=${PEER_TLS_ROOTCERT_FILE} \
    -e ORDERER_CA=${ORDERER_CA} \
    -it \
    cli bash
}

function dockerNewChannel(){
    PEER_LOCALMSPID=$1
    PEER_ADDRESS=$2
    PEER_MSPCONFIGPATH=$3
    PEER_TLS_ROOTCERT_FILE=$4
    CHANNEL_NAME=$5
    PEER_TLS_CERT_FILE=$6
    PEER_TLS_KEY_FILE=$7

    sudo docker exec \
    -e CORE_PEER_LOCALMSPID=${PEER_LOCALMSPID} \
    -e CORE_PEER_ADDRESS=${PEER_ADDRESS} \
    -e CORE_PEER_MSPCONFIGPATH=${PEER_MSPCONFIGPATH} \
    -e CORE_PEER_TLS_ROOTCERT_FILE=${PEER_TLS_ROOTCERT_FILE} \
    -e CORE_PEER_TLS_CERT_FILE=${PEER_TLS_CERT_FILE} \
    -e CORE_PEER_TLS_KEY_FILE=${PEER_TLS_KEY_FILE} \
    cli \
    peer channel create \
    -o orderer.example.com:7050 \
    -c ${CHANNEL_NAME} \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.tx \
    --cafile ${ORDERER_CA} \
    --tls
}

function dockerJoinChannel(){
    CORE_PEER_LOCALMSPID=$1
    CORE_PEER_ADDRESS=$2
    CORE_PEER_MSPCONFIGPATH=$3
    CORE_PEER_TLS_ROOTCERT_FILE=$4
    CHANNEL_NAME=$5
    PEER_TLS_CERT_FILE=$6
    PEER_TLS_KEY_FILE=$7

    sudo docker exec \
    -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
    -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
    -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
    -e CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE} \
    -e CORE_PEER_TLS_CERT_FILE=${PEER_TLS_CERT_FILE} \
    -e CORE_PEER_TLS_KEY_FILE=${PEER_TLS_KEY_FILE} \
    cli \
    peer channel join \
    -b ${CHANNEL_NAME}.block \
    --cafile ${ORDERER_CA} \
    --tls
}

function dockerUpdateChannel(){
    CORE_PEER_LOCALMSPID=$1
    CORE_PEER_ADDRESS=$2
    CORE_PEER_MSPCONFIGPATH=$3
    CORE_PEER_TLS_ROOTCERT_FILE=$4
    CHANNEL_NAME=$5
    ORGMSPANCHORS=$6
    PEER_TLS_CERT_FILE=$7
    PEER_TLS_KEY_FILE=$8

    sudo docker exec \
    -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
    -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
    -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
    -e CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE} \
    -e CORE_PEER_TLS_CERT_FILE=${PEER_TLS_CERT_FILE} \
    -e CORE_PEER_TLS_KEY_FILE=${PEER_TLS_KEY_FILE} \
    cli \
    peer channel update \
    -o orderer.example.com:7050 \
    -c ${CHANNEL_NAME} \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${ORGMSPANCHORS}_${CHANNEL_NAME}.tx \
    --cafile ${ORDERER_CA} \
    --tls
}

function dockerCCinstall(){
    CORE_PEER_LOCALMSPID=$1
    CORE_PEER_ADDRESS=$2
    CORE_PEER_MSPCONFIGPATH=$3
    CORE_PEER_TLS_ROOTCERT_FILE=$4
    PEER_TLS_CERT_FILE=$5
    PEER_TLS_KEY_FILE=$6

    sudo docker exec \
    -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
    -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
    -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
    -e CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE} \
    -e CORE_PEER_TLS_CERT_FILE=${PEER_TLS_CERT_FILE} \
    -e CORE_PEER_TLS_KEY_FILE=${PEER_TLS_KEY_FILE} \
    cli \
    peer chaincode install \
    -n fabbank \
    -v 1.0 \
    -p github.com/chaincode/Fab-Bank \
    -l golang
}

function dockerCCinstantiate(){
    CORE_PEER_LOCALMSPID=$1
    CORE_PEER_ADDRESS=$2
    CORE_PEER_MSPCONFIGPATH=$3
    CORE_PEER_TLS_ROOTCERT_FILE=$4
    CHANNEL_NAME=$5
    PEER_TLS_CERT_FILE=$6
    PEER_TLS_KEY_FILE=$7

    sudo docker exec \
    -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
    -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
    -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
    -e CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE} \
    -e CORE_PEER_TLS_CERT_FILE=${PEER_TLS_CERT_FILE} \
    -e CORE_PEER_TLS_KEY_FILE=${PEER_TLS_KEY_FILE} \
    cli \
    peer chaincode instantiate \
    -o orderer.example.com:7050 \
    -C ${CHANNEL_NAME} \
    -c '{"Args":[]}' \
    -n fabbank \
    -v 1.0 \
    --cafile ${ORDERER_CA} \
    --tls
}
function dockerRmContainer(){
    str=$(sudo docker ps -a --format '{{.Names}}')
    dockerRm "container" ${str}
}

function dockerRmImage() {
    str=$(sudo docker image ls --format '{{.Repository}}')
    dockerRm "image" ${str}
}

function dockerImageRm() {
    v=$1
    sudo docker image rm ${v}
}

function dockerContainerRm() {
    v=$1
    sudo docker container rm ${v}
}

function dockerRm() {
    type=$1
    str=$2
    values=$(echo ${str} | tr " " "\n")

    for v in ${values}
    do
        if [[ "${v}" =~ "fabbank"  ]]; then
            if [[ ${type} == "container" ]]; then
                dockerContainerRm ${v}
            elif [[ ${type} == "image" ]]; then
                dockerImageRm ${v}
            fi
        fi
    done
}

function dockerRmVolume(){
    sudo docker volume rm $(sudo docker volume ls -qf dangling=true)
}

function dockerComposeUp(){
    sudo docker-compose -f docker-compose.yml up -d
}

function dockerComposeDown(){
    sudo docker-compose -f docker-compose.yml down
}