package sql

import (
	"keti/squall/internal/log"
	"database/sql"
	_"database/sql/driver"
	"odbc"
	_ "github.com/go-sql-driver/mysql"
	_ "fmt"
)

var SQLContexts []*SQLContextType

type SQLStatement struct {
	jdbcStmt	*sql.Stmt
	odbcStmt	*odbc.Statement
}
type SQLContextType struct {
	Id		int
	conn		*odbc.Connection
	flag		bool
	db		*sql.DB
	stmt		SQLStatement
}

func SQLContext() (sc *SQLContextType) {
	sc = &SQLContextType {
		Id:	len(SQLContexts),
	}
	
	SQLContexts = append(SQLContexts, sc)

	log.Info.Println("Create SQL Context - Id", sc.Id)
	return
}


func (sc *SQLContextType) Open(driverName, dataSourceName string) error {

	if driverName == "odbc" {
		sc.flag = false
		conn, err := odbc.Connect(dataSourceName)
		if err != nil {
			panic(err)
			return err
		}
		
		sc.conn = conn
		return nil
	}

	sc.flag = true
	db, err := sql.Open(driverName, dataSourceName)

	if err != nil {
		panic(err)
		return err
	}

	sc.db = db

	return nil
}


func (sc *SQLContextType) Close() error {

	if sc.flag == false {
		sc.conn.Close()
		return nil
	}

	sc.db.Close()
	return nil
}


func (sc *SQLContextType) Prepare(query string) (SQLStatement, error) {
	
	if sc.flag == false {
		ostmt, err := sc.conn.Prepare(query)
		if err != nil {
			panic(err)
			return SQLStatement{nil, nil}, err
		}
		sc.stmt.odbcStmt = ostmt
		return SQLStatement{nil, ostmt}, nil		
	}
		
			
	jstmt, err := sc.db.Prepare(query)
	
	if err != nil {
		panic(err)
		return SQLStatement{nil, nil}, err
	}
	sc.stmt.jdbcStmt = jstmt

	return SQLStatement{jstmt, nil}, nil
}


func (stmt *SQLStatement) Exec(args ...interface{}) (sql.Result, error) {
	
	res, err := stmt.jdbcStmt.Exec(args)
	
	if err != nil {
		panic(err)
		return nil, err
	}

	return res, nil	
}	


func (stmt *SQLStatement) Execute(args ...interface{}) *odbc.ODBCError {

	err := stmt.odbcStmt.Execute(args...)
	return err

}


func (stmt *SQLStatement) NumFields() (int, *odbc.ODBCError) {

	nfields, err := stmt.odbcStmt.NumFields()
	if err != nil {
		panic(err)
		return -1, err
	}
	
	return nfields, nil

}


func (stmt *SQLStatement) Fetch() (bool, *odbc.ODBCError) {
	ret, err := stmt.odbcStmt.Fetch()
	if err != nil {
		panic(err)
		return false, err
	}

	return ret, nil
}

func (stmt *SQLStatement) FetchOne() (*odbc.Row, error) {
	
	row, err := stmt.odbcStmt.FetchOne()

	if err != nil {
		panic(err)
		return nil, err
	}
	
	return row, nil
}

func (stmt *SQLStatement) FetchAll() ([]*odbc.Row, error) {
	rows, err := stmt.odbcStmt.FetchAll()
	if err != nil {
		panic(err)
		return nil, err
	}
	
	return rows, nil
}


func (sc *SQLContextType) SQLQuery(query string) ([]*odbc.Row, error) {

	stmt, err := sc.Prepare(query)
	if err != nil {
		panic(err)
		return nil, err
	}
	exerr := stmt.Execute()
	if exerr != nil {
		panic(err)
		return nil, exerr
	}

	rows, err := stmt.FetchAll()

	if err != nil {
		panic(err)
		return nil, err
	}

	return rows, err
}

	
func (sc *SQLContextType) Query(query string) (*sql.Rows, error) {
	rows, err := sc.db.Query(query)

	if err != nil {
        	panic(err)
		return nil, err
        }
	
	return rows, nil
}



/* TO DO
func (sc *SQLContextType) CreateDataFrame()
*/
