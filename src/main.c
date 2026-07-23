#include <HsFFI.h>

#include "../include/src.h"

void adainit(void);
void adafinal(void);

void __managed__Startup(void);

int main(int argc, char* argv[]) {
    adainit();
    ada_hello();
    adafinal();

    asm_hello();
    c_hello();

    cbl_hello();

    cpp_hello();

    __managed__Startup();
    cs_hello();

    f90_hello();
    go_hello();

    hs_init(&argc, &argv);
    hs_hello();
    hs_exit();

    rs_hello();
}
