package main

import (
	"fmt"
	"keti/squall/sql"
	"log"
)

func main() {

	// Connect Database

	sqlContext := sql.SQLContext()
	sqlContext.Open("odbc", "DSN=Ketiodbc")

	// Insert Test

	stmtIn, err := sqlContext.Prepare("INSERT INTO people values(1,'Herry')")

	if err != nil {
		log.Fatal(err)
	}

	stmtIn.Exec()

	// Update Test

	stmtUp, err := sqlContext.Prepare("UPDATE people SET name='Henry' WHERE id=1")
	if err != nil {
		log.Fatal(err)
	}
	stmtUp.Exec()

	// Select Test

	rows, err := sqlContext.Query("SELECT * FROM people")

	if err != nil {
		log.Fatal(err)
	}
	var id int
	var name string
	for rows.Next() {
		perr := rows.Scan(&id, &name)
		if perr != nil {
			panic(err.Error())
		}
		fmt.Println(id, name)
	}

	// Delete Test

	stmtDel, err := sqlContext.Prepare("DELETE FROM people WHERE id=1")
	if err != nil {
		log.Fatal(err)
	}
	stmtDel.Exec()

	defer sqlContext.Close()
}
