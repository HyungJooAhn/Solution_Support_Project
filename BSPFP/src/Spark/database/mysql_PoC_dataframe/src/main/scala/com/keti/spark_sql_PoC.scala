package com.keti

import java.sql.DriverManager
import java.sql.Connection
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.sql.types.{StructField, StructType, IntegerType, StringType}
import org.apache.spark.sql.Row
import org.apache.spark.sql.DataFrameReader
import org.apache.log4j.Logger
import org.apache.log4j.Level


object SparkSqlPoc {

Logger.getLogger("org").setLevel(Level.OFF)
Logger.getLogger("akka").setLevel(Level.OFF)

  def main(args: Array[String]) {

    // #1 Mysql Driver connection by Spark SQL

    // Spark Context and SQLContext define

    val sconf = new SparkConf().setAppName("Mysql Conn").setMaster("local[4]");
    val sc = new SparkContext(sconf)
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)


    val count = args(0).toInt
    val database = args(1)
    val tableName = args(2)



      // JDBC configuration 

    val jdbcDF = sqlContext.read.format("jdbc").options(Map("driver" -> "com.mysql.jdbc.Driver" , "url" -> "jdbc:mysql://172.0.0.6/test?user=root&password=ketilinux", "dbtable" -> tableName)).load()
    jdbcDF.registerTempTable(tableName)

    println("// Database connect //")


    var start_Time = System.currentTimeMillis()
  // Insert Test 

    var num = 0
    for(num <- 0 to count-1){
      sqlContext.sql("INSERT INTO TABLE " + tableName + " SELECT 50000"+num.toString+",'1991-07-20', 'Hyung-Joo', 'Ahn', 'M', '2016-03-22'")
    }
    // Read Test 
    val resultdb = sqlContext.sql("SELECT * FROM "+tableName)
    //resultdb.collect().foreach(println) 
    // resultdb.map( t => t(0)).collect().foreach(println)  Read One Column
    
    var per_time = System.currentTimeMillis() - start_Time

    val driver = "com.mysql.jdbc.Driver"
    val url = "jdbc:mysql://172.0.0.6/" + args(1)
    val username = "root"
    val password = "ketilinux"

    var connection:Connection = null
    var i = 0

    try {
      // Database Connect
      Class.forName(driver)
      connection = DriverManager.getConnection(url, username, password)
      println("Create SQL Context")

      // Create the statement, and run the select query
      val statement = connection.createStatement()

      statement.executeUpdate("DELETE FROM " + tableName + " WHERE emp_no>=500000")

      if (tableName == "Empty"){
        println("\nEmpty Table Time : " + (per_time / 1000.0) + " sec\n")
      }else{
        println("\nEmployees Table Time : " + (per_time / 1000) + " sec\n")
      }
    } catch {
      case e => e.printStackTrace
    }
    connection.close()

  }
}
