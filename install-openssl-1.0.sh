#!/usr/bin/env bash
set -ue

. .env

OPENSSL_VERSION="1.0.2t"

if [[ ! -e "openssl-$OPENSSL_VERSION.tar.gz" ]]; then
  echo "Downloading openssl-$OPENSSL_VERSION.tar.gz..." >&2
  wget "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz"
fi
if [[ ! -e "openssl-$OPENSSL_VERSION" ]]; then
  echo "Extracting openssl-$OPENSSL_VERSION.tar.gz..." >&2
  tar zxf "openssl-$OPENSSL_VERSION.tar.gz"
fi

cd "openssl-$OPENSSL_VERSION"
./config --prefix="$OPENSSL1_0_DIR" --shared
make -j4
# make test
make install_sw
