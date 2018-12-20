package main

import (
	"bytes"
	"ddos"
	"flag"
	"fmt"
	"image"
	"image/color"
	"keti/datastruct/queue"
	"keti/squall"
	sql "keti/squall/sql"
	"log"
	"net/http"
	"os"
	"os/exec"
	"runtime"
	"strconv"
	"strings"
	"time"

	"github.com/ajstarks/svgo"
	"github.com/vdobler/chart"
	"github.com/vdobler/chart/txtg"
)

var Background = color.RGBA{0xff, 0xff, 0xff, 0xff}

// Dumper helps saving plots of size WxH in a NxM grid layout
// in several formats

type Dumper struct {
	N, M, W, H, Cnt           int
	S                         *svg.SVG
	I                         *image.RGBA
	svgFile, imgFile, txtFile *os.File
}

func NewDumper(name string, n, m, w, h int) *Dumper {
	var err error
	dumper := Dumper{N: n, M: m, W: w, H: h}

	dumper.txtFile, err = os.Create(name + ".txt")
	if err != nil {
		panic(err)
	}

	return &dumper
}

func (d *Dumper) Close() {

	d.txtFile.Close()
}

func (d *Dumper) Plot(c chart.Chart) {

	tgr := txtg.New(100, 30)
	c.Plot(tgr)
	d.txtFile.Write([]byte(tgr.String() + "\n\n\n"))

	d.Cnt++

}

// Bar Charts

func barChart(q *queue.Queue, dq *queue.Queue) {

	dumper := NewDumper("chart", 1, 1, 400, 400)
	defer dumper.Close()

	gcolor := chart.Style{Symbol: 'o', LineColor: color.NRGBA{0xff, 0xfa, 0xfa, 0xd2},
		FillColor: color.NRGBA{0xff, 0xff, 0xe4, 0xb5},
		LineStyle: chart.SolidLine, LineWidth: 2}

	// Graph setting (Chart Title, Range of X and Y, Key, etc...)

	barc := chart.BarChart{Title: "Network Traffic Monitor"}
	barc.Key.Hide = true
	barc.XRange.Fixed(dq.Get(0), dq.Get(9), 1)
	barc.YRange.Fixed(0, 3, 0.3)
	barc.XRange.ShowZero = false

	// Graph data setting

	if dq.Get(0) >= 10 {
		barc.AddDataPair("Amount",
			[]float64{dq.Get(0), dq.Get(1), dq.Get(2), dq.Get(3), dq.Get(4), dq.Get(5), dq.Get(6), dq.Get(7), dq.Get(8), dq.Get(9)},
			[]float64{0, q.Get(1), q.Get(2), q.Get(3), q.Get(4), q.Get(5), q.Get(6), q.Get(7), q.Get(8), q.Get(9)}, gcolor)
	} else {
		barc.AddDataPair("Amount",
			[]float64{dq.Get(0), dq.Get(1), dq.Get(2), dq.Get(3), dq.Get(4), dq.Get(5), dq.Get(6), dq.Get(7), dq.Get(8), dq.Get(9)},
			[]float64{q.Get(0), q.Get(1), q.Get(2), q.Get(3), q.Get(4), q.Get(5), q.Get(6), q.Get(7), q.Get(8), q.Get(9)}, gcolor)
	}
	dumper.Plot(&barc)
}

func doEvery(d time.Duration, f func()) {
	for range time.Tick(d) {
		f()
	}
}

func doEveryAttack(d time.Duration, f func()) {
	for range time.Tick(d) {
		f()
	}
}

func dateParse(t time.Time) string {
	return t.Format("2006-01-02")
}
func timeParse(t time.Time) string {
	return t.Format("15:04:05")
}

const CLR_R = "\x1b[33;1m"
const CLR_G = "\x1b[32;1m"
const CLR_N = "\x1b[0m"

