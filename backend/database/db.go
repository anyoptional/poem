package database

import (
	"backend/misc"
	"database/sql"
	"fmt"
	"log"

	_ "github.com/go-sql-driver/mysql"
)

var DB *sql.DB

func InitDB() error {
	dbUser := misc.Getenv("DB_USER")
	dbPassword := misc.Getenv("DB_PASSWORD")
	dbHost := misc.Getenv("DB_HOST")
	dbPort := misc.Getenv("DB_PORT")
	dbName := misc.Getenv("DB_NAME")

	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		dbUser, dbPassword, dbHost, dbPort, dbName)

	var err error
	DB, err = sql.Open("mysql", dsn)
	if err != nil {
		return fmt.Errorf("failed to open database: %v", err)
	}

	if err = DB.Ping(); err != nil {
		return fmt.Errorf("failed to ping database: %v", err)
	}

	DB.SetMaxOpenConns(25)
	DB.SetMaxIdleConns(5)
	DB.SetConnMaxLifetime(5 * 60)

	log.Println("Database connection established successfully")
	return nil
}

func CloseDB() {
	if DB != nil {
		_ = DB.Close()
		log.Println("Database connection closed")
	}
}
