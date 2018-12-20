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

import org.apache.hadoop.hbase.client.{ HBaseAdmin, Put, HTable }
import org.apache.hadoop.hbase.{ HBaseConfiguration, HTableDescriptor, TableName }
import org.apache.hadoop.hbase.mapreduce.TableInputFormat
import org.apache.hadoop.hbase.mapreduce.TableOutputFormat
import org.apache.hadoop.hbase.HColumnDescriptor
import org.apache.hadoop.hbase.util._
import org.apache.hadoop.fs.Path;

import java.util.Calendar
import java.text.SimpleDateFormat

import org.apache.log4j.Logger
import org.apache.log4j.Level

  /****************************************************/
 /***** DDos Detection by PPS(Packet Per Second) *****/
/****************************************************/


object DDosDect {

Logger.getLogger("org").setLevel(Level.OFF)
Logger.getLogger("akka").setLevel(Level.OFF)

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
    val ssc = new StreamingContext(sc, Seconds(1))

    // Create direct kafka stream with brokers and topics
    val topics = topic
    val brokers = broker
    val topicsSet = topics.split(",").toSet
    val kafkaParams = Map[String, String]("metadata.broker.list" -> brokers)
    val messages = KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder](ssc, kafkaParams, topicsSet)

    // Get today
    val today = Calendar.getInstance.getTime
    val curDateFormat = new SimpleDateFormat("yyyyMMdd,HH:mm:ss,HH,mm")
    val day = curDateFormat.format(today).split(",")

    // Configuration for hbase
    def genHbaseTable(day: Array[String]): HTable = {
      val tablename = "DDos-" + day(0)
      var conf = HBaseConfiguration.create()
      conf.set(TableOutputFormat.OUTPUT_TABLE, tablename)

    // Initialize hBase table
      var admin = new HBaseAdmin(conf)
      println("-------------------------------------------------\n")
      if (!admin.isTableAvailable(tablename)) {
        println("\033[0;32m            Creating DDos Table : " + tablename + "\033[0m\n")
        val tableDesc = new HTableDescriptor(TableName.valueOf(tablename))
        tableDesc.addFamily(new HColumnDescriptor("Info"))
        admin.createTable(tableDesc)
      } else {
        println("\033[0;32mTable already exists")
        println("will be overwrite.\033[0m\n")
        val columnDesc = new HColumnDescriptor(Bytes.toBytes(day(1).split(":")(2)));
        admin.disableTable(Bytes.toBytes(tablename));
        admin.addColumn(tablename, columnDesc);
        admin.enableTable(Bytes.toBytes(tablename));
      }
      new HTable(conf, tablename)
    }
    
    var myTable = genHbaseTable(day)
    println("HBase Complete")

    //Get bandwidth
    val extractSpeed = ("sudo ethtool enp6s0" #| "grep Speed").!!.toString.trim
    val bandwidth = extractSpeed.toString.split(" ")(1).split("Mb")(0).toInt
    println("-------------------------------------------------\n")
    println("Bandwidth : " + bandwidth + "Mb/s")
    println("-------------------------------------------------\n")

    /*
     * Filter UDP packets out from Ethernet packets.
     * Extract length of packet from filtered UDP packet.
     * After then, Accumulate len of packets for 1 second.
     * Check that how much accumulated value ocuppy of whole bandwidth.
     * If accumulated value exceed 70% of the whole bandwidth, it consider DDos Attack.
     */

    val packets = messages.map(_._2).flatMap(_.split("<Ether")) // Whole Packets
    val udpPackets = messages.map(_._2).flatMap(_.split("<Ether ")).filter(x => x.contains("|<UDP ")) // UDP Packets

    udpPackets.print() 
    
    var pktByte = 0
    var pktCount = 0
    var ipList : Map[String, Int] = Map()
    var sizeList : Map[String, Int] = Map()
    var dropList : List[String] = List()
    
    udpPackets.foreachRDD(x => {
      
      pktByte = 0
      pktCount = 0
      ipList = Map()
      sizeList = Map()

      for (i <- x.collect) {
      
        // Get UDP packet count while 1 second
        pktCount += 1
        
        // Get UDP packet length
        var udpOffset = i.indexOf("|<UDP")
        var srcOffset = i.indexOf("|<IP")
        var len = i.slice(udpOffset, i.length()).split(" ")(4).split("=")(1).toInt

        // Get src
        var sliceSrc = i.slice(srcOffset, udpOffset)
        var sliceSrcOffset = sliceSrc.indexOf("src")
        var srcIP = sliceSrc.slice(sliceSrcOffset, sliceSrc.length()).split(" ")(0).split("=")(1)
        
        // Check IP each packet
        if(!(ipList.contains(srcIP))){
                ipList += ( srcIP -> 1)
                sizeList += ( srcIP -> len)
        }
        else{
                ipList = ipList.updated( srcIP, ipList(srcIP) + 1)
                sizeList = sizeList.updated( srcIP, sizeList(srcIP) + len)
        }
        // Get whole UDP packets size 
        pktByte += len 
      }

      println("Total UDP Packet Count : " + pktCount)
      println("Total UDP Packet Byte : " + pktByte)

      if (pktByte > (bandwidth * 1048576 * 0.7)) {
        
        // Get Attack Time
        val now = Calendar.getInstance.getTime
        val detectTime = curDateFormat.format(now).split(",")
        println("UDP Flooding!! DDos Attack!!")
        println("Detection Time : " + detectTime(1))
        
        // Sort by count
        val sortedIP = ipList.toList.sortBy{_._2}.last.toString
        val attackerIP = sortedIP.slice(1,sortedIP.indexOf(",")) 
      
        // Sort by Size
        val sortedSize = sizeList.toList.sortBy{_._2}.last.toString
        val attackSizeIP = sortedSize.slice(1,sortedSize.indexOf(","))
        var attIP : String = ""
        
        // Drop the attacker IP from iptable according to condition
        if(attackerIP == attackSizeIP){
                println("Attack IP : " + attackerIP)
                println("Attack Size : " + sizeList(attackerIP))
                attIP = attackerIP
                if(!(dropList.exists { x => x == attackerIP })){
                        dropList ::= attackerIP
                        ("sudo iptables -A INPUT -s " + attackerIP + " -j DROP").!!.toString.trim
                        println("Drop the attacker IP")
                }
        }
        else{
                println("Attack IP : " + attackSizeIP)
                println("Attack Size : " + sizeList(attackSizeIP))
                attIP = attackSizeIP
                if(!(dropList.exists { x => x == attackSizeIP })){
                        dropList ::= attackSizeIP
                        ("sudo iptables -A INPUT -s " + attackSizeIP + " -j DROP").!!.toString.trim
                        println("Drop the attacker IP")
                }
        }

        // Insert DDos data into Hbase        
        var row  = new Put(new String("DDos Info").getBytes())
        row.add ("Info".getBytes(), "Detection Time".getBytes(), detectTime(1).toString.getBytes() )
        row.add ("Info".getBytes(), "Attacker IP".getBytes(), attIP.getBytes())
        myTable.put(row)
      }
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

