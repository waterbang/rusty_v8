# Rusty V8 Binding for android suport

V8 Version: 11.0.226.5

[![ci](https://github.com/denoland/rusty_v8/workflows/ci/badge.svg?branch=main)](https://github.com/denoland/rusty_v8/actions)
[![crates](https://img.shields.io/crates/v/v8.svg)](https://crates.io/crates/v8)
[![docs](https://docs.rs/v8/badge.svg)](https://docs.rs/v8)

## Compilation process

### before

First you need to install docker on your computer.

### install cross

```bash
cargo install cross --git https://github.com/cross-rs/cross
```

### cross build aarch64-linux-android 

```bash
 V8_FROM_SOURCE=1 cross build -vv --target aarch64-linux-android --release
```

### cargo build aarch64-linux-android 

```bash
 V8_FROM_SOURCE=1 cargo build -vv --target aarch64-linux-android --release
```
### problem

>Downloading https://github.com/denoland/ninja_gn_binaries/archive/20221218.tar.gz...
><urlopen error [Errno 111] Connection refused>

```bash
 wget https://github.com/denoland/ninja_gn_binaries/archive/20221218.tar.gz && tar -zxvf 20221218.tar.gz ninja_gn

# Select the appropriate operating system
export GN="$PWD/tools/ninja_gn/mac-amd64/gn" && export NINJA="$PWD/tools/ninja_gn/mac-amd64/ninja" 
```