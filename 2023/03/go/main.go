package main

import (
	"fmt"
	"strings"

	"github.com/sirupsen/logrus"
)

const engine = "engine.txt"
const symbols = "*-#%=$@/+&"

var gamesSum int

var log = logrus.StandardLogger()

var m = []string{}

func hasAdjacentSymbol(lineN, pos1, pos2 int) bool {
	startPos := pos1
	if pos1 > 0 {
		startPos--
	}
	endPos := pos2
	if endPos < len(m[lineN])-1 {
		endPos++
	}
	if lineN > 0 {
		if strings.IndexAny(m[lineN-1][startPos:endPos+1], symbols) != -1 {
			return true
		}
	}
	if lineN < len(m)-1 {
		if strings.IndexAny(m[lineN+1][startPos:endPos+1], symbols) != -1 {
			return true
		}
	}
	if pos1 > 0 {
		if strings.Index(symbols, string(m[lineN][pos1-1])) != -1 {
			return true
		}
	}
	if pos2 < len(m[lineN])-1 {
		if strings.Index(symbols, string(m[lineN][pos2+1])) != -1 {
			return true
		}
	}
	return false
}

func scanLine(s string) {
	m = append(m, s)
}

func findNumbers(lineN int, s string) int {
	// scan line for sequences of digits, check for adjacency to symbols
	fmt.Printf("checking %d: %s\n", lineN, s)
	result := 0
	numbers := extractNumbers(s)
	for _, seq := range numbers {
		if hasAdjacentSymbol(lineN, seq.start, seq.end-1) {
			fmt.Printf("number %d has adjacent, adding\n", seq.n)
			result += seq.n
		}
	}

	// digitStart := -1
	// currentNum := 0
	// for i, c := range s {
	// 	if strings.IndexRune(digits, c) != -1 {
	// 		if digitStart == -1 {
	// 			digitStart = i
	// 			currentNum = atoi(string(c))
	// 			fmt.Printf("begin number %d\n", currentNum)
	// 		} else {
	// 			currentNum = currentNum*10 + atoi(string(c))
	// 			fmt.Printf("continue number %d\n", currentNum)
	// 		}
	// 	} else {
	// 		if digitStart != -1 {
	// 			if hasAdjacentSymbol(lineN, digitStart, i-1) {
	// 				fmt.Printf("finished number %d, has adjacent, adding %s\n", currentNum, s[digitStart:i])
	// 				result += atoi(s[digitStart:i])
	// 			} else {
	// 				fmt.Printf("finished number %d, no adjacent\n", currentNum)
	// 			}
	// 			currentNum = 0
	// 			digitStart = -1
	// 		}
	// 	}
	// }
	// if digitStart != -1 {
	// 	if hasAdjacentSymbol(lineN, digitStart, len(s)-1) {
	// 		fmt.Printf("leftover number %d, has adjacent, adding %s\n", currentNum, s[digitStart:])
	// 		result += atoi(s[digitStart:])
	// 	} else {
	// 		fmt.Printf("leftover number %d, no adjacent\n", currentNum)
	// 	}
	// }
	return result
}

func findGears(lineN int) int {
	slice := m[lineN]
	result := 0
	pos := strings.IndexRune(slice, '*')
	if pos == -1 {
		return 0
	}
	numbers := []sequence{} // numbers from 3 adjacent lines
	if lineN > 0 {
		numbers = append(numbers, extractNumbers(m[lineN-1])...)
	}
	numbers = append(numbers, extractNumbers(m[lineN])...)
	if lineN < len(m)-1 {
		numbers = append(numbers, extractNumbers(m[lineN+1])...)
	}

	fmt.Printf("checking %d: %s -> %v\n", lineN, m[lineN], numbers)
	offset := 0
	for {
		offset += pos
		gearNumbers := []sequence{}
		for _, seq := range numbers {
			if seq.end == offset || seq.start == offset+1 || (seq.start <= offset && seq.end >= offset) {
				gearNumbers = append(gearNumbers, seq)
			}
		}
		fmt.Printf("checking pos %d -> %v\n", offset, gearNumbers)
		if len(gearNumbers) == 2 {
			fmt.Printf("using %d * %d = %d\n", gearNumbers[0].n, gearNumbers[1].n, gearNumbers[0].n*gearNumbers[1].n)
			result += gearNumbers[0].n * gearNumbers[1].n
		}

		slice = slice[pos+1:]
		offset++
		pos = strings.IndexRune(slice, '*')
		if pos == -1 {
			break
		}
	}
	fmt.Printf("result of %s -> %d\n", m[lineN], result)
	return result
}

func main() {

	scanFile(engine, 1000, scanLine)

	for i := range m {
		gamesSum += findGears(i)
	}

	fmt.Println(gamesSum)
}
