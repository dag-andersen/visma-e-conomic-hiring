package main

import (
	"log"
	"math/rand"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	requestReceived = promauto.NewCounter(prometheus.CounterOpts{
		Name: "dummy_requests_total",
		Help: "The total number of requests",
	})
	pdfServed = promauto.NewCounter(prometheus.CounterOpts{
		Name: "dummy_requests_pdf_served_total",
		Help: "The total number of requests",
	})
	pngServed = promauto.NewCounter(prometheus.CounterOpts{
		Name: "dummy_requests_png_served_total",
		Help: "The total number of requests",
	})
)

func serveRandomFile(w http.ResponseWriter, r *http.Request) {
	id := strings.TrimPrefix(r.URL.Path, "/")

	requestReceived.Inc()

	log.Printf("Request for id: %s", id)
	log.Printf("DEMO TIME")

	// parse id as int
	idInt, err := strconv.Atoi(id)
	if err != nil {
		log.Printf("Error parsing id: %s", id)
		log.Printf("Serving random file")
		idInt = rand.Intn(10)
	}

	if idInt%2 == 0 {
		pdfServed.Inc()
		log.Printf("Serving PDF")
		http.ServeFile(w, r, "./dummy.pdf")
		return
	} else {
		pngServed.Inc()
		log.Printf("Serving PNG")
		http.ServeFile(w, r, "./dummy.png")
		return
	}
}

func serveHealthCheck(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}

func main() {
	log.Println("Starting dummy-pdf-or-png server")
	rand.Seed(time.Now().UnixNano())
	http.HandleFunc("/health", serveHealthCheck)
	http.HandleFunc("/", serveRandomFile)
	http.Handle("/metrics", promhttp.Handler())

	err := http.ListenAndServe(":3000", nil)
	if err != nil {
		log.Fatal(err)
	}
}
