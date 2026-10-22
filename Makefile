SHELL = bash

C_SRC = $(wildcard src/*.c)
CPP_SRC = $(wildcard src/*.cpp)
S_SRC = $(wildcard src/*.S)
HS_SRC = $(wildcard src/*.hs)
RS_SRC = $(wildcard src/*.rs)
F90_SRC = $(wildcard src/*.f90)
GO_SRC = $(wildcard src/*.go)
ADA_SRC = $(wildcard src/*.adb)
CS_SRC = $(wildcard src/*.cs)
CBL_SRC = $(wildcard src/*.cbl)
D_SRC = $(wildcard src/*.d)
ZIG_SRC = $(wildcard src/*.zig)
HOLY_C_SRC = $(wildcard src/*.hc)
PAS_SRC = $(wildcard src/*.pas)

C_OBJ = $(patsubst src/%.c,obj/%.c.o,$(C_SRC))
CPP_OBJ = $(patsubst src/%.cpp,obj/%.cpp.o,$(CPP_SRC))
S_OBJ = $(patsubst src/%.S,obj/%.S.o,$(S_SRC))
HS_OBJ = $(patsubst src/%.hs,obj/%.hs.o,$(HS_SRC))
F90_OBJ = $(patsubst src/%.f90,obj/%.f90.o,$(F90_SRC))
# Ada is extremely strict about .o names, they must exactly match .adb name, thus .adb.o won't work !
ADA_OBJ = $(patsubst src/%.adb,obj/%.o,$(ADA_SRC)) $(patsubst src/%.adb,obj/b~%.o,$(ADA_SRC))
CBL_OBJ = $(patsubst src/%.cbl,obj/%.cbl.o,$(CBL_SRC))
D_OBJ = $(patsubst src/%.d,obj/%.d.o,$(D_SRC))
ZIG_OBJ = $(patsubst src/%.zig,obj/%.zig.o,$(ZIG_SRC))
HOLY_C_OBJ = $(patsubst src/%.hc,obj/%.hc.o,$(HOLY_C_SRC))

RS_LIB = $(patsubst src/%.rs,obj/%.rs.a,$(RS_SRC))
GO_LIB = $(patsubst src/%.go,obj/%.go.a,$(GO_SRC))
CS_LIB = $(patsubst src/%.cs,obj/%.cs.a,$(CS_SRC))
PAS_LIB = $(patsubst src/%.pas,obj/%.pas.a,$(PAS_SRC))

OBJ = $(C_OBJ) $(CPP_OBJ) $(S_OBJ) $(HS_OBJ) $(F90_OBJ) $(ADA_OBJ) $(CBL_OBJ) $(D_OBJ) $(ZIG_OBJ) $(HOLY_C_OBJ)
LIB = $(RS_LIB) $(GO_LIB) $(CS_LIB) $(PAS_LIB)

CS_RUNTIME=10
# xargs to trim leading spaces
CS_NUGET_ROOT = $(shell dotnet nuget locals global-packages --list | cut -d: -f2 | xargs)
CS_STD_LIB_ROOT = $(shell find "$(CS_NUGET_ROOT)microsoft.netcore.app.runtime.nativeaot.linux-x64" -type d -path '*$(CS_RUNTIME).*/runtimes/linux-x64/native' | tail -n 1)
CS_STD_DEPS = libbootstrapperdll.o libRuntime.WorkstationGC.a libeventpipe-disabled.a libRuntime.VxsortDisabled.a libstandalonegc-disabled.a libSystem.Native.a libSystem.IO.Compression.Native.a libSystem.Globalization.Native.a libaotminipal.a libstdc++compat.a libz.a
CS_STD_LIB = $(foreach dep,$(CS_STD_DEPS),$(CS_STD_LIB_ROOT)/$(dep))

D_STD_LIB = -lphobos2-ldc-shared -ldruntime-ldc-shared

GHC_LDFLAGS_OUTPUT = obj/ghc_ldflags.log

DEPS_DIR = $(abspath deps)
DEPS_REPOS_DIR = $(DEPS_DIR)/repos

DEPS_BIN_DIR = $(DEPS_DIR)/bin
DEPS_LIB_DIR = $(DEPS_DIR)/lib
DEPS_INCLUDE_DIR = $(DEPS_DIR)/include

HOLY_C_COMPILER = $(DEPS_BIN_DIR)/hcc
PASCAL_COMPILER = $(DEPS_BIN_DIR)/fpc
FPC_3_2_2 = $(DEPS_DIR)/fpc-3.2.2/bin/fpc

COMPILERS = $(HOLY_C_COMPILER) $(PASCAL_COMPILER)

EXE = a.out

$(EXE): init-deps-dir $(COMPILERS) check-cs-nativeaot $(OBJ) $(LIB)
	gcc $(OBJ) -o $(EXE) -lstdc++ -no-pie -lgfortran $(LIB) -lgnat-$(shell gcc -dumpversion) -lm -lgcobol $(CS_STD_LIB) $(shell cat $(GHC_LDFLAGS_OUTPUT)) $(D_STD_LIB)

obj/%.c.o: src/%.c
	mkdir -p $(shell dirname $@)
	ghc -c $< -o $@

obj/%.cpp.o: src/%.cpp
	ghc -c $< -o $@

obj/%.S.o: src/%.S
	nasm $< -felf64 -o $@

obj/%.hs.o: src/%.hs
	ghc -c $< -o $@ -hidir obj -stubdir obj
	GHC_LDFLAGS_OUTPUT=$(GHC_LDFLAGS_OUTPUT) ghc $@ -o dummy.out -no-hs-main -no-pie -pgml ./scripts/get_ghc_ldflags.py

obj/%.rs.a: src/%.rs
	rustc --crate-type=staticlib -C panic=abort $< -o $@

obj/%.f90.o: src/%.f90
	gfortran -c $< -o $@

obj/%.go.a: src/%.go
	go build -buildmode=c-archive -o $@ $<

obj/%.o: src/%.adb
	gcc -c $< -o $@

obj/b~%.o: src/%.adb
	bash -c $$' \
	if which gnat; then\n \
		gnat=gnat\n \
	elif which gnat-$$(gcc -dumpversion); then\n \
		gnat=gnat-$$(gcc -dumpversion)\n \
	else\n \
		echo "Cannot find gnat !" >&2\n \
		exit 1\n \
	fi\n \
	cd obj && $$gnat bind -n $(patsubst src/%.adb,%.ali,$<) -o $(patsubst src/%.adb,b~%.adb,$<)'
	gcc -c $(patsubst src/%.adb,obj/b~%.adb,$<) -o $(patsubst src/%.adb,obj/b~%.o,$<)

obj/%.cs.a: src/%.cs
	dotnet publish -p:PublishAot=true -p:OutputType=Library -p:TargetFramework=net$(CS_RUNTIME).0 -p:NativeLib=Static -r linux-x64 -p:DebugType=None -p:DebugSymbols=false -p:NativeDebugSymbols=false -p:StripSymbols=true -p:AssemblyName=$(shell basename $@ .a) $< -o $(shell dirname $@)

obj/%.cbl.o: src/%.cbl
	gcobol -c $< -o $@

obj/%.d.o: src/%.d
	ldc2 -c $< -of=$@

obj/%.zig.o: src/%.zig
	zig build-obj $< -fno-stack-check -femit-bin=$@

obj/%.hc.o: src/%.hc
	$(HOLY_C_COMPILER) $< -obj -o $@

obj/%.pas.a: src/%.pas
	PATH="$(DEPS_BIN_DIR):$(DEPS_LIB_DIR)/fpc/3.3.1:$$PATH" $(PASCAL_COMPILER) -XA $< -o$@ -Fu$(DEPS_BIN_DIR)/unleashedpascal-rtl-units

.PHONY: clean
clean:
	rm -f $(OBJ) $(LIB) $(EXE)

.PHONY: cleandeps
cleandeps:
	rm -rf $(DEPS_DIR)

.PHONY: cleanall
cleanall: cleandeps clean

.PHONY: re
re: clean $(EXE)

.PHONY:check-cs-nativeaot
check-cs-nativeaot:
	if [[ "$(CS_STD_LIB_ROOT)" = "" ]]; then \
		$(MAKE) cs-download-nativeaot; \
	fi

.PHONY: cs-download-nativeaot
cs-download-nativeaot:
	dir=$(shell mktemp -d) && \
	cd $$dir && \
	echo $$'<Project Sdk="Microsoft.NET.Sdk">\n\t<PropertyGroup>\n\t\t<TargetFramework>net$(CS_RUNTIME).0</TargetFramework>\n\t\t<RuntimeIdentifier>linux-x64</RuntimeIdentifier>\n\t\t<PublishAot>true</PublishAot>\n\t</PropertyGroup>\n</Project>' > $$(basename $$dir).csproj && \
	dotnet publish -p:PublishAot=true && \
	cd - && \
	rm $$dir -rf

.PHONY: init-deps-dir
init-deps-dir:
	for dir in "$(DEPS_BIN_DIR)" "$(DEPS_INCLUDE_DIR)" "$(DEPS_LIB_DIR)" "$(DEPS_REPOS_DIR)"; do \
		if ! [ -d "$$dir" ]; then \
			mkdir -p "$$dir"; \
		fi \
	done

$(HOLY_C_COMPILER):
	if ! [ -d "$(DEPS_REPOS_DIR)/holyc-lang" ]; then \
		git clone https://github.com/Jamesbarford/holyc-lang.git $(DEPS_REPOS_DIR)/holyc-lang; \
	else \
		cd $(DEPS_REPOS_DIR)/holyc-lang && git pull; \
	fi
	INSTALL_PREFIX=$(DEPS_DIR) $(MAKE) -C $(DEPS_REPOS_DIR)/holyc-lang
	$(MAKE) install -C $(DEPS_REPOS_DIR)/holyc-lang

$(FPC_3_2_2):
	mkdir -p $(DEPS_DIR)/fpc-3.2.2
	bash -c $$' \
		cd $(DEPS_DIR)/fpc-3.2.2\n \
		if ! [ -f fpc-3.2.2.x86_64-linux.tar ]; then\n \
			wget -t 0 http://downloads.freepascal.org/fpc/dist/3.2.2/x86_64-linux/fpc-3.2.2.x86_64-linux.tar -O fpc-3.2.2.x86_64-linux.tar\n \
		fi\n \
		if ! [ -d fpc-3.2.2.x86_64-linux ]; then\n \
			tar xf fpc-3.2.2.x86_64-linux.tar\n \
		fi\n \
		cd fpc-3.2.2.x86_64-linux\n \
		chmod +x install.sh\n \
		echo "$$(pwd)/.." | ./install.sh\n \
	'

$(PASCAL_COMPILER): $(FPC_3_2_2)
	if ! [ -d "$(DEPS_REPOS_DIR)/unleashedpascal" ]; then \
		git clone  https://github.com/unleashedpascal/compiler.git $(DEPS_REPOS_DIR)/unleashedpascal; \
	else \
		cd $(DEPS_REPOS_DIR)/unleashedpascal && git pull; \
	fi
	cd $(DEPS_REPOS_DIR)/unleashedpascal
	PATH="$(DEPS_DIR)/fpc-3.2.2/bin:$$PATH" make all -C $(DEPS_REPOS_DIR)/unleashedpascal
	mkdir -p $(DEPS_BIN_DIR)/unleashedpascal-rtl-units
	PATH="$(DEPS_DIR)/fpc-3.2.2/bin:$$PATH" make INSTALL_PREFIX=$(DEPS_DIR) INSTALL_UNITDIR=$(DEPS_BIN_DIR)/unleashedpascal-rtl-units install -C $(DEPS_REPOS_DIR)/unleashedpascal

DOCKER_DISTRIBUTIONS=archlinux fedora ubuntu

.PHONY: docker
docker:
	sudo bash -c $$' \
	for distribution in $(DOCKER_DISTRIBUTIONS); do\n \
		docker build . -f docker-images/$$distribution.docker -t compiled-languages-interoperability-$$distribution:latest || exit 1\n \
		docker run compiled-languages-interoperability-$$distribution || exit 1\n \
		echo "$$distribution image works."\n \
	done' && echo "All images are successfully built."

.PHONY: docker-clean
docker-clean:
	sudo bash -c $$' \
	for distribution in $(DOCKER_DISTRIBUTIONS); do\n \
		containers=$$(docker container ls -aq --filter ancestor=compiled-languages-interoperability-$$distribution || exit 1)\n \
		if [[ "$$containers" != "" ]]; then\n \
			docker container rm $$containers || exit 1\n \
		fi\n \
		docker image rm compiled-languages-interoperability-$$distribution || exit 1\n \
		echo "$$distribution image successfully deleted."\n \
	done' && echo "All images are successfully removed."
