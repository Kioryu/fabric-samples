#!/usr/bin/env bash

function logInfo(){
    echo "[INFO] : $1"
}

function logHelp(){
    echo "=================="
    echo "1. setup.sh build"
    echo "2. setup.sh run"
    echo "3. setup.sh attach <peerNumber>"
    echo "4. setup.sh rm"
    echo "=================="
}

function logAttachHelp() {
    echo "=================="
    echo "setup.sh attach <peerNumber>"
    echo "=================="
}