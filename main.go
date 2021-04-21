package main

import (
	"crypto/subtle"
	"io"
	"log"
	"net/http"
	"os"
)

func basicAuth(handler http.HandlerFunc, username, password, realm string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user, pass, ok := r.BasicAuth()

		if !ok || subtle.ConstantTimeCompare([]byte(user), []byte(username)) != 1 || subtle.ConstantTimeCompare([]byte(pass), []byte(password)) != 1 {
			w.Header().Set("WWW-Authenticate", `Basic realm="`+realm+`"`)
			w.WriteHeader(401)
			w.Write([]byte("Unauthorised.\n"))
			return
		}

		handler(w, r)
	}
}

func echo() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		_, err := io.Copy(w, r.Body)
		if err != nil {
			w.WriteHeader(400)
			w.Write([]byte(err.Error()))
		}
	}
}

func health() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello World!\n"))
	}
}

func main() {
	h := echo()

	u := os.Getenv("BASIC_AUTH_USERNAME")
	p := os.Getenv("BASIC_AUTH_PASSWORD")
	if u != "" || p != "" {
		h = basicAuth(h, u, p, "echo-webhook")
	}

	http.Handle("/", h)
	http.Handle("/health", health())
	log.Fatal(http.ListenAndServe(":"+os.Getenv("PORT"), nil))
}
