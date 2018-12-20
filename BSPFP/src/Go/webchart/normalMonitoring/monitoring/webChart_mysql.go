package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"github.com/ajstarks/svgo"
	"github.com/vdobler/chart"
	_ "github.com/vdobler/chart/imgg"
	_ "github.com/vdobler/chart/svgg"
	"github.com/vdobler/chart/txtg"
	"image"
	"image/color"
	_ "image/draw"
	_ "image/png"
	"keti/datastruct/queue"
	sql "keti/squall/sql/context_sql"
	"keti/squall/streaming"
	"log"
	_ "net"
	"net/http"
	"os"
	"os/exec"
	"runtime"
	"strconv"
	"strings"
	"time"
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

	/* SVG Part
	dumper.svgFile, err = os.Create(name + ".svg")
	if err != nil {
		panic(err)
	}
	dumper.S = svg.New(dumper.svgFile)
	dumper.S.Start(n*w, m*h)
	dumper.S.Title(name)
	dumper.S.Rect(0, 0, n*w, m*h, "fill: #ffffff")
	*/

	/* PNG Part
	dumper.imgFile, err = os.Create(name + ".png")
	if err != nil {
		panic(err)
	}
	dumper.I = image.NewRGBA(image.Rect(0, 0, n*w, m*h))
	bg := image.NewUniform(color.RGBA{0xff, 0xff, 0xff, 0xff})
	draw.Draw(dumper.I, dumper.I.Bounds(), bg, image.ZP, draw.Src)
	*/

	dumper.txtFile, err = os.Create(name + ".txt")
	if err != nil {
		panic(err)
	}

	return &dumper
}

func (d *Dumper) Close() {

	/* PNG Part
	png.Encode(d.imgFile, d.I)
	d.imgFile.Close()
	*/

	/* SVG Part
	d.S.End()
	d.svgFile.Close()
	*/

	d.txtFile.Close()
}

