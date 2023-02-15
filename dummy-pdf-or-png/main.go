package main

import (
	"log"
	"math/rand"
	"net/http"
	"strings"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	requestReceived = promauto.NewCounter(prometheus.CounterOpts{
		Name: "requests_total",
		Help: "The total number of requests",
	})
	pdfServed = promauto.NewCounter(prometheus.CounterOpts{
		Name: "requests_pdf_served_total",
		Help: "The total number of requests",
	})
	pngServed = promauto.NewCounter(prometheus.CounterOpts{
		Name: "requests_png_served_total",
		Help: "The total number of requests",
	})
	corruptServed = promauto.NewCounter(prometheus.CounterOpts{
		Name: "requests_corrupt_served_total",
		Help: "The total number of requests",
	})
)

func serveRandomFile(w http.ResponseWriter, r *http.Request) {
	id := strings.TrimPrefix(r.URL.Path, "/")

	requestReceived.Inc()

	log.Printf("Request for id: %s", id)

	if id == "0" {
		pdfServed.Inc()
		http.ServeFile(w, r, "./dummy.pdf")
		return
	} else if id == "1" {
		pngServed.Inc()
		http.ServeFile(w, r, "./dummy.png")
		return
	}

	rnd := rand.Intn(10)
	log.Printf("Random number: %d", rnd)
	if rnd < 5 {
		pngServed.Inc()
		http.ServeFile(w, r, "./dummy.png")
		return
	}
	if rnd < 9 {
		pdfServed.Inc()
		http.ServeFile(w, r, "./dummy.pdf")
		return
	}
	corruptServed.Inc()
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
