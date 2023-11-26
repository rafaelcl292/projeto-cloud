package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"projeto-cloud/api/models"
)

func Create(w http.ResponseWriter, r *http.Request) {
	log.Println("Creating a new grocery...")

	// Get the JSON body and decode into grocery
	var grocery models.Grocery
	err := json.NewDecoder(r.Body).Decode(&grocery)
	if err != nil {
		log.Printf("Error decoding JSON body: %v", err)
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	// Insert grocery
	id, err := models.InsertGrocery(grocery)
	if err != nil {
		log.Printf("Error inserting grocery: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	// Update the grocery object with the generated ID
	grocery.ID = id

	// Return the updated grocery (including the ID)
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(grocery)
}
