#!/bin/sh

for ((k=0; k<3; k++));
do

for i in 10 100 1000 10000 100000 1000000; 
do
	echo "## $i ==============="
	go run $PWD/go_mysql_engine.go $i employees employees
	#go run $PWD/go_odbc_conn.go $i employees employees
done

done
