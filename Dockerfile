FROM fedora

RUN ["dnf", "install", "-y", "make", "dotnet-sdk-10.0", "gfortran", "gnat", "gcobol", "rust", "go", "ghc"]
WORKDIR /
COPY . .
RUN ["make"]
CMD ["./a.out"]
