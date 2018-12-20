package main

/*
#cgo LDFLAGS: -L. -lodbc
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sql.h>
#include <sqlext.h>

#include "util.c"

#define COL_LEN 20
#define DATA_ARRAY_SIZE 12
#define TRUE 1
#define FALSE 0

SQLLEN NumInserts = 0;
SQLLEN BindOffset = 0;
SQLLEN RowsFetched = 0;
SQLRETURN retcode;
SQLHENV  henv  = SQL_NULL_HENV;
SQLHDBC  hdbc  = SQL_NULL_HDBC;
SQLHSTMT hstmt = SQL_NULL_HSTMT;
char select_query[] = "SELECT * FROM ";

void executor(int rows, int cols, char* tablename, char** dataframe){

	int i, p;

	SQLCHAR table_array[rows][cols][COL_LEN];
	SQLLEN tv_ptr = COL_LEN;

	retcode = SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &henv);
	CHECK_ERROR(retcode, "SQLAllocHandle(ENV)",
	henv, SQL_HANDLE_ENV);

	retcode = SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION,
	(SQLPOINTER*)SQL_OV_ODBC3, 0);
	CHECK_ERROR(retcode, "SQLSetEnvAttr(SQL_ATTR_ODBC_VERSION)",
	henv, SQL_HANDLE_ENV);

	retcode = SQLAllocHandle(SQL_HANDLE_DBC, henv, &hdbc);
	CHECK_ERROR(retcode, "SQLAllocHandle(DBC)",
	henv, SQL_HANDLE_ENV);

	retcode = SQLSetConnectAttr(hdbc, SQL_LOGIN_TIMEOUT, (SQLPOINTER)5, 0);
	CHECK_ERROR(retcode, "SQLSetConnectAttr(SQL_LOGIN_TIMEOUT)",
	hdbc, SQL_HANDLE_DBC);

	retcode = SQLConnect(hdbc, (SQLCHAR*) "Ketiodbc", SQL_NTS,
	(SQLCHAR*) NULL, 0, NULL, 0);
	CHECK_ERROR(retcode, "SQLConnect(SQL_HANDLE_DBC)",
	hdbc, SQL_HANDLE_DBC);

	retcode = SQLSetConnectAttr(hdbc, SQL_ATTR_AUTOCOMMIT,
	(SQLPOINTER)TRUE, 0);
	CHECK_ERROR(retcode, "SQLSetConnectAttr(SQL_ATTR_AUTOCOMMIT)",
	hdbc, SQL_HANDLE_DBC);

	retcode = SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);
	CHECK_ERROR(retcode, "SQLAllocHandle(SQL_HANDLE_STMT)",
	hstmt, SQL_HANDLE_STMT);

	retcode = SQLSetStmtAttr(hstmt, SQL_ATTR_CURSOR_TYPE,
	(SQLPOINTER)SQL_CURSOR_KEYSET_DRIVEN, 0);
	retcode = SQLSetStmtAttr(hstmt, SQL_ATTR_ROW_BIND_TYPE,
	(SQLPOINTER)sizeof(table_array[0]), 0);
	retcode = SQLSetStmtAttr(hstmt, SQL_ATTR_ROW_ARRAY_SIZE,
	(SQLPOINTER)3, 0);
	retcode = SQLSetStmtAttr(hstmt, SQL_ATTR_ROW_BIND_OFFSET_PTR,
	&BindOffset, 0);
	retcode = SQLSetStmtAttr(hstmt, SQL_ATTR_ROWS_FETCHED_PTR,
	&RowsFetched,0);
	retcode = SQLSetStmtAttr(hstmt, SQL_ATTR_CONCURRENCY,
	(SQLPOINTER)SQL_CONCUR_LOCK ,0);

	for ( i = 0; i<cols; i++){
		retcode = SQLBindCol(hstmt, i+1, SQL_C_CHAR,table_array[0][i],sizeof(table_array[0][i]),&tv_ptr);
		for ( p = 0; p <rows; p++){
			printf("%s\n",dataframe[12]);
			strcpy(table_array[p][i],dataframe[(i*3) + p + i]);
	//		printf("%s\n",table_array[p][i]);
		}
		printf("=========\n");

	}

	strcat(select_query, tablename);
	retcode = SQLExecDirect(hstmt,(SQLCHAR*)select_query, SQL_NTS);
	CHECK_ERROR(retcode, "SQLExecDirect()", hstmt, SQL_HANDLE_STMT);

	NumInserts = rows;
	SQLSetStmtAttr (hstmt, SQL_ATTR_ROW_ARRAY_SIZE, (SQLPOINTER)NumInserts , 0);
	BindOffset = 0;
	SQLBulkOperations(hstmt, SQL_ADD);
	SQLCloseCursor(hstmt);

exit:

	printf ("\nComplete.\n");

	if (hstmt != SQL_NULL_HSTMT)
	SQLFreeHandle(SQL_HANDLE_STMT, hstmt);

	if (hdbc != SQL_NULL_HDBC) {
		SQLDisconnect(hdbc);
		SQLFreeHandle(SQL_HANDLE_DBC, hdbc);
	}

	if (henv != SQL_NULL_HENV)
	SQLFreeHandle(SQL_HANDLE_ENV, henv);

	return;

}
*/
import "C"

import (
	_ "fmt"
	_ "reflect"
	"strconv"
	_ "unsafe"
)

func main() {

	tableArray := make([][]*C.char, 6)

	for i := range tableArray {
		tableArray[i] = make([]*C.char, 10)
	}

	for i := 0; i < 6; i++ {
		for w := 0; w < 10; w++ {
			tableArray[i][w] = C.CString(strconv.Itoa(i) + strconv.Itoa(w) + "KTL")
		}
	}

	//o := C.CString("KLL")
	//*(k) = &o
	//	fmt.Println(reflect.TypeOf(k[0]))
	//*k = o
	//	k[1] = *C.CString("LL")
	//	k = &tableArray
	//k[1][1] = C.CString("PKL")

	/*for b := range k {
		fmt.Print(b)
	}*/

	C.executor(6, 10, C.CString("employees"), &tableArray[0][0])

}
