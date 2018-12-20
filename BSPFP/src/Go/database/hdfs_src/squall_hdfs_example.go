package main

import (
	"flag"
	"fmt"
	"keti/squall/sql"
	"log"
)

func main() {

	host := flag.String("h", "localhost:50070", "Host address and port")
	userid := flag.String("u", "root", "User ID")

	flag.Parse()

	// Define HDFSContext and Set Config

	hdfsContext := sql.HDFSContext()
	err := hdfsContext.NewConfig(*host, *userid)
	if err != nil {
		log.Fatal(err)
	}

	// Make Directory Test

	hdfsContext.MakeDirs([]string{"/user/Go"}, "755")

	// Put Test

	err = hdfsContext.Put("/home/keti/workspace/Tree/etc/Game/ball.go", "/user/Go", true)
	if err != nil {
		log.Fatal(err)
	}

	// Open Test

	result, err := hdfsContext.Open("/user/Go/ball.go", 0, 512, 2048)

	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("\nFile :\n", result)

	// Checksum Test

	checksum, err := hdfsContext.GetFileChecksum("/user/Go/ball.go")

	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("\nChecksum :", checksum)

	// Put Test

	err = hdfsContext.Put("/home/keti/workspace/Tree/test.go", "/user/Go", true)
	if err != nil {
		log.Fatal(err)
	}

	// Get Test - Get을 하기 위해서는 local에 덮어쓰기 위한 파일이 필요하다. (like des.go)
	err = hdfsContext.Get("/user/keti/ball.go", "/home/keti/workspace/Tree/etc/Game/des.go")
	if err != nil {
		log.Fatal(err)
	}

	// Delete Test

	err = hdfsContext.Delete("/user/keti/test.go", false)
	if err != nil {
		log.Fatal(err)
	}

}
