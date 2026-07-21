SHELL = bash

C_SRC = $(wildcard src/*.c)
CPP_SRC = $(wildcard src/*.cpp)
S_SRC = $(wildcard src/*.S)
HS_SRC = $(wildcard src/*.hs)
RS_SRC = $(wildcard src/*.rs)
F90_SRC = $(wildcard src/*.f90)
GO_SRC = $(wildcard src/*.go)

C_OBJ = $(patsubst src/%.c,obj/%.c.o,$(C_SRC))
CPP_OBJ = $(patsubst src/%.cpp,obj/%.cpp.o,$(CPP_SRC))
S_OBJ = $(patsubst src/%.S,obj/%.S.o,$(S_SRC))
HS_OBJ = $(patsubst src/%.hs,obj/%.hs.o,$(HS_SRC))
F90_OBJ = $(patsubst src/%.f90,obj/%.f90.o,$(F90_SRC))

RS_LIB = $(patsubst src/%.rs,obj/%.rs.a,$(RS_SRC))
GO_LIB = $(patsubst src/%.go,obj/%.go.a,$(GO_SRC))

OBJ = $(C_OBJ) $(CPP_OBJ) $(S_OBJ) $(HS_OBJ) $(F90_OBJ)
LIB = $(RS_LIB) $(GO_LIB)

EXE = a.out

$(EXE): $(OBJ) $(LIB)
	ghc $(OBJ) -o $(EXE) -lstdc++ -no-pie -no-hs-main -lgfortran $(LIB)

obj/%.c.o: src/%.c
	mkdir -p $(shell dirname $@)
	ghc -c $< -o $@

obj/%.cpp.o: src/%.cpp
	ghc -c $< -o $@

obj/%.S.o: src/%.S
	nasm $< -felf64 -o $@

obj/%.hs.o: src/%.hs
	ghc -c $< -o $@ -hidir obj -stubdir obj

obj/%.rs.a: src/%.rs
	rustc --crate-type=staticlib -C panic=abort $< -o $@

obj/%.f90.o: src/%.f90
	gfortran -c $< -o $@

obj/%.go.a: src/%.go
	go build -buildmode=c-archive -o $@ $<

.PHONY: clean
clean:
	rm -f $(OBJ) $(LIB) a.out

.PHONY: re
re: clean a.out
