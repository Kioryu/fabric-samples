#!/usr/bin/env bash

MODE=$1

CHANNEL_ALL_NAME=channelall
CHANNEL_ALL_PROFILE=ChannelAll

CHANNEL_VIP_NAME=channelvip
CHANNEL_VIP_PROFILE=ChannelVIP

CHANNEL_SECRET_NAME=channelsecret
CHANNEL_SECRET_PROFILE=ChannelSecret

ORDERER_CA="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
CONFIG_ROOT=/opt/gopath/src/github.com/hyperledger/fabric/peer

function infoLog(){
    echo "[INFO] : $1"
}

function helpOptions(){
    echo "=================="
    echo "1. setup.sh build"
    echo "2. setup.sh run"
    echo "3. setup.sh attach <peerNumber>"
    echo "4. setup.sh rm"
    echo "=================="
}

function build() {
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

function peerDockerExec(){
    PEER=$1

    if [[ ${PEER} == "1" ]]; then
        ORG1_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
        CORE_PEER_LOCALMSPID=Org1MSP
        CORE_PEER_ADDRESS=peer0.org1.example.com:7051
        CORE_PEER_MSPCONFIGPATH=${ORG1_MSPCONFIGPATH}
        ORGMSPANCHORS=Org1MSPanchors

        # channel all
        sudo docker exec \
        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
        cli \
        peer channel create \
        -o orderer.example.com:7050 \
        -c ${CHANNEL_ALL_NAME} \
        -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_ALL_NAME}.tx \
        --cafile ${ORDERER_CA}

        sudo docker exec \
        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
        cli \
        peer channel join \
        -b ${CHANNEL_ALL_NAME}.block \
        --cafile ${ORDERER_CA}

        sudo docker exec \
        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
        cli \
        peer channel update \
        -o orderer.example.com:7050 \
        -c ${CHANNEL_ALL_NAME} \
        -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${ORGMSPANCHORS}_${CHANNEL_ALL_NAME}.tx \
        --cafile ${ORDERER_CA}

        # channel vip
        sudo docker exec \
        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
        cli \
        peer channel create \
        -o orderer.example.com:7050 \
        -c ${CHANNEL_VIP_NAME} \
        -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_VIP_NAME}.tx \
        --cafile ${ORDERER_CA}

        sudo docker exec \
        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
        cli \
        peer channel join \
        -b ${CHANNEL_VIP_NAME}.block \
        --cafile ${ORDERER_CA}

        sudo docker exec \
        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
        cli \
        peer channel update \
        -o orderer.example.com:7050 \
        -c ${CHANNEL_VIP_NAME} \
        -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${ORGMSPANCHORS}_${CHANNEL_VIP_NAME}.tx \
        --cafile ${ORDERER_CA}

        # channel secret
        sudo docker exec \
        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
        cli \
        peer channel create \
        -o orderer.example.com:7050 \
        -c ${CHANNEL_SECRET_NAME} \
        -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_SECRET_NAME}.tx \
        --cafile ${ORDERER_CA}

        sudo docker exec \
        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
        cli \
        peer channel join \
        -b ${CHANNEL_SECRET_NAME}.block \
        --cafile ${ORDERER_CA}

        sudo docker exec \
        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
        cli \
        peer channel update \
        -o orderer.example.com:7050 \
        -c ${CHANNEL_SECRET_NAME} \
        -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${ORGMSPANCHORS}_${CHANNEL_SECRET_NAME}.tx \
        --cafile ${ORDERER_CA}

        # deploy ChainCode !!
        sudo docker exec \
            -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
            -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
            -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
            cli \
            peer chaincode install \
            -n fabbank \
            -v 1.0 \
            -p github.com/chaincode/Fab-Bank \
            -l golang

        sudo docker exec \
            -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
            -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
            -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
            cli \
            peer chaincode instantiate \
            -o orderer.example.com:7050 \
            --cafile ${ORDERER_CA} \
            -C ${CHANNEL_ALL_NAME} \
            -c '{"Args":[]}' \
            -n fabbank \
            -v 1.0

        sudo docker exec \
            -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
            -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
            -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
            cli \
            peer chaincode instantiate \
            -o orderer.example.com:7050 \
            --cafile ${ORDERER_CA} \
            -C ${CHANNEL_VIP_NAME} \
            -c '{"Args":[]}' \
            -n fabbank \
            -v 1.0

        sudo docker exec \
            -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
            -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
            -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
            cli \
            peer chaincode instantiate \
            -o orderer.example.com:7050 \
            --cafile ${ORDERER_CA} \
            -C ${CHANNEL_SECRET_NAME} \
            -c '{"Args":[]}' \
            -n fabbank \
            -v 1.0

    elif [[ ${PEER} == "2" ]]; then
        ORG2_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
        CORE_PEER_LOCALMSPID=Org2MSP
        CORE_PEER_ADDRESS=peer0.org2.example.com:8051
        CORE_PEER_MSPCONFIGPATH=${ORG2_MSPCONFIGPATH}
        ORGMSPANCHORS=Org2MSPanchors

        # channel all
