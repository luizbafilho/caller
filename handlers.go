package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/labstack/echo/v4"
)

// Calls list of services to call
type Calls []string

func callHandler(c echo.Context) error {
	var calls Calls

	if err := c.Bind(&calls); err != nil {
		return err
	}

	if len(calls) > 0 {
		next := calls[0]

		if err := call(c, next, calls[1:]); err != nil {
			return err
		}
	}

	return c.JSON(http.StatusOK, map[string]string{"message": "success"})
}

func call(c echo.Context, url string, calls Calls) error {
	data, err := json.Marshal(calls)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(data))
	if err != nil {
		return fmt.Errorf("Error reading request. ", err)
	}

	// Set headers
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set(echo.HeaderXRequestID, c.Response().Header().Get(echo.HeaderXRequestID))

	// Set client timeout
	client := &http.Client{Timeout: time.Second * 10}

	// Send request
	resp, err := client.Do(req)
	defer resp.Body.Close()

	if err != nil {
		return fmt.Errorf("Error reading response. ", err)
	}

	return nil
}
