package main

import (
	"log"
	"math/rand"
	"net/http"
	"strings"
	"time"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func serveRandomFile(w http.ResponseWriter, r *http.Request) {
	id := strings.TrimPrefix(r.URL.Path, "/")

	log.Printf("Request for id: %s", id)

	if id == "0" {
		http.ServeFile(w, r, "./dummy.pdf")
		return
	} else if id == "1" {
		http.ServeFile(w, r, "./dummy.png")
		return
	}

	rnd := rand.Intn(10)
	log.Printf("Random number: %d", rnd)
	if rnd < 5 {
		http.ServeFile(w, r, "./dummy.png")
		return
	}
	if rnd < 9 {
		http.ServeFile(w, r, "./dummy.pdf")
		return
	}
	http.ServeFile(w, r, "./corrupt-dummy.pdf")
}

func serveHealthCheck(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusForbidden)
}

func main() {
	rand.Seed(time.Now().UnixNano())
	http.HandleFunc("/", serveRandomFile)
	http.HandleFunc("/health", serveHealthCheck)
	http.Handle("/metrics", promhttp.Handler())

	err := http.ListenAndServe(":3000", nil)
	if err != nil {
		log.Fatal(err)
	}
}
