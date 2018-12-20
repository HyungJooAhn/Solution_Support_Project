package main

import (
	"fmt"
	"keti/squall/sql"
	"log"
	"reflect"
	"strconv"
	"time"
)

func main() {

	tableName := "employees"
	count := 100

	sqlContext := sql.SQLContext()

	startTime := time.Now()

	df := sqlContext.CreateDataFrame(
		sql.NewColumnInfo([]string{}, reflect.String, "emp_no"),
		sql.NewColumnInfo([]string{}, reflect.String, "birth_date"),
		sql.NewColumnInfo([]string{}, reflect.String, "first_name"),
		sql.NewColumnInfo([]string{}, reflect.String, "last_name"),
		sql.NewColumnInfo([]string{}, reflect.String, "gender"),
		sql.NewColumnInfo([]string{}, reflect.String, "hire_date"),
	)

	prop := sql.NewProp()
	prop.SetDsn("Ketiodbc")
	prop.SetDriver("odbc")

	for i := 0; i < count; i++ {
		df.AddRow(sql.Row(strconv.Itoa(500002+i), "19910720", "HyungJoo", "Ahn", "M", "20170220"))
	}

	df.InsertODBC(tableName, "append")

	df.ConnectFormatODBC(prop)
	// Select Test //////////////////////////////////////

	rows, err := sqlContext.Query("SELECT * FROM " + tableName)

	if err != nil {
		log.Fatal(err)
	}
	/*	var emp_no string
		var birth string
		var first_name string
		var last_name string
		var gender string
		var hire_date string
	*/
	for rows.Next() {
		/*	perr := rows.Scan(&emp_no, &birth, &first_name, &last_name, &gender, &hire_date)
			if perr != nil {
				panic(err.Error())
			}

			fmt.Println(emp_no, birth, first_name, last_name, gender, hire_date)*/
	}
	endTime := time.Now()
	perTime := endTime.Sub(startTime)

	stmtDel, err := sqlContext.Prepare("DELETE FROM " + tableName + " WHERE emp_no>=500000")
	if err != nil {
		log.Fatal(err)
	}
	stmtDel.Exec()

	if tableName == "Empty" {
		fmt.Println("\nEmpty Table Time :", perTime.Seconds(), "sec\n")
	} else {
		fmt.Println("\nEmployees Table Time :", perTime.Seconds(), "sec\n")
	}

	defer sqlContext.Close()
}
