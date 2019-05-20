#!/usr/bin/env bash

MODE=$1

libName="lib"
libPath="./${libName}"
libPermission=`sudo stat -c %a ${libPath}`

if [[ ${libPermission} -ne 711 ]];then
    chmod 711 ${libPath}
fi

. ./lib/log.sh
. ./lib/fabric.sh
. ./lib/docker.sh

if [[ ${MODE} == "build" ]]; then
    mkdir channel-artifacts
    generateCerts
    newGenesis
    newChannel
elif [[ ${MODE} == "run" ]]; then
    composeUP && \
    newChannelAll && \
    joinChannelAll && \
    updateChannelAll && \
    installContract && \
    instantiateContract && \
    conCli
elif [[ ${MODE} == "rm" ]]; then
    dockerFabricRemove
    fabDirRemove
else
    logHelp
fi