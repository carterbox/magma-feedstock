set -exv

# This step is required when building from raw source archive
make generate --jobs ${CPU_COUNT}

# Duplicate lists because of https://bitbucket.org/icl/magma/pull-requests/32
export CUDA_ARCH_LIST="sm_35,sm_50,sm_61,sm_75,sm_80,sm_86"
export CUDAARCHS="35;50;61;75;80;86"

# Remove CXX standard flags added by conda-forge. std=c++11 is required to
# compile some .cu files
CXXFLAGS="${CXXFLAGS//-std=c++17/-std=c++11}"

mkdir build
cd build

cmake $SRC_DIR \
  -G "Ninja" \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DGPU_TARGET=$CUDA_ARCH_LIST \
  -DMAGMA_ENABLE_CUDA:BOOL=ON \
  -DUSE_FORTRAN:BOOL=OFF \
  -DCMAKE_CUDA_SEPARABLE_COMPILATION:BOOL=ON \
  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION:BOOL=ON \
  ${CMAKE_ARGS}

# Explicitly name build targets to avoid building tests
cmake --build . \
    --parallel ${CPU_COUNT} \
    --target magma \
    --verbose

cmake --install .

rm -rf $PREFIX/include/*
rm $PREFIX/lib/pkgconfig/magma.pc
