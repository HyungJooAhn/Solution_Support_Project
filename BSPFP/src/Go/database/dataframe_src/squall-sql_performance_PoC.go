package main

import (
	"keti/squall/sql"
	"log"
	"os"
	"strconv"
	"time"
	"fmt"
	"reflect"
)

func main() {

	num := os.Args[1]
	count, _ := strconv.Atoi(num)

	databaseName := os.Args[2]

	tableName := os.Args[3]

	unit := os.Args[4]
	unit_count, _ := strconv.Atoi(unit)


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
	prop.SetUrl("172.0.0.6:3306")
	prop.SetDriver("mysql")
	prop.SetDatabase(databaseName)
	prop.SetUser("root")
	prop.SetPassword("ketilinux")

	//df.AddRow(sql.Row(strconv.Itoa(500001), "1991-07-20", "Hyung-Joo", "Ahn", "M", "2017-02-20"))
	df.ConnectFormat(prop)
	for i := 0; i < count; i++ {
		df.AddRow(sql.Row(strconv.Itoa(500002+i), "1991-07-20", "Hyung-Joo", "Ahn", "M", "2017-02-20"))

		if i %  unit_count == 0 {
			df.Insert(tableName, "append")
			df.Clear()

		}
	}
/*
	// Update Test //////////////////////////////////////

	for i := 0; i < count; i++ {
		sqlContext.Query("UPDATE " + tableName + " SET first_name='Keti" + strconv.Itoa(i) + "' WHERE emp_no=50000" + strconv.Itoa(i))
	}
*/
	// Select Test //////////////////////////////////////

	rows, err := sqlContext.Query("SELECT * FROM " + tableName)

	if err != nil {
		log.Fatal(err)
	}
/*	_ = rows
	var emp_no string
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
/*
	// Delete Test //////////////////////////////////////

	for i := 0; i < count; i++ {
		sqlContext.Query("DELETE FROM " + tableName + " WHERE emp_no=50000" + strconv.Itoa(i))
	}
*/
	endTime := time.Now()
	perTime := endTime.Sub(startTime)

	stmtDel, err := sqlContext.Prepare("DELETE FROM " + tableName + " WHERE emp_no>=500000")
	if err != nil {
		log.Fatal(err)
	}
	stmtDel.Exec()

	if tableName == "Empty" {
		fmt.Println("\nEmpty Table Time :", perTime.Seconds(), "sec\n")
	}else{
		fmt.Println("\nEmployees Table Time :", perTime.Seconds(), "sec\n")
}

	defer sqlContext.Close()
}
