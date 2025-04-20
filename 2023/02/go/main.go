package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/sirupsen/logrus"
)

const cubes = "cubes.txt"

type RGB struct {
	red   int
	green int
	blue  int
}

var ourRGB = &RGB{12, 13, 14}
var gamesSum int

func fromBucket(s string) *RGB {
	pairs := strings.Split(s, ", ")
	rgb := &RGB{}
	for _, pairStr := range pairs {
		pair := strings.Split(pairStr, " ")
		n, _ := strconv.ParseInt(pair[0], 10, 64)
		switch pair[1] {
		case "red":
			rgb.red = int(n)
		case "green":
			rgb.green = int(n)
		case "blue":
			rgb.blue = int(n)
		}
	}
	return rgb
}

func (rgb *RGB) canContain(other *RGB) bool {
	return rgb.red >= other.red && rgb.green >= other.green && rgb.blue >= other.blue
}

func (rgb *RGB) maxValues(other *RGB) {
	if other.red > rgb.red {
		rgb.red = other.red
	}
	if other.green > rgb.green {
		rgb.green = other.green
	}
	if other.blue > rgb.blue {
		rgb.blue = other.blue
	}
}

func (rgb *RGB) power() int {
	return rgb.red * rgb.green * rgb.blue
}

var log = logrus.StandardLogger()

// helper
func scanFile(fname string, lineLimit int, lineFunc func(string)) {
	f, err := os.Open(fname)
	if err != nil {
		log.Fatal("error opening input file", err)
	}

	scanner := bufio.NewScanner(f)

	count := 0
	for scanner.Scan() {
		lineFunc(scanner.Text())
		count++
		if count >= lineLimit {
			break
		}
	}
}

func scanLine(s string) {
	// Game 1: 12 red, 2 green, 5 blue; 9 red, 6 green, 4 blue; 10 red, 2 green, 5 blue; 8 blue, 9 red
	s = s[5:]
	parts := strings.Split(s, ":")
	// gameN, _ := strconv.ParseInt(parts[0], 10, 64)
	buckets := strings.Split(parts[1], ";")

	rgb := &RGB{}
	for _, bucket := range buckets {
		// if !ourRGB.canContain(fromBucket(strings.TrimSpace(bucket))) {
		// 	return
		// }
		rgb.maxValues(fromBucket(strings.TrimSpace(bucket)))
	}

	// fmt.Println(gameN, " true")
	gamesSum += rgb.power()
}

func main() {

	scanFile(cubes, 1000, scanLine)

	fmt.Println(gamesSum)
}
