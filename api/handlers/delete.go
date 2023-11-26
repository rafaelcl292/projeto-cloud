package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"projeto-cloud/api/models"
	"strconv"

	"github.com/gorilla/mux"
)

func Delete(w http.ResponseWriter, r *http.Request) {
	log.Println("Deleting a grocery...")

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

	// Delete grocery
	err = models.DeleteGrocery(groceryID)
	if err != nil {
		log.Printf("Error deleting grocery: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	// Return the deleted grocery ID
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(groceryID)
}
