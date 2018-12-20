package com.keti

import scala.util.control.Breaks._
import java.sql.DriverManager
import java.sql.Connection
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.sql.types.{StructField, StructType, IntegerType, StringType}
import org.apache.spark.sql.Row

object DataFrameTest {
  def main(args: Array[String]) {

// #2 DataFrame을 만들어서 Table 전체를 덮어쓰는 방법=============================

    // Spark Context and SQLContext define
    val sconf = new SparkConf().setAppName("Mysql Test").setMaster("local[4]");
    val sc = new SparkContext(sconf)
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)

    val url = "jdbc:mysql://10.0.7.100:3306/employees?user=root&password=ketilinux"

    val prop = new java.util.Properties
    prop.setProperty("driver","com.mysql.jdbc.Driver")
    prop.setProperty("user","root")
    prop.setProperty("password","ketilinux")

/*    var rowdata = List(Row("keti"))
    rowdata ::= Row("50000", "1991-07-20", "Hyung-Joo", "Ahn", "M", "2016-03-23")
    val rows = sc.parallelize(rowdata)
*/



    // Read Test

    var emp = sqlContext.read.jdbc(url, "tmp_employees", prop).collect
    //emp.foreach(println) 

    // Insert Test

    var i = 0
    var k = 0

    for (i <- 0 to 999){
	emp +:= Row(500000 + i, "1991-09-20", "Hyung-Joo", "Ahn", "M", "2016-03-23")
    }


    // Update Test
 
    for (k <- 0 to 999){
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

    
    // Delete Test
    for (k <- 0 to 999){
           breakable{emp.foreach( x => {
                   if(x(0) == 500000 + k){

                           emp = emp.filter(x => x(0) != 500000 + k)
                           break
                   }
           })}
    }


    // Create DataFrame 
    
    var emprows = sc.parallelize(emp) 

    val data = sqlContext.createDataFrame(emprows, StructType(List
	(StructField("emp_no", IntegerType),
	StructField("birth_date",StringType),
	StructField("first_name",StringType),
	StructField("last_name",StringType),
	StructField("gender",StringType),
	StructField("hire_date",StringType))))



    // Insert DataFrame 

    data.insertIntoJDBC(url, "tmp_employees", true)
    // URL, Table Name, Overwrite

  }
}
