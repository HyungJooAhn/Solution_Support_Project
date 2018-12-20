package main 

import ( 
	_ "bitbucket.org/miquella/mgodbc"
	"database/sql"
	"log"
	"strconv"
) 

func main() { 

        db, err := sql.Open("mgodbc", "DSN=Altiodbc")
        //db, err := sql.Open("mgodbc", "DRIVER=ALTIBASE_HDB_ODBC_64bit;User=keti;Password=ketilinux;Server=127.0.0.1;PORT=20300;NLS_USE=US7ASCII;LongDataCompat=OFF")

	if err != nil {
		log.Fatal(err)
	}
/*
	var (
		id string
		name string
	)
*/

// Insert Test ////////////////////////////////////////////////////
        
        for i := 0; i < 100; i++ {
                db.Query("INSERT INTO book VALUES ("+strconv.Itoa(i)+",'Keti"+strconv.Itoa(i)+"')")
        }


// Update Test ////////////////////////////////////////////////////
        
        for i := 0; i < 100; i++ {
                db.Query("UPDATE book SET TITLE='KetiLinux' WHERE NUM="+strconv.Itoa(i))
        }



// Read Test //////////////////////////////////////////////////////

	rows, err := db.Query("select * from book")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
/*	for rows.Next() {
		err := rows.Scan(&id, &name)
		if err != nil {
			log.Fatal(err)
		}
		log.Println(id, name)
	}
	err = rows.Err()
	if err != nil {
		log.Fatal(err)
	}

*/
// Delete Test ////////////////////////////////////////////////////

	for i := 0; i < 100; i++ {
		db.Query("DELETE FROM book WHERE NUM="+strconv.Itoa(i))
	}

	
	defer db.Close()


}
