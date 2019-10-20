#!/usr/bin/env bash
set -ue

. .env

target_ruby_version="$1"

if [[ ! -e ruby ]]; then
  git clone https://github.com/ruby/ruby.git
fi
cd ruby
git checkout "$1"

if [[ $target_ruby_version < v2_4_0 ]]; then
  export LD_LIBRARY_PATH="$OPENSSL1_0_DIR/lib"
  export PKG_CONFIG_PATH="$OPENSSL1_0_DIR/lib/pkgconfig"
fi
if [[ $target_ruby_version < v1_9_2 ]]; then
  export LD_LIBRARY_PATH="$OPENSSL0_9_DIR/lib"
  export PKG_CONFIG_PATH="$OPENSSL0_9_DIR/lib/pkgconfig"
fi
if [[ v1_8_z < $target_ruby_version && $target_ruby_version < v2_1_0 ]]; then
  if ! grep 'static int yylex(void\*)' parse.y >/dev/null; then
    patch -p1 < ../patches/pure-parser.patch
  fi
fi
if [[ v1_8_z < $target_ruby_version && $target_ruby_version < v2_0_0 ]]; then
  if ! grep 'extern int yydebug' tool/ytab.sed >/dev/null; then
    if grep 'yymsg' tool/ytab.sed >/dev/null; then
      patch -p1 < ../patches/extern-int-yydebug.patch
    else
      patch -p1 < ../patches/extern-int-yydebug-a.patch
    fi
  fi
fi
if [[ v1_8_z < $target_ruby_version && $target_ruby_version < v1_9_1 ]]; then
  if grep 'module RubyVM' tool/instruction.rb >/dev/null; then
    patch -p1 < ../patches/rubyvm-class.patch
  fi
fi
if [[ $target_ruby_version < v1_9_1 ]]; then
  if ! grep 'HAVE_BN_RAND_RANGE' ext/openssl/openssl_missing.h >/dev/null; then
    patch -p1 < ../patches/bn-rand-range.patch
  fi
fi
if [[ $target_ruby_version < v1_9_1 ]]; then
  if grep '$$ = in_single;' parse.y >/dev/null; then
    patch -p1 < ../patches/num-in-single.patch
  fi
fi
if [[ v1_8_z < $target_ruby_version && $target_ruby_version < v1_9_1 ]]; then
  if ! grep '#include "parse\.h"' parse.y >/dev/null; then
    patch -p1 < ../patches/parse-h.patch
  fi
fi
if [[ $target_ruby_version < v1_8_7 ]]; then
  if ! grep 'HAVE_GROUP_MEMBER' file.c >/dev/null; then
    patch -p1 < ../patches/group-member.patch
  fi
fi

if [[ ! -e configure ]]; then
  autoconf
fi
if [[ ! -e Makefile ]]; then
  ./configure
fi
make -j4
