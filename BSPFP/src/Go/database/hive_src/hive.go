package main

import (
	"fmt"
	hive "github.com/mattbaird/hive"
	"log"
)

/*
func init() {
	hive.MakePool("10.0.7.100:10000")
}
*/
/*
func main() {

	// checkout a connection
	conn, err := hive.GetHiveConn()
	if err == nil {
		fmt.Println("Connect")
		//	_, _ = conn.Client.Execute("CREATE TABLE rrr(a STRING, b INT, c DOUBLE);")
		er, err := conn.Client.Execute("SELECT * FROM name LIMIT 1")
		if er == nil && err == nil {
			for {
				row, _, _ := conn.Client.FetchOne()
				if len(row) > 0 {
					log.Println("row ", row)
				} else {
					return
				}
			}
		} else {
			log.Println(er, err)
		}
	}
	if conn != nil {
		// make sure to check connection back into pool
		conn.Checkin()
	}
}*/
func main() {

	hive.MakePool("10.0.7.100:10000")
	fmt.Println("Make Pool")
	conn, err := hive.GetHiveConn()

	conn.Open()
	fmt.Println("Connect")
	if err == nil {
		fmt.Println("No ERR")
		er, err := conn.Client.Execute("SELECT * FROM test.book")
		fmt.Println(err)
		if er == nil && err == nil {
			fmt.Println("row??????")
			for {
				row, _, _ := conn.Client.FetchOne()
				log.Println("row ", row)
			}
		}
	}
	if conn != nil {
		// make sure to check connection back into pool
		fmt.Println("ERRRRR")
		conn.Checkin()
	}
}
