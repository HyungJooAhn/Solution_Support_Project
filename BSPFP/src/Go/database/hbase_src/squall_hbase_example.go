package main

import (
	"flag"
	"fmt"
	"keti/squall/sql"
	"log"
)

func main() {

	databaseName := flag.String("d", "test", "Database Name")
	rowName := flag.String("r", "row1", "Row Name")
	columnFamily := flag.String("c", "cf", "Column Family")
	cf_Name := flag.String("f", "a", "Column Family Name")

	flag.Parse()

	nosqlContext := sql.NoSQLContext()
	nosqlContext.NewClient("localhost", "/hbase")

	// Put Test ===========================================================

	err := nosqlContext.Put(*databaseName, *rowName, *columnFamily, *cf_Name, "Hi")

	if err != nil {
		panic(err)
	}

	log.Println("Completed put")

	// Get Test ===========================================================

	result, err := nosqlContext.Get(*databaseName, *rowName)

	if err != nil {
		panic(err)
	}

	log.Println("Completed get")
	fmt.Println("Column Family :", result.Columns[*columnFamily+":"+*cf_Name].Family)
	fmt.Println("Column Name :", result.Columns[*columnFamily+":"+*cf_Name].ColumnName)
	fmt.Println("Time Stamp :", result.Columns[*columnFamily+":"+*cf_Name].Timestamp)
	fmt.Println("Value :", result.Columns[*columnFamily+":"+*cf_Name].Value)

	// Delete Test =======================================================

	del := nosqlContext.Delete(*databaseName, *rowName, *columnFamily, *cf_Name)

	if del != nil {
		panic(err)
	}

	log.Println("Completed delete")

}
