package main

import (
	"fmt"
	"keti/squall/sql"
	"log"
)

func main() {

	sqlContext := sql.SQLContext()
	sqlContext.Open("odbc", "DSN=Ketiodbc")

	defer sqlContext.Close()

	// Insert
	stmtIn, err := sqlContext.Prepare("INSERT INTO keti VALUES (?, ?)")

	if err != nil {
		log.Fatal(err)
	}

	stmtIn.Exec(1, "SungNam")

	// Update
	sqlContext.Query("UPDATE keti SET location='Seoul' WHERE id=1")

	// Select
	result, err := sqlContext.Query("SELECT * FROM keti")
	if err != nil {
		log.Fatal(err)
	}

	var id int
	var location string

	for result.Next() {
		perr := result.Scan(&id, &location)
		if perr != nil {
			panic(err.Error())
		}

		fmt.Println(id, location)
	}

	// Delete
	sqlContext.Query("DELETE FROM keti")

}
