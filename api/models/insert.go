package models

import (
	"log"
	"projeto-cloud/api/db"
)

func InsertGrocery(grocery Grocery) (id int64, err error) {
	conn, err := db.OpenConnection()
	if err != nil {
		log.Printf("Error opening connection: %v", err)
		return 0, err
	}
	defer conn.Close()

	sql := "INSERT INTO groceries (name, price, quantity) VALUES ($1, $2, $3) RETURNING id"
	err = conn.QueryRow(sql, grocery.Name, grocery.Price, grocery.Quantity).Scan(&id)
	if err != nil {
		return 0, err
	}
	return id, nil
}
