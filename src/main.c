#include <HsFFI.h>

#include "../include/src.h"

void adainit(void);
void adafinal(void);

void __managed__Startup(void);

void pascal_rtlInit(void);
void pascal_rtlDone(void);

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

    d_hello();
    f90_hello();
    go_hello();
    holyC_hello();

    hs_init(&argc, &argv);
    hs_hello();
    hs_exit();

    pascal_rtlInit();
    pas_hello();
    pascal_rtlDone();

    rs_hello();
    zig_hello();
}
