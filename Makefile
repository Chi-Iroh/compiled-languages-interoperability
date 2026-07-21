SHELL = bash

SRC := $(wildcard src/*)
OBJ := $(foreach src,$(SRC),$(patsubst src/%,obj/%,$(src)).o)
EXE = a.out

$(EXE): $(OBJ)
	ghc $(OBJ) -o $(EXE) -lstdc++ -no-pie -no-hs-main

obj/%.c.o: src/%.c
	mkdir -p $(shell dirname $@)
	ghc -c $< -o $@

obj/%.cpp.o: src/%.cpp
	ghc -c $< -o $@

obj/%.S.o: src/%.S
	nasm $< -felf64 -o $@

obj/%.hs.o: src/%.hs
	ghc -c $< -o $@ -hidir obj -stubdir obj

.PHONY: clean
clean:
	rm -f $(OBJ) a.out

.PHONY: re
re: clean a.out
