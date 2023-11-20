fn main() {
    let mut build = cc::Build::new();
    // build.file("src/your_c_file.c");
    build.include("/usr/include/libunwind");
    build.flag_if_supported("-lunwind");
    build.compile("libunwind.a");
    println!("cargo:rustc-link-search=native={}", "/usr/lib/x86_64-linux-gnu");
    println!("cargo:rustc-link-lib=static=unwind");
}
