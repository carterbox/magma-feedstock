@echo on

:: This step is required when building from raw source archive
make generate --jobs %CPU_COUNT%
if errorlevel 1 exit /b 1

:: Duplicate lists because of https://bitbucket.org/icl/magma/pull-requests/32
set "CUDA_ARCH_LIST=sm_60,sm_61,sm_75,sm_80"
set "CUDAARCHS=35-virtual,60-virtual,70-virtual,80-virtual"

set CFLAGS=
set CXXFLAGS=

md build
cd build
if errorlevel 1 exit /b 1

:: Must add --use-local-env to NVCC_FLAGS otherwise NVCC autoconfigs the host
:: compiler to cl.exe instead of the full path. MSVC does not accept a
:: C++11 standard argument, and defaults to C++14
:: https://learn.microsoft.com/en-us/cpp/overview/visual-cpp-language-conformance?view=msvc-160
:: https://learn.microsoft.com/en-us/cpp/build/reference/std-specify-language-standard-version?view=msvc-160
cmake %SRC_DIR% ^
  -G "Ninja" ^
  -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS:BOOL=ON ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
  -DGPU_TARGET="%CUDA_ARCH_LIST%" ^
  -DMAGMA_ENABLE_CUDA:BOOL=ON ^
  -DUSE_FORTRAN:BOOL=OFF ^
  -DCMAKE_CUDA_FLAGS="--use-local-env" ^
  -DCMAKE_CUDA_SEPARABLE_COMPILATION:BOOL=OFF
if errorlevel 1 exit /b 1

cmake --build . ^
    --config Release ^
    --parallel %CPU_COUNT% ^
    --target magma ^
    --verbose
if errorlevel 1 exit /b 1

cmake --install .
if errorlevel 1 exit /b 1

rm -rf %LIBRARY_PREFIX%\include\*
rm %LIBRARY_PREFIX%\lib\pkgconfig\magma.pc
