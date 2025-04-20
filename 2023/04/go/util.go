package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

const digits = "0123456789"

type sequence struct {
	s     string
	n     int
	start int
	end   int
}

// helpers

func atoi(s string) int {
	s = strings.TrimSpace(s)
	n, _ := strconv.ParseInt(s, 10, 64)
	return int(n)
}

func extractNumbers(s string) []sequence {
	digitStart := -1
	currentNum := 0
	result := []sequence{}
	for i, c := range s {
		if strings.IndexRune(digits, c) != -1 {
			if digitStart == -1 {
				digitStart = i
				currentNum = atoi(string(c))
				// fmt.Printf("begin number %d\n", currentNum)
			} else {
				currentNum = currentNum*10 + atoi(string(c))
				// fmt.Printf("continue number %d\n", currentNum)
			}
		} else {
			if digitStart != -1 {
				substr := s[digitStart:i]
				result = append(result, sequence{substr, atoi(substr), digitStart, i})
				currentNum = 0
				digitStart = -1
			}
		}
	}
	if digitStart != -1 {
		substr := s[digitStart:]
		result = append(result, sequence{substr, atoi(substr), digitStart, len(s)})
	}
	fmt.Printf("extractNumbers: %s -> %v\n", s, result)
	return result
}

func scanFile(fname string, lineLimit int, lineFunc func(int, string)) {
	f, err := os.Open(fname)
	if err != nil {
		log.Fatal("error opening input file", err)
	}

	scanner := bufio.NewScanner(f)

	count := 0
	for scanner.Scan() {
		lineFunc(count, scanner.Text())
		count++
		if count >= lineLimit {
			break
		}
	}
}
