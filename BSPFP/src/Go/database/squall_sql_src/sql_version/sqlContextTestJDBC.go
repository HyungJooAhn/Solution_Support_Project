package main

import (
	_ "fmt"
	sql "keti/squall/sql/context_sql"
	"log"
	"os"
	"strconv"
)

func main() {
	num := os.Args[1]
	count, _ := strconv.Atoi(num)

	sqlContext := sql.SQLContext()

	sqlContext.Open("mysql", "root:ketilinux@tcp(10.0.7.100:3306)/employees")
	defer sqlContext.Close()
	// Insert Test //////////////////////////////////////

	for i := 0; i < count; i++ {
		sqlContext.Query("INSERT INTO tmp_employees (emp_no, birth_date, first_name, last_name, gender, hire_date) VALUES (50000" + strconv.Itoa(i) + ", '1991-07-20', 'Hyung-Joo', 'Ahn', 'M', '2016-03-22')")
	}

	// Update Test //////////////////////////////////////

	for i := 0; i < count; i++ {
		sqlContext.Query("UPDATE tmp_employees SET first_name='Keti" + strconv.Itoa(i) + "' WHERE emp_no=50000" + strconv.Itoa(i))
	}

	// Select Test //////////////////////////////////////

	rows, err := sqlContext.Query("SELECT * FROM tmp_employees")

	if err != nil {
		log.Fatal(err)
	}

	/*var emp_no string
	var birth string
	var first_name string
	var last_name string
	var gender string
	var hire_date string
	*/
	for rows.Next() {
		/*		perr := rows.Scan(&emp_no, &birth, &first_name, &last_name, &gender, &hire_date)
				if perr != nil {
					panic(err.Error())
				}

				fmt.Println(emp_no, birth, first_name, last_name, gender, hire_date)*/
	}

	// Delete Test //////////////////////////////////////

	for i := 0; i < count; i++ {
		sqlContext.Query("DELETE FROM tmp_employees WHERE emp_no=50000" + strconv.Itoa(i))
	}

}
