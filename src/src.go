package main

import "C"
import "fmt"

// vvvvv DON'T TOUCH THIS COMMENT ! It actually exports the function, it's not just a comment !
//export go_hello
func go_hello() {
	fmt.Println("Hello, world from Go !");
}

func main() {}
