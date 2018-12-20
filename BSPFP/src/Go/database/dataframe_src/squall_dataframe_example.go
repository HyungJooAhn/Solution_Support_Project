package main

import (
	"flag"
	"fmt"
	"keti/squall/sql"
	"reflect"
)

func main() {

	databaseName := flag.String("d", "test", "Database Name")
	tableName := flag.String("t", "Empty", "Table Name")
	count := flag.Int("c", 10, "Count")
	unit := flag.Int("u", 3, "Unit Count")

	flag.Parse()

	sqlContext := sql.SQLContext()
	df := sqlContext.CreateDataFrame(
		sql.NewColumnInfo([]string{}, reflect.String, "emp_no"),
		sql.NewColumnInfo([]string{}, reflect.String, "birth_date"),
		sql.NewColumnInfo([]string{}, reflect.String, "first_name"),
		sql.NewColumnInfo([]string{}, reflect.String, "last_name"),
		sql.NewColumnInfo([]string{}, reflect.String, "gender"),
		sql.NewColumnInfo([]string{}, reflect.String, "hire_date"),
	)

	prop := sql.NewProp()
	prop.SetUrl("localhost:3306")
	prop.SetDriver("mysql")
	prop.SetDatabase(*databaseName)
	prop.SetUser("root")
	prop.SetPassword("ketilinux")

	df.ConnectFormat(prop)
	for i := 0; i < *count; i++ {
		df.AddRow(sql.Row("1", "1991-07-20", "HJ", "Ahn", "M", "2000-02-20"))

		if i%*unit == 0 {
			df.Insert(*tableName, "append")
			df.Clear()

		}
	}

	rows, err := sqlContext.Query("Select * from Empty")
	if err != nil {
		println("ERR")
	}
	var emp_no string
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
}
