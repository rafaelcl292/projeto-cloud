package models

import (
	"log"
	"projeto-cloud/api/db"
)

func GetGrocery(id int64) (grocery Grocery, err error) {
	conn, err := db.OpenConnection()
	if err != nil {
		log.Printf("Error opening connection: %v", err)
		return Grocery{}, err
	}
	defer conn.Close()

	sql := "SELECT id, name, price, quantity FROM groceries WHERE id = $1"
	err = conn.QueryRow(sql, id).Scan(&grocery.ID, &grocery.Name, &grocery.Price, &grocery.Quantity)
	if err != nil {
		log.Printf("Error querying row: %v", err)
		return Grocery{}, err
	}
	return grocery, nil
}

func GetAllGroceries() (groceries []Grocery, err error) {
	conn, err := db.OpenConnection()
	if err != nil {
		log.Printf("Error opening connection: %v", err)
		return []Grocery{}, err
	}
	defer conn.Close()

	sql := "SELECT id, name, price, quantity FROM groceries"
	rows, err := conn.Query(sql)
	if err != nil {
		log.Printf("Error querying rows: %v", err)
		return []Grocery{}, err
	}
	defer rows.Close()

	for rows.Next() {
		var grocery Grocery
		err = rows.Scan(&grocery.ID, &grocery.Name, &grocery.Price, &grocery.Quantity)
		if err != nil {
			log.Printf("Error scanning row: %v", err)
			return nil, err
		}
		groceries = append(groceries, grocery)
	}
	return groceries, nil
}
