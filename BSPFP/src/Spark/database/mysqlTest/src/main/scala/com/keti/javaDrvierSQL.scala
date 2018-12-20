package com.keti

import java.sql.DriverManager
import java.sql.Connection
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.sql.types.{StructField, StructType, IntegerType, StringType}
import org.apache.spark.sql.Row

object JavaDriverTest {
  def main(args: Array[String]) {

// #3 Java Driver를 import하여 사용하는 방법=====================================

    val driver = "com.mysql.jdbc.Driver"
    val url = "jdbc:mysql://172.0.0.6/" + args(1)
    val username = "root"
    val password = "ketilinux"

    // there's probably a better way to do this
    var connection:Connection = null
    var i = 0

    try {
      // Database Connect
      Class.forName(driver)
      connection = DriverManager.getConnection(url, username, password)
      println("// Database Connect //")


      // Create the statement, and run the select query
      val statement = connection.createStatement()

      
      val count = args(0).toInt
      val tablename = args(2)

      var totalTime : Long = 0



      // Insert Test /////////////////////////////////
      for(k <- 0 to 2) {

      	      var startTime = System.currentTimeMillis()

	      for(i <- 0 to count){
		      statement.executeUpdate("INSERT INTO " + tablename +" (emp_no, birth_date, first_name, last_name, gender, hire_date) VALUES (50000"+i.toString+", '1991-07-20', 'Hyung-Joo', 'Ahn', 'M', '2016-03-23')")
	      }




	      // Update Test ///////////////////////////////

	      for(i <- 0 to count){
		      statement.executeUpdate("UPDATE " + tablename +" SET birth_date='2000-10-10',hire_date='2018-10-10' WHERE emp_no=50000"+i.toString)
	      }





	      // Read Test /////////////////////////////////

	      val resultSet = statement.executeQuery("SELECT * FROM " + tablename )

		      while ( resultSet.next() ) {

			      /*        val emp_no = resultSet.getString("emp_no")
					val birth = resultSet.getString("birth_date")
					val first_name = resultSet.getString("first_name")
					val last_name = resultSet.getString("last_name")
					val gender = resultSet.getString("gender")
					val hire_date = resultSet.getString("hire_date")

					println(emp_no, birth, first_name, last_name, gender, hire_date)*/
		      }





	      // Delete Test ////////////////////////////////

	      for(i <- 0 to count){
		      statement.executeUpdate("DELETE FROM " + tablename + " WHERE emp_no=50000"+i.toString)
	      }

	      var estimatedTime = System.currentTimeMillis() - startTime
	      totalTime = totalTime + estimatedTime
      }
      val avgTime = totalTime.toFloat/3.0
      println("Time Average : " + (avgTime / 1000) + " sec")

    } catch {
	    case e => e.printStackTrace
    }
    connection.close()

  }

}
