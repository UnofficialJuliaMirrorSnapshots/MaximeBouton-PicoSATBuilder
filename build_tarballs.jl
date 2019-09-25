# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "PicoSATBuilder"
version = v"9.6.0"

# Collection of sources required to build PicoSATBuilder
sources = [
    "http://fmv.jku.at/picosat/picosat-960.tar.gz" =>
    "edb3184a04766933b092713d0ae5782e4a3da31498629f8bb2b31234a563e817",

]

# Bash recipe for building across all platforms
script = raw"""

cd $WORKSPACE/srcdir
cd picosat-960/
if [[ ${target} == *-apple-* ]]; then 
    export CC=/opt/x86_64-linux-gnu/tools/clang 
    export CFLAGS="--target=${target} --sysroot=/opt/${target}/${target}/sys-root"
    sed -i 's/-soname/-install_name/' makefile.in
else
    export CC=/opt/${target}/bin/${target}-gcc
fi

if [[ ${nbits} == 32 ]]; then
    ./configure --shared --32
else 
    ./configure --shared
fi

make

if [[ ${target} == *-mingw* ]]; then
    mv libpicosat.so libpicosat.dll
elif [[ ${target} == *-apple-* ]]; then
    mv libpicosat.so libpicosat.dylib
fi

mv libpicosat* $prefix
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    MacOS(),
    Windows(:x86_64),
    Windows(:i686),
    Linux(:x86_64, :glibc),
    Linux(:i686, :glibc)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libpicosat", :libpicosat)
]


# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

