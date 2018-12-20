package main

import (
	"database/sql"
	"flag"
	"fmt"
	"log"
	_ "odbc/driver"
)

func main() {

	tableName := flag.String("t", "people", "Database Table")
	flag.Parse()

	// DB Connect
	db, err := sql.Open("odbc", "DSN=Ketiodbc")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("\n=====Select Table=====\n")
	fmt.Println("Table Name :", *tableName, "\n")

	// Read Test ////////////////////////////////////////////////////////////////////
	stmtOut, err := db.Query("select * from " + *tableName)
	_ = stmtOut
	for stmtOut.Next() {
		var name string
		var id string
		err := stmtOut.Scan(&id, &name)
		if err != nil {
			log.Fatal(err)
		}

		fmt.Println(id, name)
	}
	fmt.Println("\n======================\n")

	defer db.Close()
}
