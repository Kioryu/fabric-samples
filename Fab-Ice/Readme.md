# Fab-Ice
- 아이스크림 소유권을 저장하는 가장 심플한 Fabric 네트워크를 구축합니다.
- アイスクリームの所有権を保存する最もシンプルなFabricネットワークをつくります。

# how
0. ./bootstrap.sh
- path: fabric-samples/scripts/bootstrap.sh
1. sudo ./setup build
2. sudo ./setup run
3. peer chaincode invoke -n fabice -c '{"Args":["newIceCream", "ICE0", "strawberry", "red", "User1"]}' -C channelall
4. peer chaincode query -C channelall -n fabice -c '{"Args":["getIceCream", "ICE0"]}'
5. exit
6. sudo ./setup rm

# WARN!!
- sudo ./setup rm에서, 미연동중인 volume을 다 삭제합니다.
- sudo ./setup rmでは、未連動のVolumeをすべて削除します。

# img
![fabice.png](./img/fabice.png)
