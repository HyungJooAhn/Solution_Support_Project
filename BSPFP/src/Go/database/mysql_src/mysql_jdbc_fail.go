package main

import "database/sql"
import _ "github.com/go-sql-driver/mysql"
import _ "go-jdbc"

import "fmt"
import "log"
import _ "keti/thunderbolt/streaming"
import "strconv"

const ip = "tcp://10.0.7.100:3306/test"

func main() {

	// Connect Database
	//	db, err := sql.Open("mysql", "root:ketilinux@tcp(10.0.0.94:3306)/employees")
	db, err := sql.Open("jdbc", "tcp://10.0.0.94:3306/test")
	if err != nil {
		fmt.Println("Connect ERR")
		panic(err.Error()) // Just for example purpose. You should use proper error handling instead of panic
	}
	println("// Connect Database //")
	defer db.Close()

	// Read Test
	/*
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
			//		fmt.Println(emp_no, birth, first_name, last_name, gender, hire_date)
		}
	*/

	// Insert Test

	/* Using Query */

	for i := 0; i < 10; i++ {
		stmtIn, err := db.Query("INSERT INTO employees (emp_no, birth_date, first_name, last_name, gender, hire_date) VALUES (50000" + strconv.Itoa(i) + ", '1991-07-20', 'Hyung-Joo', 'Ahn', 'M', '2016-03-22')")
		if err != nil {
			log.Fatal(err)
		}
		_ = stmtIn
	}

	/*
		 * Using Prepare *

			stmtIn, err := db.Prepare("INSERT INTO employees (emp_no, birth_date, first_name, last_name, gender, hire_date) VALUES (?, ?, ?, ?, ?, ?)")
			for i := 0; i < 1000; i++ {
				stmtIn.Exec(500000+i, "1991-07-20", "Hyung-Joo", "Ahn", "M", "2016-03-22")
			}
			//	fmt.Println("Insert com")
	*/

	// Update Test
	/*
		stmtUp, err := db.Prepare("UPDATE employees set birth_date=?,hire_date=? where emp_no=?")
		if err != nil {
			log.Fatal(err)
		}
		for i := 0; i < 10; i++ {
			stmtUp.Exec("1999-07-20", "2018-03-22", 500000+i)
		}
		//	fmt.Println("Update com")
	*/
	// Read Test
	/*
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
			//              fmt.Println(emp_no, birth, first_name, last_name, gender, hire_date)
		}
	*/
	// Delete Test
	/*
		stmDel, err := db.Prepare("DELETE FROM employees where emp_no=?")
		if err != nil {
			log.Fatal(err)
		}
		for i := 0; i < 10; i++ {
			stmDel.Exec(500000 + i)
		}
		//	fmt.Println("Delete com")
	*/
}
