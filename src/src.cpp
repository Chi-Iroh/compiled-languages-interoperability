#include <iostream>

extern "C" {
    void cpp_hello() {
        std::cout << "Hello, world from C++ !\n";
    }
}
