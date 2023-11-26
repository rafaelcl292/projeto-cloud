package db

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
)

func getEnv(key string) string {
	value := os.Getenv(key)
	if value == "" {
		log.Fatalf("Error: %s environment variable not set", key)
	}
	return value
}

func OpenConnection() (*sql.DB, error) {
	dbUser := getEnv("DB_USER")
	dbPassword := getEnv("DB_PASSWORD")
	dbName := getEnv("DB_NAME")
	dbPort := getEnv("DB_PORT")
	dbHost := getEnv("DB_HOST")

	sc := fmt.Sprintf(
		"user=%s password=%s dbname=%s port=%s host=%s",
		dbUser, dbPassword, dbName, dbPort, dbHost,
	)

	conn, err := sql.Open("postgres", sc)
	if err != nil {
		log.Fatalf("Error opening database connection: %v", err)
		return nil, err
	}

	err = conn.Ping()
	if err != nil {
		log.Fatalf("Error pinging database: %v", err)
		return nil, err
	}

	log.Println("Database connection established successfully")

	// Create table if it doesn't exist
	err = createTableIfNotExists(conn)
	if err != nil {
		log.Fatalf("Error creating table: %v", err)
		return nil, err
	}

	return conn, nil
}

func createTableIfNotExists(db *sql.DB) error {
	// Define your table creation query here
	query := `
	CREATE TABLE IF NOT EXISTS groceries (
		id SERIAL PRIMARY KEY,
		name VARCHAR(255) NOT NULL,
        price NUMERIC NOT NULL,
		quantity INT NOT NULL
	);
	`

	_, err := db.Exec(query)
	if err != nil {
		return err
	}

	return nil
}
