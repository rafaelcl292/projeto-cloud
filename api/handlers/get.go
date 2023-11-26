package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"projeto-cloud/api/models"
	"strconv"

	"github.com/gorilla/mux"
)

func Get(w http.ResponseWriter, r *http.Request) {
	log.Println("Getting a grocery...")

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

	// Get grocery
	grocery, err := models.GetGrocery(groceryID)
	if err != nil {
		log.Printf("Error getting grocery: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	// Return the grocery
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(grocery)
}

func GetAll(w http.ResponseWriter, r *http.Request) {
	log.Println("Getting all groceries...")

	// Get all groceries
	groceries, err := models.GetAllGroceries()
	if err != nil {
		log.Printf("Error getting all groceries: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	// Return the grocery list
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(groceries)
}
