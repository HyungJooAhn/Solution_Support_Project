package main

import (
	"flag"
	"fmt"
	"github.com/belogik/goes"
	"net/url"
	"os"
)

var (
	ES_HOST = "localhost"
	ES_PORT = "9200"
)

func getConnection() (conn *goes.Connection) {
	h := os.Getenv("TEST_ELASTICSEARCH_HOST")

	if h == "" {
		h = ES_HOST
	}

	p := os.Getenv("TEST_ELASTICSEARCH_PORT")

	if p == "" {
		p = ES_PORT
	}

	conn = goes.NewConnection(h, p)

	return
}

func main() {

	indexName := flag.String("i", "people", "Index Name")
	documentName := flag.String("d", "person", "Document Name")
	id := flag.String("id", "1", "ID")

	flag.Parse()

	// Connect elasticsearch =================

	conn := getConnection()
	conn.DeleteIndex(*indexName)

	// Create Index Test ====================

	_, err := conn.CreateIndex(*indexName, map[string]interface{}{})
	//defer conn.DeleteIndex(indexName) // Delete Index

	// Put Document and Source Test =================

	doc := goes.Document{
		Index: *indexName,
		Type:  *documentName,
		Id:    *id,
		Fields: map[string]interface{}{
			"id":   1,
			"name": "Henry",
			"age":  30,
			"loc":  "Pil",
		},
	}

	response, err := conn.Index(doc, url.Values{})
	if err != nil {
		panic(err)
	}
	_ = response

	// Get Source Test ==================

	result, err := conn.Get(*indexName, *documentName, *id, url.Values{})
	if err != nil {
		panic(err)
	}

	fmt.Println("ID :", result.Source["id"])
	fmt.Println("Name :", result.Source["name"])
	fmt.Println("Age :", result.Source["age"])
	fmt.Println("Location :", result.Source["loc"])

	// Delete Source Test ====================

	del, err := conn.Delete(doc, url.Values{})
	if err != nil {
		panic(err)
	}
	_ = del

}
