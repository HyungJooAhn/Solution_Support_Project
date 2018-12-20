package com.keti

import java.io.File


import com.google.common.io.{ByteStreams, Files}
import org.apache.hadoop.hive.conf.HiveConf
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.sql._
import org.apache.spark.sql.hive.HiveContext

object HiveFromSpark {
  case class Record(key: Int, value: String)

  // Copy kv1.txt file from classpath to temporary directory
//  val kv1Stream = HiveFromSpark.getClass.getResourceAsStream("/kv1.txt")
 // val kv1File = File.createTempFile("kv1", "txt")
 // kv1File.deleteOnExit()
 // ByteStreams.copy(kv1Stream, Files.newOutputStreamSupplier(kv1File))

  def main(args: Array[String]) {
    val sparkConf = new SparkConf().setAppName("HiveFromSpark").setMaster("local")
    val sc = new SparkContext(sparkConf)

    // A hive context adds support for finding tables in the MetaStore and writing queries
    // using HiveQL. Users who do not have an existing Hive deployment can still create a
    // HiveContext. When not configured by the hive-site.xml, the context automatically
    // creates metastore_db and warehouse in the current directory.
    val hiveContext = new HiveContext(sc)
    import hiveContext.implicits._
    import hiveContext.sql

    // Queries are expressed in HiveQL
    println("Result of 'SELECT *': ")
    sql("SELECT * FROM name").collect().foreach(println)

    // Aggregation queries are also supported.
    val count = sql("SELECT COUNT(*) FROM src").collect().head.getLong(0)
    println(s"COUNT(*): $count")

    sc.stop()
  }
}
