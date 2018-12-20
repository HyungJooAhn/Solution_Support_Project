package main

import (
	sql "keti/squall/sql/context_sql_conn"
 	"log"
	"strconv"
)

func main(){
	sqlContext := sql.SQLContext()
	
	sqlContext.Open("odbc","DSN=Altiodbc")
//	sqlContext.Open("mysql", "root:ketilinux@tcp(10.0.7.100:3306)/employees")


	for i := 0; i < 100; i ++ {
                sqlContext.SQLQuery("INSERT INTO book VALUES(" + strconv.Itoa(i) + ", 'keti" + strconv.Itoa(i) + "')")
        }

        for i := 0; i < 100; i ++ {
                sqlContext.SQLQuery("UPDATE book SET TITLE='ketilinux" + strconv.Itoa(i) + "' WHERE NUM=" + strconv.Itoa(i))
        }
	
	rows, err := sqlContext.SQLQuery("SELECT * FROM book")
//	rows, err := sqlContext.Query("SELECT * FROM employees")
	
	_ = rows	
	if err != nil {
		log.Fatal(err)
	}	

/*        for i := 0; i < len(rows); i ++ {
                println( "Row" )
                ival := rows[i].GetString( 0 )
                println( "\t", "Num : ", ival );

                sval := rows[i].GetString( 1 )
                println( "\t", "Title : ", sval );


                if err != nil {
                        log.Fatal(err)
                }
        }
*/
        for i := 0; i < 100; i ++ {
                sqlContext.SQLQuery("DELETE FROM book WHERE NUM=" + strconv.Itoa(i))
        }

/* MySQL

	// Print result to read from database
	var emp_no string
	var birth string
	var first_name string
	var last_name string
	var gender string
	var hire_date string

	for rows.Next() {
		perr := rows.Scan(&emp_no, &birth, &first_name, &last_name, &gender, &hire_date)
	     	if perr != nil {
		     panic(err.Error())
	 	}
                
		fmt.Println(emp_no, birth, first_name, last_name, gender, hire_date)
	}
*/

}
