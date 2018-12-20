package main

import (
	"database/sql"
	"fmt"
	_ "github.com/lib/pq"
	"log"
)

func main() {
	db, err := sql.Open("postgres", "user=postgres dbname=push sslmode=disable")

	if err != nil {
		log.Fatal(err)
	}

	// Select Test

	id := 1

	rows, err := db.Query("Select * from data where id = $1", id)

	if err != nil {
		log.Fatal(err)
	}

	var id_num int
	var name string

	for rows.Next() {
		perr := rows.Scan(&id_num, &name)

		if perr != nil {
			panic(err.Error())
		}

		fmt.Println(id_num, name)
	}

	// Insert Test

	stmtIn, err := db.Prepare("Insert into data values (3, 'Post')")
	if err != nil {
		log.Fatal(err)
	}
	stmtIn.Exec()

	// Updata Test

	stmtUp, err := db.Prepare("Update data set name='Herry' where id = 3")
	if err != nil {
		log.Fatal(err)
	}
	stmtUp.Exec()

	// Delete Test

	stmtDel, err := db.Prepare("Delete from data where id = 3")
	if err != nil {
		log.Fatal(err)
	}
	stmtDel.Exec()
}
