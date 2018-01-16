using BinaryBuilder

# These are the platforms built inside the wizard
platforms = [
    BinaryProvider.Linux(:i686, :glibc),
  BinaryProvider.Linux(:x86_64, :glibc),
  BinaryProvider.Linux(:aarch64, :glibc),
  BinaryProvider.Linux(:armv7l, :glibc),
  BinaryProvider.Linux(:powerpc64le, :glibc),
  BinaryProvider.MacOS(),
  BinaryProvider.Windows(:i686),
  BinaryProvider.Windows(:x86_64)
]


# If the user passed in a platform (or a few, comma-separated) on the
# command-line, use that instead of our default platforms
if length(ARGS) > 0
    platforms = platform_key.(split(ARGS[1], ","))
end
info("Building for $(join(triplet.(platforms), ", "))")

# Collection of sources required to build Earcut
sources = [
    "https://github.com/JuliaGeometry/EarCut.jl.git" =>
    "bc89e3d30df5c40bf75b70ab8882636bd3554c61",
]

script = raw"""
cd $WORKSPACE/srcdir
cd EarCut.jl/deps/
g++ -c -fPIC -std=c++11 cwrapper.cpp -o earcut.o

if [[ ${target} == *-mingw32 ]]; then
    mkdir ${DESTDIR}/bin
    g++ -shared -o ${DESTDIR}/bin/earcut.dll earcut.o;
else
    mkdir ${DESTDIR}/lib
    if [[ ${target} == *-darwin* ]]; then
        g++ -shared -o ${DESTDIR}/lib/earcut.dylib earcut.o;
    else
        g++ -shared -o ${DESTDIR}/lib/earcut.so earcut.o;
    fi
fi

exit
"""

products = prefix -> [
    LibraryProduct(prefix,"earcut")
]


# Build the given platforms using the given sources
hashes = autobuild(pwd(), "Earcut", platforms, sources, script, products)
