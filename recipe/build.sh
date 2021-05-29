#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./build-aux

export CPPFLAGS="-DDISABLE_COMMENTATOR $CPPFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
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
