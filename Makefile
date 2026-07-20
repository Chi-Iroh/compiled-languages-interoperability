SHELL = bash

SRC := $(wildcard src/*)
OBJ := $(foreach src,$(SRC),$(patsubst src/%,obj/%,$(src)).o)
EXE = a.out

$(EXE): $(OBJ)
	gcc $(OBJ) -o $(EXE) -lstdc++ -no-pie

obj/%.c.o: src/%.c
	mkdir -p $(shell dirname $@)
	gcc -c $< -o $@

obj/%.cpp.o: src/%.cpp
	g++ -c $< -o $@

obj/%.S.o: src/%.S
	nasm $< -felf64 -o $@

.PHONY: clean
clean:
	rm -f $(OBJ) a.out

.PHONY: re
re: clean a.out
