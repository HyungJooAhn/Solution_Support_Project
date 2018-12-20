package main

import (
	"database/sql"
	"fmt"
	"log"
	_ "odbc/driver"
)

func main() {

	// DB Connect
	db, err := sql.Open("odbc", "DSN=Altiodbc")
	if err != nil {
		log.Fatal(err)
	}

	// Insert Test ////////////////////////////////////////////////////////////////////

	for i := 0; i < 100; i++ {

		stmtIn, err := db.Query("insert into book values(?,'keti')", i)
		if err != nil {
			log.Fatal(err)
		}
		_ = stmtIn
	}

	// Update Test ///////////////////////////////////////////////////////////////////

	for i := 0; i < 100; i++ {

		stmtUp, err := db.Query("update book set title='ketilinux' where num=?", i)
		if err != nil {
			log.Fatal(err)
		}
		_ = stmtUp

	}

	// Read Test ////////////////////////////////////////////////////////////////////

	stmtOut, err := db.Query("select * from book")
	//		_ = stmtOut
	for stmtOut.Next() {
		var name string
		var id string
		err := stmtOut.Scan(&id, &name)
		if err != nil {
			log.Fatal(err)
		}

		fmt.Println(id, name)
	}

	// Delete Test /////////////////////////////////////////////////////////////////

	for i := 0; i < 100; i++ {

		stmtDel, err := db.Query("delete from book where num=?", i)
		if err != nil {
			log.Fatal(err)
		}
		_ = stmtDel
	}

	defer db.Close()
}
