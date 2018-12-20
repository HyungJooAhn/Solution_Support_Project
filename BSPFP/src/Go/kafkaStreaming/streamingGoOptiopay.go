package main

import (
	"flag"
	"fmt"
	"github.com/optiopay/kafka"
	"log"
	"os"
	"time"
)

func main() {

	// Set Flag //

	brokers := flag.String("brokers", "10.0.7.100:9092", "Comma separated kafka brokers list")
	topic := flag.String("topic", "ppgo", "Kafka topic to send messages to")
	testTime := flag.Int("testTime", 10, "Test Performance")

	flag.Parse()

	// Define Logger //

	var logger = log.New(os.Stderr, "LOG> ", log.Lshortfile|log.Lmicroseconds)

	broker, err := kafka.Dial([]string{*brokers}, kafka.NewBrokerConf("test-client"))
	if err != nil {
		log.Fatalf("cannot connect to kafka cluster: %s", err)
	}
	defer broker.Close()

	conf := kafka.NewConsumerConf(*topic, 0)
	conf.StartOffset = kafka.StartOffsetNewest
	consumer, err := broker.Consumer(conf)

	//start := time.Now()
	quitChan := make(chan bool)
	resultChan := make(chan int)
	timeChan := make(chan time.Time)

	partitionCount, perr := broker.PartitionCount(*topic)
	if perr != nil {
		log.Fatalf("partition not found : %s", perr)
	}

	logger.Println("Start")
	for i := int32(0); i < partitionCount; i++ {
		go consumerGo(consumer, *testTime, *topic, quitChan, resultChan, timeChan)
	}

	var resultTimeStart time.Time
	var resultTimeEnd time.Time
	msgCount := 0

	for i := int32(0); i < partitionCount; i++ {
		countPkt := <-resultChan
		msgCount += countPkt
		resultTimeStart = <-timeChan
		resultTimeEnd = <-timeChan
	}

	// Print Result

	printPerform(resultTimeStart, resultTimeEnd, msgCount)

}

// Function for counting time //

func timer(testT int, consumerChan chan bool) {
	time.Sleep(time.Second * time.Duration(testT))
	consumerChan <- true
}

// Function for consume data of message queue //

func consumerGo(consumer kafka.Consumer, testtime int, topicname string, consumerChan chan bool, resultChan chan int, timeChan chan time.Time) {

	MsgByte := 0
	msgc := 0
	var start time.Time
	for {

		msg, err := consumer.Consume()
		if err != nil {
			if err != kafka.ErrNoData {
				log.Printf("cannot consume %q topic message: %s", topicname, err)
			}
			break
		}

		if MsgByte == 0 {
			start = time.Now()
			go timer(testtime, consumerChan)
		}
		//MsgByte++
		MsgByte += len(msg.Value)
		//log.Printf("message %d: %s", msg.Offset, msg.Value)
		//msgc = len(msg.Value)
		select {
		case flagCheck := <-consumerChan:

			if flagCheck == true {
				end := time.Now()
				resultChan <- MsgByte
				timeChan <- start
				timeChan <- end
				return
			}
		default:
		}
	}
	fmt.Println(msgc)
}

// Function for printing result //

func printPerform(resultTimeStart time.Time, resultTimeEnd time.Time, msgCount int) {

	pt := resultTimeEnd.Sub(resultTimeStart).Seconds()

	start_date := fmt.Sprintf("%02d-%02d %02d:%02d:%02d:%03d", resultTimeStart.Month(), resultTimeStart.Day(), resultTimeStart.Hour(), resultTimeStart.Minute(), resultTimeStart.Second(), resultTimeStart.UnixNano()/1000000%1000)
	end_date := fmt.Sprintf("%02d-%02d %02d:%02d:%02d:%03d", resultTimeEnd.Month(), resultTimeEnd.Day(), resultTimeEnd.Hour(), resultTimeEnd.Minute(), resultTimeEnd.Second(), resultTimeEnd.UnixNano()/1000000%1000)

	fmt.Println("-----------------------/ ------------------ / ---------------- / --------------- /---------------------/ ")
	fmt.Println("      start.time      /      end.time      / consumed.in.nMsg /  Msg_count.sec  / performancetime.sec /")
	fmt.Println("---------------------/ ------------------ / ---------------- / --------------- /---------------------/ ")
	s := fmt.Sprintf(" %14s / %14s / %16d / %15.2f / %20.4f ", start_date, end_date, msgCount, float64(msgCount)/pt, pt)
	fmt.Println(s)
	fmt.Println("-------------------/ ------------------ / ---------------- / --------------- /---------------------/ ")

}
