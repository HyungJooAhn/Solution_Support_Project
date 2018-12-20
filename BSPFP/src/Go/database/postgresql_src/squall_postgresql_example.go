package main

import (
	"flag"
	"fmt"
	sql "keti/squall/sql"
	"log"
)

func main() {

	user := flag.String("u", "postgres", "Postgresql User Name")
	database := flag.String("d", "push", "Database Name")
	table := flag.String("t", "data", "Table Name")
	flag.Parse()

	sqlContext := sql.SQLContext()
	sqlContext.Open("postgres", "user="+*user+" dbname="+*database+" sslmode=disable")

	// Select Test

	rows, err := sqlContext.Query("Select * from " + *table)
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

	stmtIn, err := sqlContext.Prepare("Insert into data values (3, 'Post')")
	if err != nil {
		log.Fatal(err)
	}
	stmtIn.Exec()

	// Updata Test

	stmtUp, err := sqlContext.Prepare("Update data set name='Herry' where id = 3")
	if err != nil {
		log.Fatal(err)
	}
	stmtUp.Exec()

	// Delete Test

	stmtDel, err := sqlContext.Prepare("Delete from data where id = 3")
	if err != nil {
		log.Fatal(err)
	}
	stmtDel.Exec()
}
