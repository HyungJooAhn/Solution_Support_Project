package main

import "database/sql"
import _ "github.com/go-sql-driver/mysql"
import "fmt"
import "log"
import "keti/thunderbolt/sql"

func main() {

	// JDBC Configuration

	driver := "com.mysql.jdbc.Driver"
	url := "jdbc:mysql://10.0.7.103/employees?user=root&password=ketilinux"
	dbtable := "employees"

	// SQLContext

	sqlContext := sql.SQLContext()
	jdbcConn, err := sqlContext.read.format("jdbc").option(map[string]string{"driver": driver, "url": url, "dbtable": dbtable}).connect()

	if err != nil {
		log.Fatal(err)
	}

	// SQL Execution

	// Read
	resultDB := sqlContext.sql("SELECT * FROM employees")
	for _, result := range resultDB {
		fmt.Println(result)
	}

	// Insert
	sqlContext.sql("INSERT INTO TABLE employees (emp_no, birth_date, first_name, last_name, gender, hire_date) VALUES (500000, '1991-08-08', 'Gil-Dong', 'Hong', 'M', '2010-09-09')")

	// Update
	sqlContext.sql("UPDATE employees SET birth_date='2000-07-20',hire_date='2018-03-22' WHERE emp_no=500000")

	// Delete
	sqlContext.sql("DELETE FROM employees WHERE empno=500000")

	// Create DataFrame and insert

	rowdatas := []Row{""}
	rowdatas = append(rowdatas, "keti")

	dataFrame := sqlContext.createDataFrame(rowdatas, []string{"UserNumber", "UserName"})
	dataFrame.insertIntoJDBC(url, dbtable, true)

	//Connect Database

	db, err := sql.Open("mysql", "root:ketilinux@tcp(10.0.7.103:3306)/employees")
	if err != nil {
		panic(err.Error()) // Just for example purpose. You should use proper error handling instead of panic
	}
	println("// Connect Database //")
	defer db.Close()

	// Read Test

	stmtOut, err := db.Query("SELECT * FROM employees")
	if err != nil {
		panic(err.Error()) // proper error handling instead of panic in your app
	}

	defer stmtOut.Close()

	// Print result to read from database
	var emp_no string
	var birth string
	var first_name string
	var last_name string
	var gender string
	var hire_date string

	for stmtOut.Next() {
		err := stmtOut.Scan(&emp_no, &birth, &first_name, &last_name, &gender, &hire_date)
		if err != nil {
			panic(err.Error())
		}
		fmt.Println(emp_no, birth, first_name, last_name, gender, hire_date)
	}

	// Insert Test

	stmtIn, err := db.Prepare("INSERT INTO employees (emp_no, birth_date, first_name, last_name, gender, hire_date) VALUES (?,?,?,?,?,?)")
	if err != nil {
		log.Fatal(err)
	}
	for i := 0; i < 100; i++ {
		stmtIn.Exec(500000+i, "1991-07-20", "Hyung-Joo", "Ahn", "M", "2016-03-22")
	}
	fmt.Println("Insert com")

	// Update Test

	stmtUp, err := db.Prepare("UPDATE employees set birth_date=?,hire_date=? where emp_no=?")
	if err != nil {
		log.Fatal(err)
	}
	for i := 0; i < 100; i++ {
		stmtUp.Exec("1999-07-20", "2018-03-22", 500000+i)
	}
	fmt.Println("Update com")

	// Delete Test

	stmDel, err := db.Prepare("DELETE FROM employees where emp_no=?")
	if err != nil {
		log.Fatal(err)
	}
	for i := 0; i < 100; i++ {
		stmDel.Exec(500000 + i)
	}
	fmt.Println("Delete com")

}
