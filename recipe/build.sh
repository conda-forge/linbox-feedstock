#!/bin/bash

sed -i.bak "s/INSTR_SET//g" configure.ac
sed -i.bak "s/AC_COMPILER_NAME//g" configure.ac

autoreconf -if

export CPPFLAGS="-DDISABLE_COMMENTATOR $CPPFLAGS"
export CFLAGS="-g -fPIC $CFLAGS"
export CXXFLAGS="-g -fPIC $CXXFLAGS"

if [[ "$target_platform" == "linux-ppc64le" ]]; then
  export CXXFLAGS=$(echo "${CXXFLAGS}" | sed "s/-std=c++17/-std=gnu++17/g")
fi

chmod +x configure

./configure \
    --prefix="$PREFIX" \
    --with-default="$PREFIX" \
    --libdir="$PREFIX/lib" \
    --enable-sage \
    --disable-openmp \
    --enable-sse \
    --enable-sse2 \
    --disable-sse3 \
    --disable-ssse3 \
    --disable-sse41 \
    --disable-sse42 \
    --disable-avx \
    --disable-avx2 \
    --disable-fma \
    --disable-fma4 \
    --without-ocl \
    --without-fplll \
    --with-iml="$PREFIX" \
    --with-m4ri="$PREFIX" \
    --with-m4rie="$PREFIX" \
    --with-ntl="$PREFIX"

make -j${CPU_COUNT}
if [[ "$CI" == "drone" ]]; then
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  make check -j${CPU_COUNT}
fi
else
  make check
fi
make install