func main() {

	// Host information ******

	url := "http://10.0.0.94:8000/monitoring"
	client := &http.Client{}
	jsonStr := []byte("{\"head\":\"body\"}")

	// Application args ******

	debugging := flag.Bool("debug", false, "output debug information to stderr")
	brokers := flag.String("brokers", "localhost:9092", "kafka brokers list")
	topic := flag.String("topic", "packet", "Kafka topic to send messages to")
	shard := flag.Int("shard", 3, "Set shard")
	iface := flag.String("i", "enp6s0", "set network interface")
	dstip := flag.String("dstip", "10.0.0.94", "set host ip")

	flag.Parse()

	if *debugging {
		chart.DebugLogger = log.New(os.Stdout, "", log.LstdFlags)
	}

	// Set the max process count

	runtime.GOMAXPROCS(20)

	// Sqaull streaming setting ******
	sconf := squall.NewConfig("Squall Application", *shard)
	streamContext := squall.StreamingContext(sconf)

	// Squall kafka streaming setting
	// Brokers, shard etc...
	// Decide word for filtering and set parameter

	conf := squall.NewKafkaConfig(*topic, 0)
	src := streamContext.KafkaStream(*brokers, conf)

	res := src.Filter(func(packet string) bool {
		return strings.Contains(packet, "PACKET")
	})

	// Create sql context instance and sql setting ******

	sqlContext := sql.SQLContext()
	sqlContext.Open("odbc", "DSN=Ketiodbc")
	stmtInsert, err := sqlContext.Prepare("insert into ddostable values (TO_DATE(?, 'YYYY-MM-DD'),?,?,?,?,?,?)")
	if err != nil {
		log.Fatal(err)
	}

	// Get Memory State ******

	memoryCommand := exec.Command("/bin/sh", "-c", "free -m | grep Mem")
	memoryOutput, _ := memoryCommand.CombinedOutput()
	memory := strings.SplitN(strings.Trim(strings.SplitN(strings.Trim(strings.SplitN(string(memoryOutput), " ", 2)[1], " "), " ", 2)[1], " "), " ", 2)[0]

	// The Queue has graph data ******
	// Make instance of two Queue and initialize them

	dataQueue := queue.NewQueue()
	timeQueue := queue.NewQueue()
	timeQueue.XRangeInit()

	// Declare count variable ******

	packetCount := 0
	packetTotalCount := 0
	packetTotalSize := 0
	timeCount := 0
	maxTraffic := float64(-1)
	maxDate := ""
	maxTime := ""
	tcpCh := make(chan float64)
	udpCh := make(chan float64)
	icmpCh := make(chan float64)

	// Foreach Operation ******
	// Measure network traffic by packet length
	// Express result on the graph per 1 second

	res.Map(func(packet string) {
		packetLength, _ := strconv.Atoi(strings.Split(packet, " ")[1])
		packetTotalCount++
		packetCount++
		packetTotalSize += packetLength

		if packetTotalCount == 1 {
			go doEvery(time.Duration(1)*time.Second, func() {

				packetTotalSizeMB := float64(packetTotalSize) / float64(1024) / float64(1024)

				if maxTraffic < packetTotalSizeMB {
					maxTraffic = packetTotalSizeMB
					maxDate = dateParse(time.Now())
					maxTime = timeParse(time.Now())
				}

				// Console Chart Data setting ******

				dataQueue.Push(packetTotalSizeMB)
				dataQueue.Pop()
				timeQueue.Push(float64(10 + timeCount))
				timeQueue.Pop()

				nowDate := dateParse(time.Now())
				nowTime := timeParse(time.Now())

				timeCount++

				barChart(dataQueue, timeQueue)

				// Print graph on the console ******

				cmd := exec.Command("/bin/sh", "-c", "clear && cat chart.txt")
				out, _ := cmd.CombinedOutput()
				fmt.Println(string(out))

				// Print information on the console ******

				fmt.Println("===============================\n")
				fmt.Println("Date :", nowDate)
				fmt.Println("Time :", nowTime)
				fmt.Println("Ethernet Port :", *iface)
				fmt.Println("[ X : Second + 10 | Y : MB/s ]\n")
				fmt.Printf("Term (X) : %s%d%s\n", CLR_G, int(timeQueue.Bottom()), CLR_N)
				fmt.Printf("Now Traffic (Y) : %s%3f%s MB/s\n\n", CLR_G, packetTotalSizeMB, CLR_N)
				fmt.Println("Max Traffic Date :", maxDate)
				fmt.Println("Max Traffic Time :", maxTime)
				fmt.Printf("Max Traffic : %s%3f%s MB/s\n\n", CLR_R, maxTraffic, CLR_N)

				tcpSendByte := 0.0
				udpSendByte := 0.0
				icmpSendByte := 0.0

				select {
				case tcpValue := <-tcpCh:
					if tcpValue != 0.0 {
						tcpSendByte = tcpValue / float64(1024) / float64(1024)
					}
				default:
				}

				select {
				case udpValue := <-udpCh:
					if udpValue != 0.0 {
						udpSendByte = udpValue / float64(1024) / float64(1024)
					}
				default:
				}

				select {
				case icmpValue := <-icmpCh:
					if icmpValue != 0.0 {
						icmpSendByte = icmpValue / float64(1024) / float64(1024)
					}
				default:
				}

				// Request setting for sending server ******
				req, err := http.NewRequest("GET", url, bytes.NewBuffer(jsonStr))
				if err != nil {
					log.Fatal(err)
				}

				req.Header.Add("Date", nowDate)
				req.Header.Add("Time", nowTime)
				req.Header.Add("EPort", *iface)
				req.Header.Add("Term", strconv.Itoa(int(timeQueue.Bottom())))
				req.Header.Add("OneSize", strconv.FormatFloat(packetTotalSizeMB, 'f', 6, 64))
				req.Header.Add("TCPAttack", strconv.FormatFloat(tcpSendByte, 'f', 6, 64))
				req.Header.Add("UDPAttack", strconv.FormatFloat(udpSendByte, 'f', 6, 64))
				req.Header.Add("ICMPAttack", strconv.FormatFloat(icmpSendByte, 'f', 6, 64))
				req.Header.Add("MaxDate", maxDate)
				req.Header.Add("MaxTime", maxTime)
				req.Header.Add("MaxTraffic", strconv.FormatFloat(maxTraffic, 'f', 6, 64))
				req.Header.Add("Memory", memory)

				fmt.Println("===============================")

				// Send request to server ******

				client.Do(req)

				// Initialize count and size ******
				packetCount = 0
				packetTotalSize = 0
			})
		}

	})

	rules := ddos.Rules{}

	rules.AddRule("TCP XMAS Flooding", "TCP", "FIN=true", "RST=true", "PSH=true", "URG=true", "DstIP="+*dstip)
	rules.AddRule("TCP ACK Flooding", "TCP", "ACK=true", "DstIP="+*dstip)
	rules.AddRule("TCP PUSH Flooding", "TCP", "PSH=true", "DstIP="+*dstip)
	rules.AddRule("TCP SYN Flooding", "TCP", "SYN=true", "DstIP="+*dstip)
	rules.AddRule("TCP FIN Flooding", "TCP", "FIN=true", "DstIP="+*dstip)
	rules.AddRule("TCP RESET Flooding", "TCP", "RST=true", "DstIP="+*dstip)
	rules.AddRule("TCP URG Flooding", "TCP", "URG=true", "DstIP="+*dstip)
	rules.AddRule("UDP Flooding", "UDP", "DstIP="+*dstip)
	rules.AddRule("LAND Attack", "ICMP", "SrcIP="+*dstip, "DstIP="+*dstip)
	rules.AddRule("ICMP Smurf", "ICMP", "TypeCode=EchoRequest", "SrcIP="+*dstip)
	rules.AddRule("Ping of Death", "ICMP", "DstIP="+*dstip)

	attackCount := 0

	ddosRes := src.Filter(func(packet string) bool {
		return strings.Contains(packet, "PACKET")
	})

	ddosStmt := ddos.Stream{ddosRes}

	attackName := new(string)
	attackByte := new(float64)
	attackCountNumber := new(int)
	attackPercent := new(float64)
	attackStart := new(string)
	attackLatest := new(string)

	ddosStmt.DdosDetector(rules, 1, 900).Map(func(packet ddos.AttackInfo) {
		attackCount++

		*attackName = packet.AttackType
		*attackByte = packet.Byte
		*attackCountNumber = packet.Count
		*attackPercent = packet.Percent
		*attackStart = timeParse(packet.Start)
		*attackLatest = timeParse(packet.Latest)

		if attackCount == 1 {
			go doEveryAttack(time.Duration(1)*time.Second, func() {

				nowDate := dateParse(time.Now())
				if strings.Contains(*attackName, "TCP") {
					tcpCh <- *attackByte
					//	fmt.Println("TCP", *attackByte)
				} else if strings.Contains(*attackName, "UDP") {
					udpCh <- *attackByte
					//	fmt.Println("UDP", *attackByte)
				} else {
					icmpCh <- *attackByte
					//	fmt.Println("ICMP", *attackByte)
				}

				if *attackByte != 0 {
					stmtInsert.Exec(nowDate, *attackName, *attackByte, *attackCountNumber, *attackPercent, *attackStart, *attackLatest)
				}

				*attackByte = 0.0
			})
		}
	})

	// Foreach Start ******

	src.Start()

}
