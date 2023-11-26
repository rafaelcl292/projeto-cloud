package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"projeto-cloud/api/models"
	"strconv"

	"github.com/gorilla/mux"
)

func Update(w http.ResponseWriter, r *http.Request) {
	log.Println("Updating a grocery...")

	// Retrieve the ID from the URL path parameters
	vars := mux.Vars(r)
	id, ok := vars["id"]
	if !ok {
		log.Printf("Error: Missing ID parameter in the URL")
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	// Convert the ID to the appropriate type (e.g., int64)
	groceryID, err := strconv.ParseInt(id, 10, 64)
	if err != nil {
		log.Printf("Error converting ID to int64: %v", err)
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	// Get the JSON body and decode into grocery
	var updatedGrocery models.Grocery
	err = json.NewDecoder(r.Body).Decode(&updatedGrocery)
	if err != nil {
		log.Printf("Error decoding JSON body: %v", err)
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	// Update grocery with the retrieved ID
	updatedGrocery.ID = groceryID
	err = models.UpdateGrocery(updatedGrocery)
	if err != nil {
		log.Printf("Error updating grocery: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	// Return the updated grocery (including the ID)
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(updatedGrocery)
}
