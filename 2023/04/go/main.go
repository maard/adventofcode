package main

import (
	"fmt"
	"slices"
	"strings"

	"github.com/sirupsen/logrus"
)

const cards = "cards.txt"

var gamesSum int

var log = logrus.StandardLogger()

func extractNumbersFromString(s string) []int {
	s = strings.TrimSpace(s)
	result := []int{}
	for _, ns := range strings.Split(s, " ") {
		ns = strings.TrimSpace(ns)
		if ns == "" {
			continue
		}
		result = append(result, atoi(ns))
	}
	slices.Sort(result)
	return result
}

func calcCardValue(s string) int {
	// fmt.Println(s)
	parts1 := strings.Split(s, ":")
	parts2 := strings.Split(parts1[1], "|")
	winning := extractNumbersFromString(parts2[0])
	// fmt.Printf("winning: %v\n", winning)
	haves := extractNumbersFromString(parts2[1])
	// fmt.Printf("haves: %v\n", haves)
	// result := 1 // will decrease in the end
	result := 0
	var posW, posH int
	for posW < len(winning) && posH < len(haves) {
		if winning[posW] == haves[posH] {
			// result *= 2
			result++
			posW++
			posH++
		} else if winning[posW] < haves[posH] {
			posW++
		} else {
			posH++
		}
	}
	// return result >> 1
	return result
}

func scanLine(s string) {
	gamesSum += calcCardValue(s)
}

var cardCopies []int

func scanLine2(lineN int, s string) {
	lineN++
	cardCopies[lineN]++
	fmt.Printf("%d copies of card %d\n", cardCopies[lineN], lineN)
	cardValue := calcCardValue(s)
	gamesSum += cardCopies[lineN]
	for n := 1; n <= cardValue; n++ {
		fmt.Printf("++card %d * %d\n", lineN+n, cardCopies[lineN])
		cardCopies[lineN+n] += cardCopies[lineN]
	}
}

func main() {

	cardCopies = make([]int, 1000)

	scanFile(cards, 1000, scanLine2)

	fmt.Println(gamesSum)
}
