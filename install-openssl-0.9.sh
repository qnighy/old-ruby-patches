#!/usr/bin/env bash
set -ue

. .env

OPENSSL_VERSION="0.9.8zh"

if [[ ! -e "openssl-$OPENSSL_VERSION.tar.gz" ]]; then
  echo "Downloading openssl-$OPENSSL_VERSION.tar.gz..." >&2
  wget "https://www.openssl.org/source/old/0.9.x/openssl-$OPENSSL_VERSION.tar.gz"
fi
if [[ ! -e "openssl-$OPENSSL_VERSION" ]]; then
  echo "Extracting openssl-$OPENSSL_VERSION.tar.gz..." >&2
  tar zxf "openssl-$OPENSSL_VERSION.tar.gz"
fi

cd "openssl-$OPENSSL_VERSION"
./config --prefix="$OPENSSL0_9_DIR" --shared
make
# make test
make install_sw
