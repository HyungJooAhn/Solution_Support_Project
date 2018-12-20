package main

import (
	_ "fmt"
	sql "keti/squall/sql/context_sql"
	"log"
	"strconv"
)

func main() {

	sqlContext := sql.SQLContext()
	sqlContext.Open("odbc", "DSN=Altiodbc")

	for i := 0; i < 100; i++ {
		sqlContext.Query("INSERT INTO book VALUES(" + strconv.Itoa(i) + ", 'keti" + strconv.Itoa(i) + "')")
	}

	for i := 0; i < 100; i++ {
		sqlContext.Query("UPDATE book SET TITLE='ketilinux" + strconv.Itoa(i) + "' WHERE NUM=" + strconv.Itoa(i))
	}

	rows, err := sqlContext.Query("SELECT * FROM book")

	_ = rows

	if err != nil {
		log.Fatal(err)
	}

	for rows.Next() {
		var num string
		var title string
		err := rows.Scan(&num, &title)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Println(num, title)
	}

	for i := 0; i < 100; i++ {
		sqlContext.Query("DELETE FROM book WHERE NUM=" + strconv.Itoa(i))
	}

}
