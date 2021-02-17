package main

import (
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
	"math/rand"
	"net/http"
	"time"
)

func main() {
	// Echo instance
	e := echo.New()

	// Add middleware to server
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	// Add routes to server
	routes(e)

	// Start server
	e.Logger.Fatal(e.Start(":1323"))
}

func routes(e *echo.Echo) {
	// Route => handler
	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "Hello, World!\n")
	})

	// Route => handler with Json application type
	e.GET("/json", func(c echo.Context) error {

		var content struct {
			Response  string    `json:"response"'`
			Timestamp time.Time `json:"timestamp"`
			Random    int       `json:"random"`
		}

		content.Response = "Sent via JSONP"
		content.Timestamp = time.Now().UTC()
		content.Random = rand.Intn(1000)

		return c.JSON(http.StatusOK, content)
	})

	// Route => handler with all routes of my golang ms
	e.GET("/routes", func(c echo.Context) error {
		return c.JSON(http.StatusOK, e.Routes())
	})
}
