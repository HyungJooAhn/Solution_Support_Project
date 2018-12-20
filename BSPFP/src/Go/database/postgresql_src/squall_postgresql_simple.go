package main

import (
	"fmt"
	"keti/squall/sql"
	"log"
)

func main() {

	sqlContext := sql.SQLContext()
	sqlContext.Open("postgres", "user=postgres dbname=push sslmode=disable")

	defer sqlContext.Close()

	// Insert
	stmtIn, err := sqlContext.Prepare("INSERT INTO keti VALUES (1, 'SungNam')")

	if err != nil {
		log.Fatal(err)
	}

	stmtIn.Exec()

	// Update
	sqlContext.Query("UPDATE keti SET location='Seoul' WHERE id=1")

	// Select
	rows, err := sqlContext.Query("SELECT * FROM keti")

	if err != nil {
		log.Fatal(err)
	}
	var id int
	var location string

	for rows.Next() {
		perr := rows.Scan(&id, &location)
		if perr != nil {
			panic(err.Error())
		}

		fmt.Println(id, location)
	}

	// Delete
	sqlContext.Query("DELETE FROM keti")

}
