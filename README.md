# Rusty V8 Binding

V8 Version: 10.5.218.1

[![ci](https://github.com/denoland/rusty_v8/workflows/ci/badge.svg?branch=main)](https://github.com/denoland/rusty_v8/actions)
[![crates](https://img.shields.io/crates/v/v8.svg)](https://crates.io/crates/v8)
[![docs](https://docs.rs/v8/badge.svg)](https://docs.rs/v8)

## 命令

```shell

docker build --target x86_64-linux-android --tag denoland/rusty_v8:x86_64-linux-android .


V8_FROM_SOURCE=1 cross build -vv --target aarch64-linux-android
```

## 修复流程

1. 修改build.rs 里的python ,全部改成python3

2. 修改文件build/print_clang_major_version.py，第11行，改成：

```python
major_version = int(re.search(b"version (\d+)\.\d+\.\d+", output).group(1))
```

3. 修改：/Users/mac/Desktop/waterbang/project/rust/rusty_v8/build/config/apple/sdk_info.py,71行

```python
settings['xcode_build'] = int[lines[-1].split((-1),16)]
```

## 下载地址

1. 下载: <https://codeload.github.com/denoland/ninja_gn_binaries/tar.gz/refs/tags/20220517>
解压到：tools目录下

2. 下载: <https://commondatastorage.googleapis.com/chromium-browser-clang/Linux_x64/clang-llvmorg-15-init-9576-g75f9e83a-3.tgz>
解压到：tools/clang  

3. 下载: <https://commondatastorage.googleapis.com/chrome-linux-sysroot/toolchain/3dc473ad845d3ae810c3e1be6f377e3eaa301c6e/debian_bullseye_arm64_sysroot.tar.xz>
解压到：build/linux/debian_bullseye_arm64-sysroot

4. 下载：git clone <https://chromium.googlesource.com/chromium/src/third_party/android_platform>
5. 下载：git clone <https://github.com/denoland/android_ndk.git>
6. 下载：git clone <https://chromium.googlesource.com/catapult.git>
到 third_party

### 环境配置

```shell
# 指向自己的ndk
export CLANG_BASE_PATH=/Users/mac/Library/Android/sdk/ndk/21.3.6528147

export GN=/Users/mac/Desktop/waterbang/project/rust/rusty_v8/tools/gn

export NINJA=/Users/mac/Desktop/waterbang/project/rust/rusty_v8/tools/ninja

```

### 问题

#### ERROR at //build/config/mac/mac_sdk.gni:95:31: No value named "xcode_build" in scope "_mac_sdk_result"[v8 0.48.0] xcode_build =_mac_sdk_result.xcode_build

安装 xcode

#### ERROR at dynamically parsed input that //build/config/mac/mac_sdk.gni:93:19 loaded :1:15: This is not a valid number.xcode_build=11C505

File "/Users/mac/Desktop/waterbang/project/rust/rusty_v8/build/config/apple/sdk_info.py", line 71
修改为 `settings['xcode_build'] = int[lines[-1].split((-1),16)]`

#### fatal error: 'features.h' file not found

检查  `--sysroot=../../../../third_party/android_ndk/toolchains/llvm/prebuilt/darwin-x86_64/sysroot`
观察ndk,是否没有`darwin-x86_64`,把目录下：
`third_party/android_ndk/toolchains/llvm/prebuilt/`的其他版本复制一分重命名为`darwin-x86_64`，或者是别的系统名。

### <urlopen error [Errno 111] Connection refused>

命令增加 ：V8_FROM_SOURCE=1  从头构建v8,不然官方的拉不到
 <!-- /Applications/Python\ 3.6/Install\ Certificates.command  -->

### 其他参考

<https://www.jianshu.com/p/435fc02819a0>

## Goals

1. Provide high quality Rust bindings to [V8's C++
   API](https://cs.chromium.org/chromium/src/v8/include/v8.h). The API should
   match the original API as closely as possible.

2. Do not introduce additional call overhead. (For example, previous attempts at
   Rust V8 bindings forced the use of Persistent handles.)

3. Do not rely on a binary `libv8.a` built outside of cargo. V8 is a very large
   project (over 600,000 lines of C++) which often takes 30 minutes to compile.
   Furthermore, V8 relies on Chromium's bespoke build system (gn + ninja) which is
   not easy to use outside of Chromium. For this reason many attempts to bind to V8
   rely on pre-built binaries that are built separately from the binding itself.
   While this is simple, it makes upgrading V8 difficult, it makes CI difficult, it
   makes producing builds with different configurations difficult, and it is a
   security concern since binary blobs can hide malicious code. For this reason we
   believe it is imperative to build V8 from source code during "cargo build".

4. Publish the crate on crates.io and allow docs.rs to generate documentation.
   Due to the complexity and size of V8's build, this is nontrivial. For example
   the crate size must be kept under 10 MiB in order to publish.

## Binary Build

V8 is very large and takes a long time to compile. Many users will prefer to use
a prebuilt version of V8. We publish static libs for every version of rusty v8
on [Github](https://github.com/denoland/rusty_v8/releases).

Binaries builds are turned on by default: `cargo build` will initiate a download
from github to get the static lib. To disable this build using the
`V8_FROM_SOURCE` environmental variable.

When making changes to rusty_v8 itself, it should be tested by build from
source. The CI always builds from source.

## The `V8_FORCE_DEBUG` environment variable

By default `rusty_v8` will link against release builds of `v8`, if you want to
use a debug build of `v8` set `V8_FORCE_DEBUG=true`.

We default to release builds of `v8` due to performance & CI reasons in `deno`.

## The `RUSTY_V8_MIRROR` environment variable

Tells the build script where to get binary builds from. Understands
`http://` and `https://` URLs, and file paths. The default is
<https://github.com/denoland/rusty_v8/releases/download>.

File-based mirrors are good for using cached downloads. First, point
the environment variable to a suitable location:

    # you might want to add this to your .bashrc
    $ export RUSTY_V8_MIRROR=$HOME/.cache/rusty_v8

Then populate the cache:

```bash
#!/bin/bash

# see https://github.com/denoland/rusty_v8/releases

for REL in v0.13.0 v0.12.0; do
  mkdir -p $RUSTY_V8_MIRROR/$REL
  for FILE in \
    librusty_v8_debug_x86_64-unknown-linux-gnu.a \
    librusty_v8_release_x86_64-unknown-linux-gnu.a \
  ; do
    if [ ! -f $RUSTY_V8_MIRROR/$REL/$FILE ]; then
      wget -O $RUSTY_V8_MIRROR/$REL/$FILE \
        https://github.com/denoland/rusty_v8/releases/download/$REL/$FILE
    fi
  done
done
```

## The `RUSTY_V8_ARCHIVE` environment variable

Tell the build script to use a specific v8 library. This can be an URL
or a path. This is useful when you have a prebuilt archive somewhere:

```bash
export RUSTY_V8_ARCHIVE=/path/to/custom_archive.a
cargo build
```

## Build V8 from Source

Use `V8_FROM_SOURCE=1 cargo build -vv` to build the crate completely from
source.

The build scripts require Python 3 to be available as `python` in your `PATH`.

For linux builds: glib-2.0 development files need to be installed such that
pkg-config can find them. On Ubuntu, run `sudo apt install libglib2.0-dev` to
install them.

For Windows builds: the 64-bit toolchain needs to be used. 32-bit targets are
not supported.

The build depends on several binary tools: `gn`, `ninja` and `clang`. The
tools will automatically be downloaded, if they are not detected in the environment.

Specifying the `$GN` and `$NINJA` environmental variables can be used to skip
the download of gn and ninja. The clang download can be skipped by setting
`$CLANG_BASE_PATH` to the directory containing a `llvm`/`clang` installation.
V8 is known to rely on bleeding edge features, so LLVM v8.0+ or Apple clang 11.0+
is recommended.

Arguments can be passed to `gn` by setting the `$GN_ARGS` environmental variable.

Env vars used in when building from source: `SCCACHE`, `CCACHE`, `GN`, `NINJA`,
`CLANG_BASE_PATH`, `GN_ARGS`

## FAQ

**Building V8 takes over 30 minutes, this is too slow for me to use this crate.
What should I do?**

Install [sccache](https://github.com/mozilla/sccache) or
[ccache](https://ccache.dev/). Our build scripts will detect and use them. Set
the `$SCCACHE` or `$CCACHE` environmental variable if it's not in your path.

**What are all these random directories for like `build` and `buildtools` are
these really necessary?**

In order to build V8 from source code, we must provide a certain directory
structure with some git submodules from Chromium. We welcome any simplifications
to the code base, but this is a structure we have found after many failed
attempts that carefully balances the requirements of cargo crates and
GN/Ninja.

**V8 has a very large API with hundreds of methods. Why don't you automate the
generation of this binding code?**

In the limit we would like to auto-generate bindings. We have actually started
down this route several times, however due to many eccentric features of the V8
API, this has not proven successful. Therefore we are proceeding in a
brute-force fashion for now, focusing on solving our stated goals first. We hope
to auto-generate bindings in the future.

**Why are you building this?**

This is to support [the Deno project](https://deno.land/). We previously have
gotten away with a simpler high-level Rust binding to V8 called
[libdeno](https://github.com/denoland/deno/tree/32937251315493ef2c3b42dd29340e8a34501aa4/core/libdeno).
But as Deno has matured we've found ourselves continually needing access to an
increasing amount of V8's API in Rust.

**When building I get unknown argument: '-gno-inline-line-tables'**

Use `export GN_ARGS="no_inline_line_tables=false"` during build.
