package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"sync"
)

const processWavFilesExecutablePath = "processWavFiles_docker.sh"

func main() {
	var wg sync.WaitGroup

	wg.Add(2)

	go runServer(&wg)
	go loadSongsToServer(&wg)

	fmt.Println("Waiting for goroutines to finish...")
	wg.Wait()
	fmt.Println("Done!")
}

func runServer(wg *sync.WaitGroup) error {
	defer wg.Wait()

	// configure the songs directory name and port
	const songsDir = "songs"
	const port = 8080

	// add a handler for the song files
	http.Handle("/", addHeaders(http.FileServer(http.Dir(songsDir))))
	fmt.Printf("Starting server on %v\n", port)
	log.Printf("Serving %s on HTTP port: %v\n", songsDir, port)

	// serve and log errors on HTTPS
	log.Fatal(http.ListenAndServeTLS(fmt.Sprintf(":%v", port), "localhost.crt", "localhost.key", nil))

	return nil
}

// addHeaders will act as middleware to give us CORS support
func addHeaders(h http.Handler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		h.ServeHTTP(w, r)
	}
}

func loadSongsToServer(wg *sync.WaitGroup) error {
	defer wg.Wait()

	// get script that processes .wav files from Ableton Live and serves them as mp3
	cmdGetSongs := &exec.Cmd{
		Path: processWavFilesExecutablePath,
		Args: []string{ processWavFilesExecutablePath, "version" },
		Stdout: os.Stdout,
		Stderr: os.Stdout,
	}

	// run script
	if err := cmdGetSongs.Run(); err != nil {
		fmt.Println("Error: ", err)
	}

	return nil
}