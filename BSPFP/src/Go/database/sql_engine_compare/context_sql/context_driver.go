package sql

import (
	"database/sql"
	"database/sql/driver"
	_ "fmt"

	//_ "github.com/go-sql-driver/mysql" // version 1.2
	_ "github.com/go-sql-driver-ori/mysql" // version 1.1
	//_ "github.com/Go-SQL-Driver/MySQL" // version beta3

	jdbc "japettyjohn/go-jdbc"
	"keti/datastruct/enzyme/optimizer"
	"keti/squall/internal/log"

	_ "odbc/driver"
	//_ "bitbucket.org/miquella/mgodbc"
	//_ "github.com/silvasur/go-odbc/odbc/driver"
	//_ "github.com/alexbrainman/odbc"

	_ "github.com/lib/pq"
)

var SQLContexts []*SQLContextType

type SQLContextType struct {
	Id      int
	db      *sql.DB
	stmt    *sql.Stmt
	jdriver jdbc.Driver
	jconn   driver.Conn
	jstmt   driver.Stmt
}

func SQLContext() (sc *SQLContextType) {
	sc = &SQLContextType{
		Id: len(SQLContexts),
	}

	SQLContexts = append(SQLContexts, sc)

	log.Info.Println("Create SQL Context - Id", sc.Id)
	return
}

func (sc *SQLContextType) Open(driverName, dataSourceName string) error {

	db, err := sql.Open(driverName, dataSourceName)

	if err != nil {
		panic(err)
		return err
	}

	sc.db = db

	return nil
}

func (sc *SQLContextType) JOpen(dataSourceName string) error {

	conn, err := sc.jdriver.Open(dataSourceName)

	if err != nil {
		panic(err)
		return err
	}

	sc.jconn = conn

	return nil
}

func (sc *SQLContextType) Close() error {

	sc.db.Close()
	return nil
}

func (sc *SQLContextType) Prepare(query string) (*sql.Stmt, error) {

	stmt, err := sc.db.Prepare(query)

	if err != nil {
		panic(err)
		return nil, err
	}
	sc.stmt = stmt

	return stmt, nil
}

func (sc *SQLContextType) JPrepare(query string) (driver.Stmt, error) {
	stmt, err := sc.jconn.Prepare(query)

	if err != nil {
		panic(err)
		return nil, err
	}
	sc.jstmt = stmt

	return stmt, nil
}

func (sc *SQLContextType) Exec(args ...interface{}) (sql.Result, error) {

	res, err := sc.stmt.Exec(args)

	if err != nil {
		panic(err)
		return nil, err
	}

	return res, nil
}

/*
func (sc *SQLContextType) JExec(args []driver.Value) (driver.Result, error) {

	res, err := sc.jstmt.Exec(args)

	if err != nil {
		panic(err)
		return nil, err
	}

	return res, nil
}
*/
func (sc *SQLContextType) Query(query string) (*sql.Rows, error) {

	rows, err := sc.db.Query(query)

	if err != nil {
		panic(err)
		return nil, err
	}

	return rows, nil
}

func (sc *SQLContextType) OptQuery(query string) (*sql.Rows, error) {

	query = optimizer.Optimizer(query)

	rows, err := sc.db.Query(query)

	if err != nil {
		panic(err)
		return nil, err
	}

	return rows, nil
}

func (sc *SQLContextType) QueryOptimizer(query string) string {
	return optimizer.Optimizer(query)
}

/* TO DO
func (sc *SQLContextType) CreateDataFrame()
*/
