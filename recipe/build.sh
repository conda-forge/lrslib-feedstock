#!/bin/bash

if [[ "$target_platform" == "win-64" ]]; then
  export PREFIX=${PREFIX}/Library
  # MinGW doesn't use soname; replace with --out-implib to produce import library
  sed -i "s/-Wl,-soname=/-Wl,--out-implib=/g" makefile
  OPTIONS="SONAME=liblrs.dll.a SHLIB=liblrs.dll SHLINK=liblrs.dll.a"
  # Disable POSIX signal handling and resource timing (not available on Windows)
  export CPPFLAGS="${CPPFLAGS} -DSIGNALS -DTIMES"
elif [[ "$target_platform" == osx-* ]]; then
  sed -i "s/-Wl,-soname=/-Wl,-install_name,/g" makefile
  OPTIONS="SONAME=liblrs.0.dylib SHLIB=liblrs.0.0.0.dylib SHLINK=liblrs.dylib"
fi
export CC="${CC} ${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"
make INCLUDEDIR=${PREFIX}/include LIBDIR=${PREFIX}/lib prefix=$PREFIX all-shared install -j${CPU_COUNT} $OPTIONS
if [[ "$target_platform" == "win-64" ]]; then
  cp ${PREFIX}/bin/lrs.exe ${PREFIX}/bin/redund.exe
  # DLLs must be on PATH; copy liblrs.dll to bin/ where executables live
  mv ${PREFIX}/lib/liblrs.dll ${PREFIX}/bin/
else
  ln -sf ${PREFIX}/bin/lrs ${PREFIX}/bin/redund
fi
