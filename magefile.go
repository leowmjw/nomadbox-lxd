// +build mage

package main

import (
	"fmt"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os/exec"
	"strings"

	"github.com/magefile/mage/mg" // mg contains helpful utility functions, like Deps
)

// Default target to run when none is specified
// If not set, running mage will list available targets
// var Default = Build

// A build step that requires additional params, or platform specific steps for example
func Build() error {
	mg.Deps(InstallDeps)
	fmt.Println("Building...")
	return nil
}

// A custom install step if you need your bin someplace other than go/bin
func Install() error {
	mg.Deps(Build)
	fmt.Println("Installing...")
	return nil
}

// Manage your deps, or running package managers.
func InstallDeps() error {
	fmt.Println("Installing Deps...")
	return nil
}

// Clean up after yourself
func Clean() {
	fmt.Println("Cleaning...")
	return
}

func AccessConsul() error {
	// COnsul per port ..
	rpURL, err := url.Parse("http://consul.service.consul:8500")
	if err != nil {
		fmt.Println("ERR:", err)
		return err
	}
	http.Handle("/", httputil.NewSingleHostReverseProxy(rpURL))

	http.ListenAndServe(":8500", nil)

	return nil
}

func AccessNomad() error {
	// Nomad per port ..
	nomadURL, err := url.Parse("http://nomad.service.consul:4646")
	if err != nil {
		fmt.Println("ERR_NOMAD_PROXY:", err)
		return err
	}

	http.Handle("/", httputil.NewSingleHostReverseProxy(nomadURL))
	http.ListenAndServe(":4646", nil)

	return nil

}

func SetupFabio() error {
	// Check if Fabio is there? be smart anout it?
	ip, err := getAddress()
	if err != nil {
		return err
	}
	fmt.Println("IP_ADDRESS: ", ip)
	cmd := exec.Command("go", "get", "github.com/fabiolb/fabio")
	err = cmd.Run()
	if err != nil {
		fmt.Println("ERR: ", err)
		return err
	}
	return nil
}

func SetupTraefik() error {
	// Check if Tarefik is there? be smart about it?
	ip, err := getAddress()
	if err != nil {
		return err
	}
	fmt.Println("IP_ADDRESS: ", ip)

	return nil
}

// Address gets the full xip.io address needed to demo things like Fabio / Traefik?
func Address() error {

	ip, err := getAddress()
	if err != nil {
		return err
	}
	fmt.Printf("www.%s.xip.io", ip)
	return nil
}

func getAddress() (string, error) {
	// fmt.Println("Get the full formed address ...")
	// cmd := exec.Command("./scripts/address.sh")
	cmd := exec.Command("/bin/bash", "-c", "hostname -I | cut -d' ' -f1 | grep 192 || hostname -I | cut -d' ' -f2 | grep 192")
	// rerr := cmd.Run()
	// if rerr != nil {
	// 	fmt.Println("%v", rerr)
	// 	return
	// }
	output, err := cmd.Output()
	if err != nil {
		fmt.Println("ERR: ", err)
		return "", err
	}

	// fmt.Println(output)
	t := strings.Trim(string(output), "\n")
	return t, nil
}
