package main

import (
	"bufio"
	"fmt"
	"os"

	"github.com/sirupsen/logrus"
)

const codes = "codes.txt"
const digits = "0123456789"

var m = map[string]int{
	// "0": 0,
	// "1": 1,
	// "2": 2,
	// "3": 3,
	// "4": 4,
	// "5": 5,
	// "6": 6,
	// "7": 7,
	// "8": 8,
	// "9": 9,
	"one":   1,
	"two":   2,
	"three": 3,
	"four":  4,
	"five":  5,
	"six":   6,
	"seven": 7,
	"eight": 8,
	"nine":  9,
}

var log = logrus.StandardLogger()

func scanLine(s string) int {
	// fmt.Println(s)
	l := len(s)
	var d1, d2 int
L1:
	for i := 0; i < l; i++ {
		if s[i] >= '0' && s[i] <= '9' {
			d1 = int(s[i] - '0')
			break
		}
		for word, n := range m {
			max := i + len(word)
			if max > l {
				max = l
			}
			if s[i:max] == word {
				d1 = n
				break L1
			}
		}
	}

L2:
	for i := l - 1; i >= 0; i-- {
		if s[i] >= '0' && s[i] <= '9' {
			d2 = int(s[i] - '0')
			break
		}
		for word, n := range m {
			max := i + len(word)
			if max > l {
				max = l
			}
			// fmt.Println(i, max, word)
			if s[i:max] == word {
				d2 = n
				break L2
			}
		}
	}

	return d1*10 + d2
}

func main() {
	f, err := os.Open(codes)
	if err != nil {
		log.Fatal("error opening input file", err)
		return
	}

	scanner := bufio.NewScanner(f)

	count := 0
	sum := 0
	for scanner.Scan() {
		num := scanLine(scanner.Text()) //
		// fmt.Println(num)
		sum += num
		count++
		if count >= 10_000 {
			break
		}
	}

	fmt.Println(sum)
}
