package com.keti

import scala.util.control.Breaks._
import java.sql.DriverManager
import java.sql.Connection
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.sql.types.{StructField, StructType, IntegerType, StringType}
import org.apache.spark.sql.Row
import org.apache.log4j.Logger
import org.apache.log4j.Level
import scala.reflect.runtime.universe._
import sys.process._

object SqlDF {
  
  Logger.getLogger("org").setLevel(Level.OFF)
  Logger.getLogger("akka").setLevel(Level.OFF)

  def main(args: Array[String]) {


    val count = args(0).toInt
    val database = args(1)
    val tableName = args(2)
    val rowCount = args(3).toInt


    // Spark Context and SQLContext define
    val sconf = new SparkConf().setAppName("Mysql Test").setMaster("local[4]");
    val sc = new SparkContext(sconf)
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)


 //   val date = "date".!!.toString.trim
 //   println("INFO: " + date + " Create SQL Context - Id 0")

    val url = "jdbc:mysql://172.0.0.6:3306/" + database + "?user=root&password=ketilinux"

    val prop = new java.util.Properties
    prop.setProperty("driver","com.mysql.jdbc.Driver")
    prop.setProperty("user","root")
    prop.setProperty("password","ketilinux")


    var start_Time = System.currentTimeMillis()    
    
    // Read Test
    //var emp = sqlContext.read.jdbc(url, tableName, prop).collect
    //emp.foreach(println) 

    // Insert Test

    var i = 0
    var k = 0
    var rowValue = List(Row(500000, "1991-09-20", "Hyung-Joo", "Ahn", "M", "2016-03-23"))

    for (i <- 1 to count){
      //emp +:= Row(500000 + i, "1991-09-20", "Hyung-Joo", "Ahn", "M", "2016-03-23")
      rowValue +:= Row(500000 + i, "1991-09-20", "Hyung-Joo", "Ahn", "M", "2016-03-23")
      if ( i % rowCount == 0 ){
        val data = sqlContext.createDataFrame(sc.parallelize(rowValue),
          StructType(List(StructField("emp_no", IntegerType),
          StructField("birth_date",StringType),
          StructField("first_name",StringType),
          StructField("last_name",StringType),
          StructField("gender",StringType),
          StructField("hire_date",StringType))))
        data.write.mode("append").jdbc(url, tableName, prop)
        rowValue = List()
      }
    }

    var emp = sqlContext.read.jdbc(url, tableName, prop).collect

    var per_time = System.currentTimeMillis() - start_Time

    if (tableName == "Empty"){
      println("\nEmpty Table Time : " + (per_time / 1000.0) + " sec\n")
    }else{
      println("\nEmployees Table Time : " + (per_time / 1000.0) + " sec\n")
    }
  
    /*
    // Update Test
 
    for (k <- 1 to count){
	   breakable{emp.foreach( x => {
		   if(x(0) == 500000 + k){
			   var emp_no = x(0)
			   var birth_date = x(1)
			   var first_name = x(2)
			   var last_name = x(3)
			   var gender = x(4)
			   var hire_date = x(5)	

			   emp = emp.filter(x => x(0) != 500000 + k)

			   emp +:= Row(emp_no, birth_date, "JJOO", last_name, gender, hire_date)
			   break
		   }
	   })}
    }

*/
   
    // Delete Test
/*
    for (k <- 0 to count){
           breakable{emp.foreach( x => {
                   if(x(0) == 500000 + k){

                           emp = emp.filter(x => x(0) != 500000 + k)
                           break
                   }
           })}
    }

    var emprows = sc.parallelize(emp) 

    val data = sqlContext.createDataFrame(emprows, StructType(List
	(StructField("emp_no", IntegerType),
	StructField("birth_date",StringType),
	StructField("first_name",StringType),
	StructField("last_name",StringType),
	StructField("gender",StringType),
	StructField("hire_date",StringType))))
    data.write.mode("overwrite").jdbc(url, tableName, prop)
   
  }*/

  val del_driver = "com.mysql.jdbc.Driver"
  val del_url = "jdbc:mysql://172.0.0.6/" + args(1)
  val del_username = "root"
  val del_password = "ketilinux"

  var connection:Connection = null

  try {
    // Database Connect
    Class.forName(del_driver)
    connection = DriverManager.getConnection(del_url, del_username, del_password)
    // Create the statement, and run the select query
    val statement = connection.createStatement()
    statement.executeUpdate("DELETE FROM " + tableName + " WHERE emp_no>=500000")
  } catch {
    case e => e.printStackTrace
  }
  connection.close()
}
}
