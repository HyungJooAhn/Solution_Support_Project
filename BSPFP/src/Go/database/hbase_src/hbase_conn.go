package main

import (
	"bytes"
	"flag"
	"fmt"
	"github.com/lazyshot/go-hbase"
	"log"
	"reflect"
)

func main() {

	databaseName := flag.String("d", "test", "Database Name")
	rowName := flag.String("r", "row1", "Row Name")
	columnFamily := flag.String("c", "cf", "Column Family")
	cf_Name := flag.String("f", "a", "Column Family Name")

	flag.Parse()

	client := hbase.NewClient([]string{"localhost"}, "/hbase")

	// Put Test ===========================================================

	put := hbase.CreateNewPut([]byte(*rowName))          // insert 할Row 이름, Row 이름이 같고 값만 다르면 Update 할 수 있다.
	put.AddStringValue(*columnFamily, *cf_Name, "Henry") // Column Family, Column 이름, insert할 값
	res, err := client.Put(*databaseName, put)           // 데이터베이스 이름

	if err != nil {
		panic(err)
	}

	if !res {
		panic("No put results")
	}

	log.Println("Completed put")

	// Get Test ===========================================================

	get := hbase.CreateNewGet([]byte(*rowName))   // Get 할Row의이름
	result, err := client.Get(*databaseName, get) // Get 할 데이터베이스 이름

	if err != nil {
		panic(err)
	}

	if !bytes.Equal(result.Row, []byte(*rowName)) {
		panic("No row")
	}

	if !bytes.Equal(result.Columns[*columnFamily+":"+*cf_Name].Value, []byte("Henry")) {
		panic("Value doesn't match")
	}

	log.Println("Completed get")
	//fmt.Println("EE:", reflect.TypeOf(result))
	fmt.Println("Column Family :", result.Columns[*columnFamily+":"+*cf_Name].Family)
	fmt.Println("Column Name :", result.Columns[*columnFamily+":"+*cf_Name].ColumnName)
	fmt.Println("Time Stamp :", result.Columns[*columnFamily+":"+*cf_Name].Timestamp)
	fmt.Println("Value :", result.Columns[*columnFamily+":"+*cf_Name].Value) // 읽어온 데이터값 확인

	// Delete Test =======================================================

	delete := hbase.CreateNewDelete([]byte(*rowName))
	delete.AddStringColumn(*columnFamily, *cf_Name)
	del, err := client.Delete(*databaseName, delete)
	_ = del
	if err != nil {
		panic(err)
	}

	log.Println("Completed delete")

	// Results Test ======================================================

	/*	results, err := client.Gets(*databaseName, []*hbase.Get{get})

		if err != nil {
			panic(err)
		}

		fmt.Printf("%#v\n", results) // 데이터 타입 및 내제 데이터 확인*/
}
