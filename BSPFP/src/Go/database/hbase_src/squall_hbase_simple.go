package main

import (
	"fmt"
	"keti/squall/sql"
	"log"
)

func main() {

	nosqlContext := sql.NoSQLContext()
	nosqlContext.NewClient("localhost", "/hbase")

	/* Put
	 * Put(database_name, row_name, column_family, column_family_name, value)
	 */
	err := nosqlContext.Put("keti", "row1", "cf", "a", "Squall")

	if err != nil {
		log.Fatal(err)
	}

	/* Get
	 * Get(database_name, row_name)
	 */
	result, err := nosqlContext.Get("keti", "row1")

	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Column Family :", result.Columns["cf:a"].Family)
	fmt.Println("Column Name :", result.Columns["cf:a"].ColumnName)
	fmt.Println("Time Stamp :", result.Columns["cf:a"].Timestamp)
	fmt.Println("Value :", result.Columns["cf:a"].Value)

	/* Delete
	 * Delete(database_name, row_name, column_family, column_family_name)
	 */

	del := nosqlContext.Delete("keti", "row1", "cf", "a")

	if del != nil {
		log.Fatal(err)
	}
}
