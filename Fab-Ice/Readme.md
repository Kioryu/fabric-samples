# Fab-Ice
- 아이스크림 소유권을 저장하는 가장 심플한 Fabric 네트워크를 구축합니다.
- アイスクリームの所有権を保存する最もシンプルなFabricネットワークをつくります。

# how
0. ./bootstrap.sh
- path: fabric-samples/scripts/bootstrap.sh
1. sudo ./setup build
2. sudo ./setup run
3. sudo ./setup rm

# WARN!!
- sudo ./setup rm에서 docker container을 모두 삭제하며, 미연동중인 volume도 다 삭제합니다.
- sudo ./setup rmではDocker Containerをすべて削除します。尚、未連動のVolumeもすべて削除します。

# img
![fabice.png](./img/fabice.png)
