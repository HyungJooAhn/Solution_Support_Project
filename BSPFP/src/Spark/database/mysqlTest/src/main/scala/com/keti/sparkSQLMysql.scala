package com.keti

import java.sql.DriverManager
import java.sql.Connection
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.sql.types.{StructField, StructType, IntegerType, StringType}
import org.apache.spark.sql.Row

object SparkSqlTest {
  def main(args: Array[String]) {

// #1 Spark SQL에 Mysql Driver 등록하여 사용하는 방법=============================

    // Spark Context and SQLContext define
    val sconf = new SparkConf().setAppName("Mysql Test").setMaster("local[4]");
    val sc = new SparkContext(sconf)
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)

    // JDBC configuration 
    val jdbcDF = sqlContext.read.format("jdbc").options(Map("driver" -> "com.mysql.jdbc.Driver" , "url" -> "jdbc:mysql://10.0.7.100/employees?user=root&password=ketilinux", "dbtable" -> "employees")).load()  
    jdbcDF.registerTempTable("employees")
    println("// Database connect //")


    // Read Test 
    val resultdb = sqlContext.sql("SELECT * FROM employees")
//    resultdb.collect().foreach(println) 
    // resultdb.map( t => t(0)).collect().foreach(println)  Read One Column

    // Make data to insert to database
    var num = 0
    for(num <- 0 to 9){
         sqlContext.sql("INSERT INTO TABLE employees SELECT 50000"+num.toString+",'1991-07-20', 'Hyung-Joo', 'Ahn', 'M', '2016-03-22'")
    }
   
   /*
    * Update and Delete are impossible by sql Query *
  */ 
    sqlContext.sql("UPDATE employees SET birth_date='2000-07-20',hire_date='2018-03-22' WHERE emp_no=500000") 
    sqlContext.sql("DELETE FROM employees WHERE empno=500000")

  }
}
