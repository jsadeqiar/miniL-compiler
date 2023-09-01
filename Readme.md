CS152 Project Phase 3 - Code Generation
========================================

[Home Page - Phase3 Code Generation Part1](https://www.cs.ucr.edu/~dtan004/proj3/phase3_code_generator.html)

[Home Page - Phase3 Code Generation Part2](https://www.cs.ucr.edu/~dtan004/proj4/phase3_code_generator.html)


## Tools preparation

Make sure you have a Linux environment for this project. You can use 'bolt', your own Linux machine, or Windows Subsystem for Linux(WSL). We highly recommend you directly use 'bolt' since it contains all the necessary tools preinstalled. 

```sh
ssh <your-net-id>@bolt.cs.ucr.edu
```

Make sure you have the following tools installed and check the version:
1. flex -V       (>=2.5)
2. bison -V      (>=3.0)
3. git --version (>=1.8)
4. make -v       (>=3.8)
5. gcc -v        (>=4.8)
6. g++ -v        (>=4.8)

## Clone and Build

Use 'git' to clone the project template and copy your code in phase 2 into this new repository.

```sh
    git clone <your-repo-link> phase3
    cd miniL-compiler && make
```
