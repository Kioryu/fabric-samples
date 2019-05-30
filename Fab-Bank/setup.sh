#!/usr/bin/env bash

# cli options [ ex> ./setup.sh [option] ]
MODE=$1

# init
function checkLibPermission(){
    libName="lib"
    libPath="./${libName}"
    libPermission=`sudo stat -c %a ${libPath}`
    if [[ ${libPermission} -ne 711 ]];then
        sudo chmod -R 711 ${libPath}
    fi
}

checkLibPermission

# import
. ./lib/fabric.sh
. ./lib/docker.sh
. ./lib/log.sh


# main
if [[ ${MODE} == "build" ]]; then
    fabricBuild
elif [[ ${MODE} == "run" ]]; then
    dockerComposeUp

    # ORG1
    echo "---------- ORG1 ${CHANNEL_ALL_PROFILE} ---------- "
    dockerNewChannel ${ORG1_MSP} ${ORG1_CORE_PEER_ADDRESS} ${ORG1_MSPCONFIGPATH} ${ORG1_TLS_ROOTCERT_FILE} ${CHANNEL_ALL_NAME}
    dockerJoinChannel ${ORG1_MSP} ${ORG1_CORE_PEER_ADDRESS} ${ORG1_MSPCONFIGPATH} ${ORG1_TLS_ROOTCERT_FILE} ${CHANNEL_ALL_NAME}
    dockerUpdateChannel ${ORG1_MSP} ${ORG1_CORE_PEER_ADDRESS} ${ORG1_MSPCONFIGPATH} ${ORG1_TLS_ROOTCERT_FILE} ${CHANNEL_ALL_NAME} ${ORG1_MSP_ANCHORS}
    echo "---------- ORG1 ${CHANNEL_VIP_PROFILE} ---------- "
    dockerNewChannel ${ORG1_MSP} ${ORG1_CORE_PEER_ADDRESS} ${ORG1_MSPCONFIGPATH} ${ORG1_TLS_ROOTCERT_FILE} ${CHANNEL_VIP_NAME}
    dockerJoinChannel ${ORG1_MSP} ${ORG1_CORE_PEER_ADDRESS} ${ORG1_MSPCONFIGPATH} ${ORG1_TLS_ROOTCERT_FILE} ${CHANNEL_VIP_NAME}
    dockerUpdateChannel ${ORG1_MSP} ${ORG1_CORE_PEER_ADDRESS} ${ORG1_MSPCONFIGPATH} ${ORG1_TLS_ROOTCERT_FILE} ${CHANNEL_VIP_NAME} ${ORG1_MSP_ANCHORS}
    echo "---------- ORG1 ${CHANNEL_SECRET_PROFILE} ---------- "
    dockerNewChannel ${ORG1_MSP} ${ORG1_CORE_PEER_ADDRESS} ${ORG1_MSPCONFIGPATH} ${ORG1_TLS_ROOTCERT_FILE} ${CHANNEL_SECRET_NAME}
    dockerJoinChannel ${ORG1_MSP} ${ORG1_CORE_PEER_ADDRESS} ${ORG1_MSPCONFIGPATH} ${ORG1_TLS_ROOTCERT_FILE} ${CHANNEL_SECRET_NAME}
    dockerUpdateChannel ${ORG1_MSP} ${ORG1_CORE_PEER_ADDRESS} ${ORG1_MSPCONFIGPATH} ${ORG1_TLS_ROOTCERT_FILE} ${CHANNEL_SECRET_NAME} ${ORG1_MSP_ANCHORS}
    echo "---------- ORG1 INSTALL FAB-BANK ---------- "
    dockerCCinstall ${ORG1_MSP} ${ORG1_CORE_PEER_ADDRESS} ${ORG1_MSPCONFIGPATH} ${ORG1_TLS_ROOTCERT_FILE}
    echo "---------- ORG1 INSTANTIATE FAB-BANK ${CHANNEL_ALL_PROFILE} ---------- "
    dockerCCinstantiate ${ORG1_MSP} ${ORG1_CORE_PEER_ADDRESS} ${ORG1_MSPCONFIGPATH} ${ORG1_TLS_ROOTCERT_FILE} ${CHANNEL_ALL_NAME}
    echo "---------- ORG1 INSTANTIATE FAB-BANK ${CHANNEL_VIP_PROFILE} ---------- "
    dockerCCinstantiate ${ORG1_MSP} ${ORG1_CORE_PEER_ADDRESS} ${ORG1_MSPCONFIGPATH} ${ORG1_TLS_ROOTCERT_FILE} ${CHANNEL_VIP_NAME}
    echo "---------- ORG1 INSTANTIATE FAB-BANK ${CHANNEL_SECRET_PROFILE} ---------- "
    dockerCCinstantiate ${ORG1_MSP} ${ORG1_CORE_PEER_ADDRESS} ${ORG1_MSPCONFIGPATH} ${ORG1_TLS_ROOTCERT_FILE} ${CHANNEL_SECRET_NAME}

    # ORG2
    echo "---------- ORG2 ${CHANNEL_ALL_PROFILE} ---------- "
    dockerJoinChannel ${ORG2_MSP} ${ORG2_CORE_PEER_ADDRESS} ${ORG2_MSPCONFIGPATH} ${ORG2_TLS_ROOTCERT_FILE} ${CHANNEL_ALL_NAME}
    dockerUpdateChannel ${ORG2_MSP} ${ORG2_CORE_PEER_ADDRESS} ${ORG2_MSPCONFIGPATH} ${ORG2_TLS_ROOTCERT_FILE} ${CHANNEL_ALL_NAME} ${ORG2_MSP_ANCHORS}
    echo "---------- ORG2 ${CHANNEL_VIP_PROFILE} ---------- "
    dockerJoinChannel ${ORG2_MSP} ${ORG2_CORE_PEER_ADDRESS} ${ORG2_MSPCONFIGPATH} ${ORG2_TLS_ROOTCERT_FILE} ${CHANNEL_VIP_NAME}
    dockerUpdateChannel ${ORG2_MSP} ${ORG2_CORE_PEER_ADDRESS} ${ORG2_MSPCONFIGPATH} ${ORG2_TLS_ROOTCERT_FILE} ${CHANNEL_VIP_NAME} ${ORG2_MSP_ANCHORS}
    echo "---------- ORG2 INSTALL FAB-BANK ---------- "
    dockerCCinstall ${ORG2_MSP} ${ORG2_CORE_PEER_ADDRESS} ${ORG2_MSPCONFIGPATH} ${ORG2_TLS_ROOTCERT_FILE}

    # ORG3
    echo "---------- ORG3 ${CHANNEL_ALL_PROFILE} ---------- "
    dockerJoinChannel ${ORG3_MSP} ${ORG3_CORE_PEER_ADDRESS} ${ORG3_MSPCONFIGPATH} ${ORG3_TLS_ROOTCERT_FILE} ${CHANNEL_ALL_NAME}
    dockerUpdateChannel ${ORG3_MSP} ${ORG3_CORE_PEER_ADDRESS} ${ORG3_MSPCONFIGPATH} ${ORG3_TLS_ROOTCERT_FILE} ${CHANNEL_ALL_NAME} ${ORG3_MSP_ANCHORS}
    echo "---------- ORG3 INSTALL FAB-BANK ---------- "
    dockerCCinstall ${ORG3_MSP} ${ORG3_CORE_PEER_ADDRESS} ${ORG3_MSPCONFIGPATH} ${ORG3_TLS_ROOTCERT_FILE}

elif [[ ${MODE} == "rm" ]]; then
    dockerComposeDown
    fabricRmDir
    dockerRmContainer
    dockerRmImage
    dockerRmVolume
elif [[ ${MODE} == "attach" ]]; then
    USER=$2
    if [[ ${USER} == "1" ]]; then
        dockerAttach ${ORG1_MSP} ${ORG1_CORE_PEER_ADDRESS} ${ORG1_MSPCONFIGPATH} ${ORG1_TLS_ROOTCERT_FILE}
    elif [[ ${USER} == "2" ]]; then
        dockerAttach ${ORG2_MSP} ${ORG2_CORE_PEER_ADDRESS} ${ORG2_MSPCONFIGPATH} ${ORG2_TLS_ROOTCERT_FILE}
    elif [[ ${USER} == "3" ]]; then
        dockerAttach ${ORG3_MSP} ${ORG3_CORE_PEER_ADDRESS} ${ORG3_MSPCONFIGPATH} ${ORG3_TLS_ROOTCERT_FILE}
    else
        logAttachHelp
    fi

else
    logHelp
fi