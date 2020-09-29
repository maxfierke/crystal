#!/bin/bash

set -euo pipefail

WASI_SDK_PATH=${WASI_SDK_PATH:-"$HOME/toolchains/wasi-sdk-11.0"}
INITIAL_MEMORY=${INITIAL_MEMORY:-16777216}
MAX_MEMORY=${MAX_MEMORY:-2147483648}
STACK_SIZE=${STACK_SIZE:-5242880}

export CC="$WASI_SDK_PATH/bin/clang --sysroot=$WASI_SDK_PATH/share/wasi-sysroot"
export LIBRARY_PATH="$WASI_SDK_PATH/share/wasi-sysroot/lib/wasm32-wasi"
export CRYSTAL_LIBRARY_PATH="$HOME/toolchains/crystal-wasm-libs/targets/wasm32-wasi"
export WASM_LDFLAGS="-Wl,--allow-undefined \
-Wl,--initial-memory=${INITIAL_MEMORY} \
-Wl,--max-memory=${MAX_MEMORY}         \
-Wl,-z -Wl,stack-size=${STACK_SIZE}    \
-Wl,--stack-first                      \
-Wl,--no-threads"

linker_command=$(bin/crystal build \
  spec/std_spec.cr \
  --exclude-warnings spec/std \
  --exclude-warnings spec/compiler \
  -Dgc_none \
  -Dwithout_openssl \
  -Dwithout_zlib \
  -Di_know_what_im_doing \
  --cross-compile \
  --target wasm32-wasi \
  --static \
  --error-trace \
  --link-flags="$WASM_LDFLAGS")
binary_path="./$(echo "$linker_command" | grep -oP '(?<=-o\s)(.*)(?=\.wasm)').wasm"

eval $linker_command

wavm run \
  --abi=wasi \
  --enable all-proposed \
  "$binary_path"
