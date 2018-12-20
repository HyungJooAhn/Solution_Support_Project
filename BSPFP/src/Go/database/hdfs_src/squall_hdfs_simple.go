package main

import (
	"fmt"
	"keti/squall/sql"
	"log"
)

func main() {

	// Define HDFSContext and Set Config

	hdfsContext := sql.HDFSContext()
	err := hdfsContext.NewConfig("localhost:50070", "root")
	if err != nil {
		log.Fatal(err)
	}

	/*
	 * Make Directory
	 * func MakeDirs(paths, permission)
	 */

	hdfsContext.MakeDirs([]string{"/user"}, "755")

	/*
	 * Put(Copy to hdfs from local)
	 * func Put(src_path, des_path, overwrite)
	 */

	err = hdfsContext.Put("/home/temp.txt", "/user", true)
	if err != nil {
		log.Fatal(err)
	}

	/*
	 * HDFS File Open
	 * func Open(path, offset, length, buffer_size)
	 */

	result, err := hdfsContext.Open("/user/temp.txt", 0, 512, 2048)

	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("\nFile :\n", result)

	/*
	 * Checksum
	 * func GetFileChecksum(path)
	 */

	checksum, err := hdfsContext.GetFileChecksum("/user/temp.txt")

	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("\nChecksum :", checksum)

	/*
	 * Get(Copy to local from hdfs)
	 * func Get(src_path, des_path)
	 */

	err = hdfsContext.Get("/user/temp.txt", "/home/des.txt")
	if err != nil {
		log.Fatal(err)
	}

	/*
	 * Delete File in HDFS
	 * func Delete(path, response)
	 */

	err = hdfsContext.Delete("/user/temp.txt", false)
	if err != nil {
		log.Fatal(err)
	}

}
