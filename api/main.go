package main

import (
	"log"
	"net/http"
	"projeto-cloud/api/handlers"

	"github.com/gorilla/mux"
	"github.com/rs/cors"
)

func main() {
	log.Println("Starting the service...")
	r := mux.NewRouter()
	r.HandleFunc("/grocery", handlers.Create).Methods("POST")
	r.HandleFunc("/grocery/{id}", handlers.Get).Methods("GET")
	r.HandleFunc("/groceries", handlers.GetAll).Methods("GET")
	r.HandleFunc("/grocery/{id}", handlers.Update).Methods("PUT")
	r.HandleFunc("/grocery/{id}", handlers.Delete).Methods("DELETE")

	// Configure CORS middleware
	corsHandler := cors.New(cors.Options{
		AllowedOrigins: []string{"*"}, // You may want to restrict this to specific origins in a production environment
		AllowedMethods: []string{"GET", "POST", "PUT", "DELETE"},
		AllowedHeaders: []string{"Content-Type", "Authorization"},
	})

	// Apply CORS middleware to your router
	handler := corsHandler.Handler(r)

	// Additional: Handle OPTIONS requests for preflight checks
	http.Handle("/", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}
		handler.ServeHTTP(w, r)
	}))

	http.ListenAndServe(":8000", handler)
}
