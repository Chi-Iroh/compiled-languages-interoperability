#![no_main]

#[no_mangle]
pub extern "C" fn rs_hello() {
    println!("Hello, world from Rust !");
}
