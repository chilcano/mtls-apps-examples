// server/server.go

package main

import (
    "fmt"
    "log"
    "net/http"
)

func main() {
    // set up handler to listen to root path
    handler := http.NewServeMux()
    handler.HandleFunc("/hello", func(writer http.ResponseWriter, request *http.Request) {
        log.Println(" -> new request")
        fmt.Fprintf(writer, "Hello World!! \n")
    })

    // serve on port 9090 of local host
    server := http.Server{
        Addr:    ":9091",
        Handler: handler,
    }

    if err := server.ListenAndServe(); err != nil {
        log.Fatalf("error listening to port: %v", err)
    }
}
