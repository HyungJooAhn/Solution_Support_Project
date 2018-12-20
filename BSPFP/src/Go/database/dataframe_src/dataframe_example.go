package main

import (
	"container/list"
	"fmt"
	"github.com/kniren/gota/dataframe"
	"github.com/kniren/gota/series"
	"reflect"
	"strconv"
)

func w(w reflect.Kind) {
	println(w)
}

func main() {
	df := dataframe.New(
		series.New([]string{}, series.String, "emp_no"),
		series.New([]string{}, series.String, "birth_date"),
		series.New([]string{}, series.String, "first_name"),
		series.New([]string{}, series.String, "last_name"),
		series.New([]string{}, series.String, "gender"),
		series.New([]string{}, series.String, "hire_date"),
	)
	fmt.Println(reflect.TypeOf(series.String))
	listRow := list.New()
	for i := 0; i < 10; i++ {
		listRow.PushBack(strconv.Itoa(i))
		listRow.PushBack("1991-07-20")
		listRow.PushBack("Hyung-Joo")
		listRow.PushBack("Ahn")
		listRow.PushBack("M")
		listRow.PushBack("2017-03-03")
		df.AddRow(listRow)
		listRow = list.New()
	}

	fmt.Println(listRow)

	for i := 0; i < df.Ncol(); i++ {
		fmt.Println(df.Select(i))
	}
	filter := dataframe.F{
		Colname:    "emp_no",
		Comparator: series.Eq,
		Comparando: "2",
	}

	fdf := df.Filter(filter)
	for i := 0; i < fdf.Ncol(); i++ {
		fmt.Println(fdf.Select(i))
	}

	for e := listRow.Front(); e != nil; e = e.Next() {
		fmt.Println(e.Value)
	}

	//	fmt.Println(reflect.TypeOf(df.uintptr.Addrow(2)))
	//df.Addrow(listRow)
}
