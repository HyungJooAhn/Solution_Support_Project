#/bin/bash

PRODUCER_PATH=/home/keti/Workspace/src/beji/producer/packetProducer

${PRODUCER_PATH}/GoPacketProducer -capture -brokers localhost:9092 -topic packet -c -pn 100 -i enp6s0

