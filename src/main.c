#include <HsFFI.h>

#include "../include/src.h"

int main(int argc, char* argv[]) {
    asm_hello();
    c_hello();
    cpp_hello();

    f90_hello();
    go_hello();

    hs_init(&argc, &argv);
    hs_hello();
    hs_exit();

    rs_hello();
}
