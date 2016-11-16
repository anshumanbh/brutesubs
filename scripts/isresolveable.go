//Quick dirtry script to use Go's inbuilt net.Lookup to resolve domains
//If it resolves, it returns the domain
//If it cant resolve, it just returns an empty string

package main

import (
	"bufio"
	"fmt"
	"log"
	"net"
	"os"
	"time"
)

func main() {

	filepath := os.Args[1]

	f, err := os.Open(filepath)

	if err != nil {
		log.Fatalln(err)
	}

	defer f.Close()

	scanner := bufio.NewScanner(f)

	for scanner.Scan() {
		domain := scanner.Text()

		fmt.Println(isresolveable(domain))

	}

}

func isresolveable(domain string) string {
	ch := make(chan string, 1)
	go func() {
		select {
		case ch <- check(domain):
		case <-time.After(2 * time.Second):
			ch <- "timedout"
		}
	}()
	return <-ch
}

func check(domain string) string {

	if _, err := net.LookupIP(domain); err != nil {
		return ""
	}

	return domain
}
