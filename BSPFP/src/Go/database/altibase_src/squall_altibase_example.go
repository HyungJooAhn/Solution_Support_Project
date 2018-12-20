package main

import (
	"fmt"
	sql "keti/squall/sql"
	//sql "keti/squall/sql/odbc_tmp"
	"flag"
	"log"
	_ "strconv"
	"time"
)

func main() {

	num := flag.Int("n", 10, "Query Count")
	databaseName := flag.String("d", "employees", "Database Name")
	tableName := flag.String("t", "employees", "Table Name")

	flag.Parse()

	_ = databaseName

	connStartTime := time.Now()
	var totalTime time.Duration
	var avgTime time.Duration

	sqlContext := sql.SQLContext()

	//sqlContext.Open("mysql", "root:ketilinux@tcp(localhost:3306)/"+*databaseName)

	sqlContext.Open("odbc", "DSN=Ketiodbc")
	//sqlContext.Open("mgodbc", "DSN=ketiodbc")

	connEndTime := time.Now()
	connTime := connEndTime.Sub(connStartTime)

	startTime := time.Now()

	// Insert Test //////////////////////////////////////
	stmtIn, err := sqlContext.Prepare("INSERT INTO " + *tableName + " (emp_no, birth_date, first_name, last_name, gender, hire_date) VALUES (?, TO_DATE('1991-07-20','YYYY-MM-DD'), 'Hyung-Joo', 'Ahn', 'M', TO_DATE('2016-03-22','YYYY-MM-DD'))")

	//stmtIn, err := sqlContext.Prepare("INSERT INTO " + *tableName + " (emp_no, birth_date, first_name, last_name, gender, hire_date) VALUES (?, '1991-07-20', 'Hyung-Joo', 'Ahn', 'M','2016-03-22')")

	if err != nil {
		log.Fatal(err)
	}

	for i := 0; i < *num; i++ {
		stmtIn.Exec(500000 + i)
		//sqlContext.Query("INSERT INTO " + *tableName + " (emp_no, birth_date, first_name, last_name, gender, hire_date) VALUES (50000" + strconv.Itoa(i) + ", '1991-07-20', 'Hyung-Joo', 'Ahn', 'M', '2016-03-22')")
	}
	/*
		// Update Test //////////////////////////////////////

		for i := 0; i < *num; i++ {
			sqlContext.Query("UPDATE " + *tableName + " SET first_name='Keti" + strconv.Itoa(i) + "' WHERE emp_no=50000" + strconv.Itoa(i))
		}
	*/
	// Select Test //////////////////////////////////////

	rows, err := sqlContext.Query("SELECT * FROM " + *tableName)

	if err != nil {
		log.Fatal(err)
	}
	_ = rows
	/*var emp_no string
	var birth string
	var first_name string
	var last_name string
	var gender string
	var hire_date string

	for rows.Next() {
				perr := rows.Scan(&emp_no, &birth, &first_name, &last_name, &gender, &hire_date)
				if perr != nil {
					panic(err.Error())
				}

				fmt.Println(emp_no, birth, first_name, last_name, gender, hire_date)
	}

	// Delete Test //////////////////////////////////////

	for i := 0; i < *num; i++ {
		sqlContext.Query("DELETE FROM " + *tableName + " WHERE emp_no=50000" + strconv.Itoa(i))
	}
	*/
	endTime := time.Now()
	perTime := endTime.Sub(startTime)
	totalTime = totalTime + perTime

	//	time.Sleep(10000 * time.Millisecond)
	stmtDel, err := sqlContext.Prepare("DELETE FROM " + *tableName + " WHERE emp_no>=500000")
	if err != nil {
		log.Fatal(err)
	}
	stmtDel.Exec()

	avgTime = (totalTime + connTime)

	if *tableName == "Empty" {
		fmt.Println("\nEmpty Table Time :", avgTime.Seconds(), "sec\n")
	} else {
		fmt.Println("\nEmployees Table Time :", avgTime.Seconds(), "sec\n")
	}

	defer sqlContext.Close()
}
