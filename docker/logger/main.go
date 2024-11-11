package main

import (
	"bufio"
	"flag"
	"fmt"
	"github.com/fsnotify/fsnotify"
	"log"
	"os"
	"path/filepath"
	"strings"
	"sync"
)

var lastLoggedFile string = ""
var fileOffsets = make(map[string]int64)
var mutex = &sync.Mutex{}

const TotalLength = 60

func formatLogHeader(filePath string) {
	if lastLoggedFile == filePath {
		return
	}
	lastLoggedFile = filePath

	if len(filePath) >= TotalLength-4 {
		filePath = "..." + filePath[len(filePath)-(TotalLength-7):]
	}

	remaining := TotalLength - len(filePath) - 4
	if remaining < 0 {
		remaining = 0
	}

	fmt.Printf("\n===== %s %s\n", filePath, strings.Repeat("=", remaining))
}

func initFileOffset(filePath string) {
	file, err := os.Open(filePath)
	if err != nil {
		log.Printf("Error opening file %s for initializing offset: %v\n", filePath, err)
		return
	}
	defer file.Close()

	offset, err := file.Seek(0, os.SEEK_END)
	if err != nil {
		log.Printf("Error seeking to end of file %s: %v\n", filePath, err)
		return
	}

	mutex.Lock()
	fileOffsets[filePath] = offset
	mutex.Unlock()
}

func tailFile(filePath string) {
	mutex.Lock()
	offset, exists := fileOffsets[filePath]
	if !exists {
		offset = 0
	}
	mutex.Unlock()

	file, err := os.Open(filePath)
	if err != nil {
		log.Printf("Error opening file %s: %v\n", filePath, err)
		return
	}
	defer file.Close()

	currentOffset, err := file.Seek(offset, os.SEEK_SET)
	if err != nil {
		log.Printf("Error seeking file %s: %v\n", filePath, err)
		return
	}

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		fmt.Println(line)
		currentOffset, _ = file.Seek(0, os.SEEK_CUR)
	}

	mutex.Lock()
	fileOffsets[filePath] = currentOffset
	mutex.Unlock()

	if err := scanner.Err(); err != nil {
		log.Printf("Error reading file %s: %v\n", filePath, err)
	}
}

func monitorLogs(logDir string) {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		log.Fatal(err)
	}
	defer watcher.Close()

	done := make(chan bool)

	go func() {
		for {
			select {
			case event, ok := <-watcher.Events:
				if !ok {
					return
				}
				if event.Op&fsnotify.Write == fsnotify.Write {
					mutex.Lock()                // Ensure mutual exclusion when modifying lastLoggedFile
					formatLogHeader(event.Name) // Print the header for the log file
					mutex.Unlock()
					tailFile(event.Name) // Read the file content
				}
			case err, ok := <-watcher.Errors:
				if !ok {
					return
				}
				log.Printf("Error: %v\n", err)
			}
		}
	}()

	err = filepath.Walk(logDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			log.Printf("Error walking directory %s: %v\n", path, err)
			return nil
		}
		if !info.IsDir() {
			initFileOffset(path)
		}
		err = watcher.Add(path)
		if err != nil {
			log.Printf("Error adding to watcher: %s, %v\n", path, err)
		}
		return nil
	})

	if err != nil {
		log.Fatal(err)
	}

	<-done
}

func main() {
	logDir := flag.String("dir", "/var/log", "Directory containing log files to monitor")
	flag.Parse()

	monitorLogs(*logDir)
}
