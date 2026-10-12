# Why not throw a bunch of compiled languages together in the same executable ?

This PoC is an experiment to try this silly idea and see how much it works.  

The program entry point is in C (`main()` function), and it calls individual functions from multiple languages :  
- Ada: <img src="icons/Ada.png" height="30">
- Assembly (NASM) <img src="icons/NASM.png" height="30">
- C <img src="icons/C.png" height="30">
- C++ <img src="icons/C++.png" height="30">
- C# <img src="icons/C%23.png" height="30">
- COBOL (didn't find any logo)
- D <img src="icons/D.png" height="30">
- FORTRAN <img src="icons/FORTRAN.png" height="30">
- Go <img src="icons/Go.png" height="30">
- Haskell <img src="icons/Haskell.png" height="30">
- HolyC <img src="icons/HolyC.png" height="30">
- Pascal (Unleashed) <img src="icons/Pascal Unleashed.png" height="50">
- Rust <img src="icons/Rust.png" height="30">
- Zig <img src="icons/Zig.png" height="30">

<br>

For Pascal, special thanks to the people on Lazarus Pascal forum, for their help [here](https://forum.lazarus.freepascal.org/index.php/topic,74996.0.html), on a thread where I asked how to integrate Pascal in a static build.  
Many thanks as well to the [Unleashed Pascal project](https://github.com/unleashedpascal/compiler/tree/feat/staticlib) which implemented static library generation, a feature I needed for my project, which lacks in the regular Free Pascal Compiler.  

# Run

Packages to install are listed in Docker images :  
- [Arch Linux](docker-images/archlinux.docker)
- [Fedora](docker-images/fedora.docker)
- [Ubuntu](docker-images/ubuntu.docker)

Then, simply do :  
```bash
make
```

The build is tested with Docker images.  
Beware, they will take a LOT of disk space as many languages toolchains are installed.  
Here are the commands :  
```bash
# Install Docker
sudo dnf install docker

# Initialize Docker
sudo systemctl enable docker
sudo systemctl start docker

# Run Docker images (takes a LOT of disk space)
make docker

# Remove Docker images (frees disk space)
make docker-clean
```
