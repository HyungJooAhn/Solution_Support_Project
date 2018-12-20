package main

import (
	"flag"
	"fmt"
	"keti/squall/sql"
)

func main() {

	indexName := flag.String("i", "people", "Index Name")
	documentName := flag.String("d", "person", "Document Name")
	id := flag.String("id", "1", "ID")

	flag.Parse()

	// Initialize Index and Connect elasticsearch =================

	nosqlContext := sql.NoSQLContext()
	nosqlContext.NewEsConnect("localhost", "9200")

	// Create Index Test ====================

	nosqlContext.InitEsIndex(*indexName)
	err := nosqlContext.CreateEsIndex(*indexName)
	if err != nil {
		panic(err)
	}

	// Put Test =================

	put := nosqlContext.EsPut(*indexName, *documentName, *id, map[string]interface{}{
		"id":   1,
		"name": "Henry",
		"age":  30,
		"loc":  "Pil",
	})

	if put != nil {
		panic(put)
	}

	// Get Test ==================

	result, err := nosqlContext.EsGet(*indexName, *documentName, *id)
	if err != nil {
		panic(err)
	}

	fmt.Println("ID :", result.Source["id"])
	fmt.Println("Name :", result.Source["name"])
	fmt.Println("Age :", result.Source["age"])
	fmt.Println("Location :", result.Source["loc"])

	// Delete Test ====================

	del := nosqlContext.EsDelete(*indexName, *documentName, *id, map[string]interface{}{
		"id":   1,
		"name": "Henry",
		"age":  30,
		"loc":  "Pil",
	})
	if del != nil {
		panic(del)
	}

}
