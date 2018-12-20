package main

import (
	"fmt"
	"github.com/ariefdarmawan/hdfs"
	"github.com/vladimirvivien/gowfs"
	"io/ioutil"
	"log"
)

func main() {

	h, err := hdfs.NewHdfs(hdfs.NewHdfsConfig("http://localhost:50070", "hdfs"))
	if err != nil {
		log.Fatal(err)
	}

	es := h.MakeDirs([]string{"/user/root"}, "755")
	if es != nil {
		for k, v := range es {
			fmt.Println("Error when create %v : %v \n", k, v)
		}
	}

	fs, err := gowfs.NewFileSystem(gowfs.Configuration{Addr: "localhost:50070", User: "hdfs"})
	if err != nil {
		log.Fatal(err)
	}

	checksum, err := fs.GetFileChecksum(gowfs.Path{Name: "/user/keti/ball.go"})
	if err != nil {
		log.Fatal(err)
	}

	data, err := fs.Open(gowfs.Path{Name: "/user/keti/ball.go"}, 0, 512, 2048)

	rcvdData, _ := ioutil.ReadAll(data)
	fmt.Println(string(rcvdData))

	fmt.Println(checksum)

	shell := gowfs.FsShell{FileSystem: fs}

	_, err = shell.Put("/home/keti/workspace/Tree/test.go", "/user/keti", true)
	if err != nil {
		log.Fatal(err)
	}

	_, err = shell.Get("/user/keti/ball.go", "/home/keti/workspace/Tree/etc/Game/des.go")
	if err != nil {
		log.Fatal(err)
	}

	_, err = fs.Delete(gowfs.Path{Name: "/user/keti/test.go"}, false)
	if err != nil {
		log.Fatal(err)
	}

}
