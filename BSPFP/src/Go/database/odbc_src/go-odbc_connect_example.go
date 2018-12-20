package main 


import ( 
	"log"
	"odbc"
	"strconv"
	_"fmt"
) 

func main() { 

    conn, err := odbc.Connect("DSN=Altiodbc")
    if err != nil {
        log.Fatal(err)
    }

// Insert Test /////////////////////////////////////////////////////////

    stmtIn, err := conn.Prepare("INSERT INTO book VALUES (?,?)")
	    if err != nil {
		    log.Fatal(err)
	    }
    for i := 0; i < 100; i ++ {
	    stmtIn.Execute(strconv.Itoa(i), "Keti"+strconv.Itoa(i))
    }

// Update Test /////////////////////////////////////////////////////////

    for i := 0; i < 100; i ++ {
	    stmtUp, err := conn.Prepare("UPDATE book SET TITLE='KetiLinux'"+" WHERE NUM="+strconv.Itoa(i))
		    if err != nil {
			    log.Fatal(err)
		    }
	    stmtUp.Execute()
    } 

// Read Test /////////////////////////////////////////////////////////

    stmt, err := conn.Prepare("SELECT * FROM book")
	    if err != nil {
        log.Fatal(err)
    }

    err = stmt.Execute()
    if err != nil {
        log.Fatal(err)
    }


    nfields, err := stmt.NumFields();
    if err != nil {
        log.Fatal(err)
    }

    println( "Number of fields", nfields );

    for i := 0; i < nfields; i ++ {
        field, err := stmt.FieldMetadata( i + 1 );
        if err != nil {
            log.Fatal(err)
        }
        println( "\tField:", i + 1, "Name:", field.Name );
    }

/*
    println( "" );


    row, err := stmt.FetchOne()
    if err != nil {
        log.Fatal(err)
    }

    for row != nil {

        println( "Row" )

        ival := row.GetString( 0 )
        println( "\t", "Num : ", ival );

        sval := row.GetString( 1 )
        println( "\t", "Title : ", sval );

        row, err = stmt.FetchOne()
        if err != nil {
            log.Fatal(err)
        }
    }
*/
// Delete Test /////////////////////////////////////////////////////////

    for i := 0; i < 100; i ++ {
            stmtDel, err := conn.Prepare("DELETE FROM book WHERE NUM="+strconv.Itoa(i))
                    if err != nil {
                            log.Fatal(err)
                    }
            stmtDel.Execute()
    }

    stmt.Close()
    conn.Close()

}

