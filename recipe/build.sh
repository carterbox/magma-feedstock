set -exv

export CUDA_ARCH_LIST="-gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_60,code=sm_60 -gencode arch=compute_70,code=sm_70"

if [[ "$cuda_compiler_version" == "11.1" || "$cuda_compiler_version" == "11.2" ]]; then
  CUDA_ARCH_LIST="$CUDA_ARCH_LIST -gencode arch=compute_80,code=sm_80 -gencode arch=compute_86,code=sm_86"
elif [[ "$cuda_compiler_version" == "11.0" ]]; then
  CUDA_ARCH_LIST="$CUDA_ARCH_LIST -gencode arch=compute_80,code=sm_80"
fi

mkdir build
cd build

# Upstream doesn't properly pass host compiler args to NVCC, so we have to pass
# them here with CUDA_NVCC_FLAGS.
cmake $SRC_DIR \
  -G "Ninja" \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCUDA_ARCH_LIST="$CUDA_ARCH_LIST" \
  -DGPU_TARGET="all" \
  -DMAGMA_ENABLE_CUDA:BOOL=ON \
  -DUSE_FORTRAN=OFF \
  -DCUDA_NVCC_FLAGS="--use-local-env --fatbin -Xcompiler -std=c++11" \
  ${CMAKE_ARGS}

# Only build library targets not any of the tests
cmake --build . -j${CPU_COUNT} --verbose --target magma magma_sparse

cmake --install .
