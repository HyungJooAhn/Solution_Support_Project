package com.keti

import kafka.serializer.StringDecoder
import org.apache.spark._
import org.apache.spark.streaming._
import org.apache.spark.streaming.kafka._
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._

import org.elasticsearch.spark._
import org.elasticsearch.spark.rdd.Metadata._

import java.util
import collection.mutable.HashMap
import scala.sys.process._

import org.apache.hadoop.fs.Path;

import scala.util.control.Breaks._
import java.util.Calendar
import java.text.SimpleDateFormat


  /****************************************************/
 /***** DDos Detection by PPS(Packet Per Second) *****/
/****************************************************/

object KafkaStream {

  // Usage define
  val usage = """
  Usage:  spark-submit ~ -t topics [-b brokers] [-p port] [-n node] ...
  Where:  
  -t topic  Set Kafka stream topic name to consume (split: , )
  -b broker Set Kafka broker names.  defalut-> localhost:9092
  -p port   Set Elasticsearch port number.  defalut-> 9200
  -n node	  Set Elasticsearch server ip address. defalut-> localhost
  """

  // Default Setting
  var topic: String = ""
  var broker: String = "localhost:9092"
  var esport: String = "9200"
  var esnode: String = "localhost"
  val unknown = "(^-[^\\s])".r

  // Arguments classify
  val pf: PartialFunction[List[String], List[String]] = {
    case "-t" :: (arg: String) :: tail =>
      topic = arg; tail
    case "-b" :: (arg: String) :: tail =>
      broker = arg; tail
    case "-p" :: (arg: String) :: tail =>
      esport = arg; tail
    case "-n" :: (arg: String) :: tail =>
      esnode = arg; tail
    case unknown(bad) :: tail => die("unknown argument " + bad + "\n" + usage)
  }


  def main(args: Array[String]) {

    if (args.length == 0) die()
    else {
      val arglist = args.toList
      parseArgs(arglist, pf)
    }

    val sconf = new SparkConf().setAppName("DDos Attack detection").setMaster("local[4]");

    // Elastic Search Conf
    sconf.set("es.nodes", esnode);
    sconf.set("es.port", esport);
    sconf.set("es.index.auto.create", "true");
    sconf.set("es.resource", "spark/docs");

    val sc = new SparkContext(sconf)

    // Create context with 1 second batch interval
    val ssc = new StreamingContext(sc, Seconds(10))

    // Create direct kafka stream with brokers and topics
    val topics = topic
    val brokers = broker
    val topicsSet = topics.split(",").toSet
    val kafkaParams = Map[String, String]("metadata.broker.list" -> brokers)
    val messages = KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder](ssc, kafkaParams, topicsSet)

    println("-------------------------------------------------\n")

    val packets = messages.map(_._2) // Whole Packets
//    packets.print() 
    var pktCount = 0

    packets.foreachRDD(x => {
        pktCount = 0
        breakable{
	    for (i <- x.collect) {
                    /*if (pktCount == 10){
                      break
                    }*/
		    pktCount += 1
                    //println(i)
                    //println("===============================================================================")
                    

	    }
          }
	println("Packet Count : " +  pktCount)
    })

    // Start Spark Streaming
    ssc.start()
    ssc.awaitTermination()
  }

  def toTuple[A <: Object](as: List[A]): Product = {
    as.size match {
      case 0 => Nil
      case _ => {
        val tupleClass = Class.forName("scala.Tuple" + as.size)
        tupleClass.getConstructors.apply(0).newInstance(as: _*).asInstanceOf[Product]
      }
    }
  }

  def parseArgs(args: List[String], pf: PartialFunction[List[String], List[String]]): List[String] = args match {
    case Nil => Nil
    case _ => if (pf isDefinedAt args) parseArgs(pf(args), pf)
    else args.head :: parseArgs(args.tail, pf)
  }

  def die(msg: String = usage) = {
    println(msg)
    sys.exit(1)
  }

}