#        sudo docker exec \
#        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
#        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
#        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
#        cli \
#        peer channel create \
#        -o orderer.example.com:7050 \
#        -c ${CHANNEL_ALL_NAME} \
#        -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_ALL_NAME}.tx \
#        --cafile ${ORDERER_CA}

        sudo docker exec \
        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
        cli \
        peer channel join \
        -b ${CHANNEL_ALL_NAME}.block \
        --cafile ${ORDERER_CA}

        sudo docker exec \
        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
        cli \
        peer channel update \
        -o orderer.example.com:7050 \
        -c ${CHANNEL_ALL_NAME} \
        -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${ORGMSPANCHORS}_${CHANNEL_ALL_NAME}.tx \
        --cafile ${ORDERER_CA}

        # channel vip
#        sudo docker exec \
#        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
#        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
#        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
#        cli \
#        peer channel create \
#        -o orderer.example.com:7050 \
#        -c ${CHANNEL_VIP_NAME} \
#        -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_VIP_NAME}.tx \
#        --cafile ${ORDERER_CA}

        sudo docker exec \
        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
        cli \
        peer channel join \
        -b ${CHANNEL_VIP_NAME}.block \
        --cafile ${ORDERER_CA}

        sudo docker exec \
        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
        cli \
        peer channel update \
        -o orderer.example.com:7050 \
        -c ${CHANNEL_VIP_NAME} \
        -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${ORGMSPANCHORS}_${CHANNEL_VIP_NAME}.tx \
        --cafile ${ORDERER_CA}

        # deploy ChainCode
        sudo docker exec \
            -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
            -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
            -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
            cli \
            peer chaincode install \
            -n fabbank \
            -v 1.0 \
            -p github.com/chaincode/Fab-Bank \
            -l golang

    elif [[ ${PEER} == "3" ]]; then
        ORG3_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
        CORE_PEER_LOCALMSPID=Org3MSP
        CORE_PEER_ADDRESS=peer0.org3.example.com:9051
        CORE_PEER_MSPCONFIGPATH=${ORG3_MSPCONFIGPATH}
        ORGMSPANCHORS=Org3MSPanchors

        # channel all
#        sudo docker exec \
#        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
#        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
#        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
#        cli \
#        peer channel create \
#        -o orderer.example.com:7050 \
#        -c ${CHANNEL_ALL_NAME} \
#        -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_ALL_NAME}.tx \
#        --cafile ${ORDERER_CA}

        sudo docker exec \
        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
        cli \
        peer channel join \
        -b ${CHANNEL_ALL_NAME}.block \
        --cafile ${ORDERER_CA}

        sudo docker exec \
        -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
        -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
        -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
        cli \
        peer channel update \
        -o orderer.example.com:7050 \
        -c ${CHANNEL_ALL_NAME} \
        -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${ORGMSPANCHORS}_${CHANNEL_ALL_NAME}.tx \
        --cafile ${ORDERER_CA}

        # deploy ChainCode
        sudo docker exec \
            -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
            -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
            -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
            cli \
            peer chaincode install \
            -n fabbank \
            -v 1.0 \
            -p github.com/chaincode/Fab-Bank \
            -l golang

    fi
}

function attachDocker() {
    PEER=$1
    if [[ ${PEER} == "1" ]]; then
        ORG1_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
        CORE_PEER_LOCALMSPID=Org1MSP
        CORE_PEER_ADDRESS=peer0.org1.example.com:7051
        CORE_PEER_MSPCONFIGPATH=${ORG1_MSPCONFIGPATH}

    elif [[ ${PEER} == "2" ]]; then
        ORG2_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
        CORE_PEER_LOCALMSPID=Org2MSP
        CORE_PEER_ADDRESS=peer0.org2.example.com:8051
        CORE_PEER_MSPCONFIGPATH=${ORG2_MSPCONFIGPATH}

    elif [[ ${PEER} == "3" ]]; then
        ORG3_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
        CORE_PEER_LOCALMSPID=Org3MSP
        CORE_PEER_ADDRESS=peer0.org3.example.com:9051
        CORE_PEER_MSPCONFIGPATH=${ORG3_MSPCONFIGPATH}
    else
        return
    fi


    sudo docker exec \
     -e CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID} \
     -e CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS} \
     -e CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH} \
     -e ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
     -it \
     cli bash
}

function run() {
    docker-compose -f docker-compose.yml up -d

    peerDockerExec 1 && \
    peerDockerExec 2 && \
    peerDockerExec 3
}

if [[ ${MODE} == "rm" ]]; then
    docker-compose down
    docker volume rm $(docker volume ls -qf dangling=true)
    rm -rf crypto-config
    rm -rf channel-artifacts
elif [[ ${MODE} == "build" ]]; then
    build
elif [[ ${MODE} == "run" ]]; then
    run
elif [[ ${MODE} == "attach" ]]; then
    attachDocker $2
else
    helpOptions
fi