func (d *Dumper) Plot(c chart.Chart) {
	/* PNG Part
	row, col := d.Cnt/d.N, d.Cnt%d.N

	igr := imgg.AddTo(d.I, col*d.W, row*d.H, d.W, d.H, color.RGBA{0x80, 0x80, 0x80, 0xff}, nil, nil)
	c.Plot(igr)
	*/

	/* SVG Part
	sgr := svgg.AddTo(d.S, col*d.W, row*d.H, d.W, d.H, "", 12, color.RGBA{0xff, 0xff, 0xff, 0xff})
	c.Plot(sgr)
	*/

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

func dateParse(t time.Time) string {
	return t.Format("2006-01-02")
}
func timeParse(t time.Time) string {
	return t.Format("15:04:05")
}

func makeJson(q *queue.Queue) string {
	tempMap := make(map[string]float64)
	for k := 1; k < 11; k++ {
		tempMap["t"+strconv.Itoa(k)] = q.Get(k - 1)
	}
	dataJson, _ := json.Marshal(tempMap)
	return string(dataJson)
}

const CLR_R = "\x1b[33;1m"
const CLR_G = "\x1b[32;1m"
const CLR_N = "\x1b[0m"

func main() {

	// Host information

	url := "http://10.0.0.94:8000/monitoring"
	client := &http.Client{}
	jsonStr := []byte("{\"head\":\"body\"}")

	// Application args

	debugging := flag.Bool("debug", false, "output debug information to stderr")
	brokers := flag.String("brokers", "localhost:9092", "kafka brokers list")
	topic := flag.String("topic", "packet", "Kafka topic to send messages to")
	shard := flag.Int("shard", 3, "Set shard")
	iface := flag.String("i", "enp6s0", "set network interface")
	flag.Parse()

	if *debugging {
		chart.DebugLogger = log.New(os.Stdout, "", log.LstdFlags)
	}

	// Set the max process count

	runtime.GOMAXPROCS(20)

	// Sqaull streaming setting

	streaming.PRINT_JIFFIES = false
	streamContext := streaming.Context()

	// Create sql context instance and sql setting

	sqlContext := sql.SQLContext()
	sqlContext.Open("mysql", "root@tcp(10.0.0.94:3306)/monitoring")
	stmtInsert, err := sqlContext.Prepare("insert into monitoring (ID, date, time, traffic) values (?,?,?,?)")
	if err != nil {
		log.Fatal(err)
	}

	// Squall kafka streaming setting
	// Brokers, shard etc...
	// Decide word for filtering and set parameter

	conf := streaming.NewKafkaConfig(*topic, 0)
	src := streamContext.KafkaStream(*brokers, conf, *shard)

	res := src.Filter(func(packet string) bool {
		return strings.Contains(packet, "PACKET")
	})

	// Get bandwidth of system
	// Adjust threshold ratio arbitrarily for seeing graph flow

	bandCommand := exec.Command("/bin/sh", "-c", "ethtool "+*iface+" | grep Speed")
	out, _ := bandCommand.CombinedOutput()
	bandwidth, _ := strconv.Atoi(strings.Split(strings.Split(string(out), " ")[1], "Mb")[0])
	threshold := float64(bandwidth) * 0.002

	// Get Memory State
	memoryCommand := exec.Command("/bin/sh", "-c", "free -m | grep Mem")
	memoryOutput, _ := memoryCommand.CombinedOutput()
	memory := strings.SplitN(strings.Trim(strings.SplitN(strings.Trim(strings.SplitN(string(memoryOutput), " ", 2)[1], " "), " ", 2)[1], " "), " ", 2)[0]
	println(memory)
	// The Queue has graph data
	// Make instance of two Queue and initialize them

	dataQueue := queue.NewQueue()
	timeQueue := queue.NewQueue()
	timeQueue.XRangeInit()

	// Declare count variable

	packetCount := 0
	packetTotalCount := 0
	packetTotalSize := 0
	i := 0
	idCount := 0
	maxTraffic := float64(-1)
	maxDate := ""
	maxTime := ""

	// Foreach Operation
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

				dataQueue.Push(packetTotalSizeMB)
				dataQueue.Pop()
				timeQueue.Push(float64(10 + i)) //100 + (10 * i)))
				timeQueue.Pop()
				i++
				barChart(dataQueue, timeQueue)

				nowDate := dateParse(time.Now())
				nowTime := timeParse(time.Now())

				// Print graph on the console

				cmd := exec.Command("/bin/sh", "-c", "clear && cat chart.txt")
				out, _ := cmd.CombinedOutput()
				fmt.Println(string(out))

				// Data in graph send to server

				req, err := http.NewRequest("GET", url, bytes.NewBuffer(jsonStr))
				if err != nil {
					log.Fatal(err)
				}
				req.Header.Add("Date", nowDate)
				req.Header.Add("Time", nowTime)
				req.Header.Add("EPort", *iface)
				req.Header.Add("Term", strconv.Itoa(int(timeQueue.Bottom())))
				req.Header.Add("OneSize", strconv.FormatFloat(packetTotalSizeMB, 'f', 6, 64))
				req.Header.Add("MaxDate", maxDate)
				req.Header.Add("MaxTime", maxTime)
				req.Header.Add("MaxTraffic", strconv.FormatFloat(maxTraffic, 'f', 6, 64))
				req.Header.Add("Memory", memory)

				// Print information on the console

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

				// When over the threshold, it stores information into database

				if packetTotalSizeMB > threshold {
					req.Header.Add("DDoS", "3")
					idCount++
					overDate := dateParse(time.Now())
					overTime := timeParse(time.Now())
					fmt.Printf("%sOver Threshold!!%s\n\n", CLR_R, CLR_N)
					stmtInsert.Exec(idCount, overDate, overTime, packetTotalSizeMB)
				} else {
					req.Header.Add("DDoS", "0")
				}

				fmt.Println("===============================")

				client.Do(req)

				packetCount = 0
				packetTotalSize = 0
			})
		}

	})

	// Foreach Start

	src.Run()

}
