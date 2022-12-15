#!/bin/sh
# Build GnuPG 1.4.13

if [[ ! -f "gnupg-1.4.13.tar.bz2" ]]; then
  echo "Ensure GnuPG sources are present"
  exit 1
fi

mkdir -v install/
mkdir -v home/

tar -xjvf gnupg-1.4.13.tar.bz2
mv -v gnupg-1.4.13/ src/
pushd src/

./configure \
  CFLAGS="-O2 -g -fcommon" \
  --prefix="${PWD}/../install/"
  --disable-exec
make -j$(nproc)
make check
make install

popd
