package com.keti

import scala.util.control.Breaks._
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicBoolean
import java.util.Properties
import java.util.concurrent._
import scala.collection.JavaConversions._
import kafka.consumer.Consumer
import kafka.consumer.ConsumerConfig
import kafka.utils._
import kafka.utils.Logging
import kafka.consumer.KafkaStream

class KafkaStreamT(val zookeeper: String,
                            val groupId: String,
                            val topic: String,
                            val delay: Long, val time :Int) extends Logging {

  val config = createConsumerConfig(zookeeper, groupId)
  val consumer = Consumer.create(config)
  var executor: ExecutorService = null
  var msgCount = new AtomicInteger(0)
  var msgByte = new AtomicInteger(0)
  var threadFlag =  new AtomicBoolean(false)

  def shutdown() = {
    if (consumer != null)
      consumer.shutdown();
    if (executor != null)
      executor.shutdown();
  }

  def createConsumerConfig(zookeeper: String, groupId: String): ConsumerConfig = {
    val props = new Properties()
    props.put("zookeeper.connect", zookeeper);
    props.put("group.id", groupId);
    props.put("auto.offset.reset", "largest");
    props.put("zookeeper.session.timeout.ms", "400");
    props.put("zookeeper.sync.time.ms", "200");
    props.put("auto.commit.interval.ms", "1000");
    val config = new ConsumerConfig(props)
    config
  }

  def run(numThreads: Int) = {
    val topicCountMap = Map(topic -> numThreads)
    val consumerMap = consumer.createMessageStreams(topicCountMap);
    val streams = consumerMap.get(topic).get;

    executor = Executors.newFixedThreadPool(numThreads);
    var threadNumber = 0;
    for (stream <- streams) {
      executor.submit(new ScalaConsumerTest(stream, threadNumber, delay, time, msgCount, msgByte, threadFlag))
      threadNumber += 1
    }
  }
}

object KafkaStreamT extends App {
  val example = new KafkaStreamT(args(0), args(1), args(2),args(4).toLong, args(5).toInt)
  example.run(args(3).toInt)
}

class Timer(time: Int, msgCount: AtomicInteger, msgByte: AtomicInteger, threadFlag: AtomicBoolean)  extends Runnable {
  def run {
	System.out.println("Timer Start")
	Thread.sleep(time * 1000)
	threadFlag.getAndSet(true)
	System.out.println("==========================================")
	System.out.println("Message Count : ", msgCount.get())
	System.out.println("Message Byte : ", msgByte.get())
	System.exit(0)
  }
}

class ScalaConsumerTest(val stream: KafkaStream[Array[Byte], Array[Byte]], val threadNumber: Int, val delay: Long, val time: Int, var msgCount: AtomicInteger, var msgByte: AtomicInteger, var threadFlag: AtomicBoolean) extends Logging with Runnable {
  def run {

	  val it = stream.iterator()

	  msgCount.getAndSet(0)
	  msgByte.getAndSet(0)

	  breakable{ 
		  while (it.hasNext()) {
			  if ( msgCount.get() == 0 ){
				  (new Thread(new Timer(time, msgCount, msgByte, threadFlag))).start
			  }
			  val msg = new String(it.next().message());

			  msgCount.getAndAdd(1)
		 	  msgByte.getAndAdd(msg.length)
			  if (threadFlag.get() == true){
				  break
			  }
		  }
	  }
  }
}
