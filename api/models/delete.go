package models

import (
	"log"
	"projeto-cloud/api/db"
)

func DeleteGrocery(id int64) (err error) {
	conn, err := db.OpenConnection()
	if err != nil {
		log.Printf("Error opening connection: %v", err)
		return err
	}
	defer conn.Close()

	sql := "DELETE FROM groceries WHERE id = $1"
	_, err = conn.Exec(sql, id)
	return err
}
