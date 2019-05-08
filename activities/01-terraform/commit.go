package main

import (
	"flag"
	"log"
	"os"

	"github.com/PaloAltoNetworks/pango"
)

func main() {
	var (
		hostname, username, password, apikey, comment string
		ok                                            bool
		err                                           error
		job                                           uint
	)

	log.SetFlags(log.Ldate | log.Ltime | log.Lmicroseconds)

	if hostname, ok = os.LookupEnv("PANOS_HOSTNAME"); !ok {
		log.Fatalf("PANOS_HOSTNAME must be set")
	}
	apikey = os.Getenv("PANOS_API_KEY")
	if username, ok = os.LookupEnv("PANOS_USERNAME"); !ok && apikey == "" {
		log.Fatalf("PANOS_USERNAME must be set if PANOS_API_KEY is unset")
	}
	if password, ok = os.LookupEnv("PANOS_PASSWORD"); !ok && apikey == "" {
		log.Fatalf("PANOS_PASSWORD must be set if PANOS_API_KEY is unset")
	}

	flag.StringVar(&comment, "c", "", "Commit comment")
	flag.Parse()

	fw := &pango.Firewall{Client: pango.Client{
		Hostname: hostname,
		Username: username,
		Password: password,
		ApiKey:   apikey,
		Logging:  pango.LogOp | pango.LogAction,
	}}
	if err = fw.Initialize(); err != nil {
		log.Fatalf("Failed: %s", err)
	}

	job, err = fw.Commit(comment, true, true, false, true)
	if err != nil {
		log.Fatalf("Error in commit: %s", err)
	} else if job == 0 {
		log.Printf("No commit needed")
	} else {
		log.Printf("Committed config successfully")
	}
}
