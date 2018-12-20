package main

import (
	"flag"
	"fmt"
	"github.com/Shopify/sarama"
	stdlog "log"
	"os"
	"os/signal"
	"time"
)

func main() {

	// Set Flag //

	brokers := flag.String("brokers", "10.0.7.100:9092", "Comma separated kafka brokers list")
	topic := flag.String("topic", "ppgo", "Kafka topic to send messages to")
	testTime := flag.Int("testTime", 10, "Test Performance")

	flag.Parse()

	// Define Logger //

	var logger = stdlog.New(os.Stderr, "LOG> ", stdlog.Lshortfile|stdlog.Lmicroseconds)

	conf := sarama.NewConfig()
	conf.ClientID = "kafkatest"
	conf.Consumer.MaxWaitTime = time.Duration(1) * time.Millisecond
	conf.Consumer.Fetch.Min = int32(1024 * 1024)

	// Define Client //

	cl, err := sarama.NewClient([]string{*brokers}, conf)
	if err != nil {
		fmt.Printf("ERROR creating kafka client to %q: %s", *brokers, err)
		return
	}
	defer cl.Close()

	// Define Partition //

	partitions, err := cl.Partitions(*topic)
	if err != nil {
		fmt.Printf("ERROR reading partitions for %q: %s\n", *topic, err)
		return
	}

	// Define offset of each partitions //
	// Make array of offsets //

	offsets := make(map[int32]int64, len(partitions))
	for _, p := range partitions {
		offset, err := cl.GetOffset(*topic, p, sarama.OffsetNewest)
		if err != nil {
			fmt.Printf("ERROR reading offset for partition %d of %q: %s\n", p, *topic, err)
			return
		}
		offsets[p] = offset
	}

	// Define consumer //

	consumer, err := sarama.NewConsumerFromClient(cl)
	if err != nil {
		logger.Panicln(err)
	}

	defer func() {
		if err := consumer.Close(); err != nil {
			logger.Fatalln(err)
		}
	}()

	// Make Signal Channel //

	signals := make(chan os.Signal, 1)
	signal.Notify(signals, os.Interrupt)

	// Define consumer of each partitions //
	// Make array of partition consumer //

	partitionConArr := make([]sarama.PartitionConsumer, len(partitions))
	for i := int32(0); i < int32(len(partitions)); i++ {

		partitionConsumer, err := consumer.ConsumePartition(*topic, i, sarama.OffsetNewest)

		if err == nil {
			partitionConArr[i] = partitionConsumer
		} else {
			logger.Panicln(err)
		}
	}

	// Define Channel to need
	// # quitChan is channel for receiving timer result ( 10 seconds )
	// # resultChan is channel for receiving packet result of counting
	// # timeChan is channel for receiving start time and end time

	quitChan := make(chan bool)
	resultChan := make(chan int)
	byteChan := make(chan int)
	timeChan := make(chan time.Time)
	msgCount := 0
	msgByte := 0

	// Starting Point //

	logger.Println("Start")

	// Run each consumer of partition through go routine //

	for i := int32(0); i < int32(len(partitionConArr)); i++ {
		go consumerGo(partitionConArr[i], offsets[i], quitChan, resultChan, byteChan, timeChan, *testTime)

	}

	// Receive result of consumer from channel //

	var resultTimeStart time.Time
	var resultTimeEnd time.Time

	for i := int32(0); i < int32(len(partitionConArr)); i++ {
		pckCount := <-resultChan
		msgCount += pckCount
		msgByte += <-byteChan
		resultTimeEnd = <-timeChan
		resultTimeStart = <-timeChan
	}

	// Print Result

	printPerform(resultTimeStart, resultTimeEnd, msgCount, msgByte)

}

// Function for counting time //

func timer(testT int, consumerChan chan bool) {
	time.Sleep(time.Second * time.Duration(testT))
	consumerChan <- true
}

// Function for consume data of message queue //

func consumerGo(partitionCon sarama.PartitionConsumer, offset int64, consumerChan chan bool, resultChan chan int, byteChan chan int, timeChan chan time.Time, testtime int) {

	nMsg := 0
	byteMsg := 0
	var start time.Time

	for k := int64(0); k < offset; k++ {

		a := (<-partitionCon.Messages())

		if nMsg == 0 {
			start = time.Now()
			go timer(testtime, consumerChan)
		}

		//	fmt.Println(a.Value)

		nMsg++ // count packet
		byteMsg = byteMsg + len(a.Value)
		//fmt.Println("Packet : ", nMsg)

		select {
		case flagCheck := <-consumerChan:

			if flagCheck == true {
				end := time.Now()
				resultChan <- nMsg
				byteChan <- byteMsg
				timeChan <- end
				timeChan <- start
				return
			}
		default:
		}
	}
}

// Function for printing result //

func printPerform(resultTimeStart time.Time, resultTimeEnd time.Time, msgCount int, msgByte int) {

	pt := resultTimeEnd.Sub(resultTimeStart).Seconds()

	start_date := fmt.Sprintf("%02d-%02d %02d:%02d:%02d:%03d", resultTimeStart.Month(), resultTimeStart.Day(), resultTimeStart.Hour(), resultTimeStart.Minute(), resultTimeStart.Second(), resultTimeStart.UnixNano()/1000000%1000)
	end_date := fmt.Sprintf("%02d-%02d %02d:%02d:%02d:%03d", resultTimeEnd.Month(), resultTimeEnd.Day(), resultTimeEnd.Hour(), resultTimeEnd.Minute(), resultTimeEnd.Second(), resultTimeEnd.UnixNano()/1000000%1000)

	fmt.Println("-----------------------/ ------------------ / ---------------- / --------------- /---------------------/ ")
	fmt.Println("      start.time      /      end.time      / consumed.in.nMsg /  Msg_count.sec  / performancetime.sec /")
	fmt.Println("---------------------/ ------------------ / ---------------- / --------------- /---------------------/ ")
	s := fmt.Sprintf(" %14s / %14s / %16d / %15.2f / %20.4f ", start_date, end_date, msgCount, float64(msgCount)/pt, pt)
	fmt.Println(s)
	fmt.Println("-------------------/ ------------------ / ---------------- / --------------- /---------------------/ ")
	fmt.Println("Total Byte : ", msgByte)
}
