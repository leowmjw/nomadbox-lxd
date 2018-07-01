package main

import (
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/leowmjw/nomadbox-lxd/helper"
)

var runningCount int

func main() {

	helper.HelloWorld()

	myport := os.Getenv("NOMAD_PORT_http")
	if myport == "" {
		myport = "8989"
	}
	httpServer := &http.Server{
		Addr:         ":" + myport,
		Handler:      http.HandlerFunc(StaticServer),
		ReadTimeout:  60 * time.Second,
		WriteTimeout: 30 * time.Second,
	}

	err := httpServer.ListenAndServe()
	if err != nil {
		fmt.Println(err)
	}
}

// StaticServer does waht??
func StaticServer(w http.ResponseWriter, req *http.Request) {
	defer req.Body.Close()
	fmt.Println(req.RemoteAddr)
	localIP := req.Context().Value(http.LocalAddrContextKey)
	fmt.Println("LOCALIP: ", localIP)
	// Net/http needs to require LocalAddr IP
	io.WriteString(w, fmt.Sprintf("HOST: IP: %s", localIP))
	return
}

// From: https://github.com/tomasen/realip/blob/master/realip.go
// FromRequest return client's real public IP address from http request headers.
func decodeIPFromReq(r *http.Request) string {
	// Fetch header value
	xRealIP := r.Header.Get("X-Real-Ip")
	xForwardedFor := r.Header.Get("X-Forwarded-For")

	var remoteIP string
	// If both empty, return IP from remote address
	if xRealIP == "" && xForwardedFor == "" {
		fmt.Println("EMPTY: ", r.RemoteAddr)
		// If there are colon in remote address, remove the port number
		// otherwise, return remote address as is
		if strings.ContainsRune(r.RemoteAddr, ':') {
			remoteIP, _, _ = net.SplitHostPort(r.RemoteAddr)
		} else {
			remoteIP = r.RemoteAddr
		}

		return remoteIP
	}

	// Check list of IP in X-Forwarded-For and return the first global address
	for _, address := range strings.Split(xForwardedFor, ",") {
		address = strings.TrimSpace(address)
		fmt.Println("FORWARD: ", address)
		if strings.ContainsRune(address, ':') {
			remoteIP, _, _ = net.SplitHostPort(address)
		}
		return address
	}

	// If nothing succeed, return X-Real-IP
	return xRealIP
}
