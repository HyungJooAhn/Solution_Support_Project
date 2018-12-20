package sql

import (
	"database/sql"
	_ "database/sql/driver"
	_ "github.com/go-sql-driver/mysql"
	"keti/datastruct/enzyme/optimizer"
	"keti/squall/internal/log"
	_ "odbc/driver"
)

var SQLContexts []*SQLContextType

type SQLContextType struct {
	Id   int
	db   *sql.DB
	stmt *sql.Stmt
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

func (sc *SQLContextType) Close() error {

	sc.db.Close()
	return nil

}

func (sc *SQLContextType) Prepare(query string) (*sql.Stmt, error) {

	query = optimizer.Optimizer(query)
	stmt, err := sc.db.Prepare(query)

	if err != nil {
		panic(err)
		return nil, err
	}

	sc.stmt = stmt
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

func (sc *SQLContextType) Query(query string) (*sql.Rows, error) {

	query = optimizer.Optimizer(query)
	rows, err := sc.db.Query(query)

	if err != nil {
		panic(err)
		return nil, err
	}

	return rows, nil

}
