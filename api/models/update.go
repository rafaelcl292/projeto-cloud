package models

import (
	"log"
	"projeto-cloud/api/db"
)

func UpdateGrocery(grocery Grocery) (err error) {
	conn, err := db.OpenConnection()
	if err != nil {
		log.Printf("Error opening connection: %v", err)
		return err
	}
	defer conn.Close()

	sql := "UPDATE groceries SET name = $1, price = $2, quantity = $3 WHERE id = $4"
	_, err = conn.Exec(sql, grocery.Name, grocery.Price, grocery.Quantity, grocery.ID)
	return err
}
