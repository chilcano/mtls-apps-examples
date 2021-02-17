// client/client.go

package main

import (
    "fmt"
    "io/ioutil"
    "log"
    "net/http"
    "time"
)

func main(){
    client := http.Client{
        Timeout: time.Minute * 3,
    }

    resp,err := client.Get("http://localhost:9090")
    if err != nil {
        log.Fatalf("error making get request: %v", err)
    }

    body,err := ioutil.ReadAll(resp.Body)
    if err != nil{
        log.Fatalf("error reading response: %v", err)
    }
    fmt.Println(string(body))
}
