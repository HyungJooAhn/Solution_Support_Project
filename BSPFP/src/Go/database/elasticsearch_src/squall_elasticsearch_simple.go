package main

import (
	"fmt"
	"keti/squall/sql"
	"log"
)

func main() {

	// Connect elasticsearch

	nosqlContext := sql.NoSQLContext()
	nosqlContext.NewEsConnect("localhost", "9200")

	/*
	 * Create Index
	 *
	 * func InitEsIndex(index_name)
	 * Delete existed index

	 * func CreateEsIndex(index_name)
	 * Create index
	 */

	nosqlContext.InitEsIndex("keti")
	err := nosqlContext.CreateEsIndex("keti")
	if err != nil {
		log.Fatal(err)
	}

	/*
	 * Put
	 * func EsPut(index_name, document_name, id, field)
	 */

	put := nosqlContext.EsPut("keti", "loc_info", "1", map[string]interface{}{
		"id":  1,
		"loc": "SungNam",
	})

	if put != nil {
		log.Fatal(put)
	}

	/*
	 * Get
	 * func EsGet(index_name, document_name, id)
	 */

	result, err := nosqlContext.EsGet("keti", "loc_info", "1")
	if err != nil {
		panic(err)
	}

	fmt.Println("ID :", result.Source["id"])
	fmt.Println("Location :", result.Source["loc"])

	/*
	 * Delete
	 * func EsDelete(index_name, document_name, id, field)
	 */

	del := nosqlContext.EsDelete("keti", "loc_info", "1", map[string]interface{}{
		"id":  1,
		"loc": "SungNam",
	})
	if del != nil {
		log.Fatal(del)
	}

}
