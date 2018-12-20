package main

import (
	"flag"
	"fmt"
	"keti/squall"
	"runtime"
	"strings"
)

const CLR_R = "\x1b[31;1m"
const CLR_G = "\x1b[32;1m"
const CLR_N = "\x1b[0m"

var (
	brokers = flag.String("brokers", "localhost:9092", "kafka brokers list")
	topic   = flag.String("topic", "packet", "Kafka topic to send messages to")
	shard   = flag.Int("shard", 1, "Set shard")
	dstip   = flag.String("dstip", "10.0.0.94", "set host ip")
)

func main() {

	flag.Parse()

	runtime.GOMAXPROCS(*shard)

	//Create a local StreamContext
	streamContext := squall.StreamingContext()

	//Create a input stream
	conf := squall.NewKafkaConfig(*topic, 0)
	src := streamContext.KafkaStream(*brokers, conf, *shard)

	///////////////////////////////////////////////////////////////TCP
	tcp_rules := squall.Rules{}
	tcp_rules.AddRule("TCP XMAS Flooding", "FIN=true", "RST=true", "PSH=true", "URG=true", "DstIP="+*dstip)
	tcp_rules.AddRule("TCP ACK Flooding", "ACK=true", "DstIP="+*dstip)
	tcp_rules.AddRule("TCP PUSH Flooding", "PSH=true", "DstIP="+*dstip)
	tcp_rules.AddRule("TCP SYN Flooding", "SYN=true", "DstIP="+*dstip)
	tcp_rules.AddRule("TCP FIN Flooding", "FIN=true", "DstIP="+*dstip)
	tcp_rules.AddRule("TCP RESET Flooding", "RST=true", "DstIP="+*dstip)
	tcp_rules.AddRule("TCP URG Flooding", "URG=true", "DstIP="+*dstip)

	tcpAttackCounter := squall.NewPacketCnt(tcp_rules, 10, 10000)

	res := src.Filter(func(packet string) bool {
		return strings.Contains(packet, "TCP")
	})

	tcpAttackInfo := res.DdosDetector(tcpAttackCounter)

	tcpAttackInfo.Map(func(packet squall.AttackInfo) {
		fmt.Printf("%+v\n", packet)
	})

	///////////////////////////////////////////////////////////////UDP
	udp_rules := squall.Rules{}
	udp_rules.AddRule("UDP Flooding", "DstIP="+*dstip)

	udpAttackCounter := squall.NewPacketCnt(udp_rules, 10, 10000)

	udpAttackInfo := src.Filter(func(packet string) bool {
		return strings.Contains(packet, "UDP")
	}).DdosDetector(udpAttackCounter)

	udpAttackInfo.Map(func(packet squall.AttackInfo) {
		fmt.Printf("%+v\n", packet)
	})

	///////////////////////////////////////////////////////////////ICMP
	icmp_rules := squall.Rules{}
	icmp_rules.AddRule("LAND Attack", "SrcIP="+*dstip, "DstIP="+*dstip)
	icmp_rules.AddRule("ICMP Smurf", "TypeCode=EchoRequest", "SrcIP="+*dstip)
	icmp_rules.AddRule("Ping of Death", "DstIP="+*dstip)

	icmpAttackCounter := squall.NewPacketCnt(icmp_rules, 1, 100)

	icmpAttackInfo := src.Filter(func(packet string) bool {
		return strings.Contains(packet, "ICMP")
	}).DdosDetector(icmpAttackCounter)

	icmpAttackInfo.Map(func(packet squall.AttackInfo) {
		fmt.Printf("%+v\n", packet)
	})

	src.Run()

}
