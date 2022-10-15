@echo on

:: Set CUDACXX with call to 'where nvcc'
for /f "tokens=* usebackq" %%f in (`where nvcc`) do (set "dummy=%%f" && call set "CUDACXX=%%dummy:\=\\%%")

set "CXX=C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64\cl.exe"
set "CUDAHOSTCXX=C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64\cl.exe"
set "CUDACXX=%CUDA_HOME%\bin\nvcc.exe"

set "CUDA_ARCH_LIST=-gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_60,code=sm_60 -gencode arch=compute_70,code=sm_70"

if %cuda_compiler_version% == "11.2" (
    set "CUDA_ARCH_LIST=%CUDA_ARCH_LIST% -gencode arch=compute_80,code=sm_80 -gencode arch=compute_86,code=sm_86"
)
if %cuda_compiler_version% == "11.1" (
    set "CUDA_ARCH_LIST=%CUDA_ARCH_LIST% -gencode arch=compute_80,code=sm_80 -gencode arch=compute_86,code=sm_86"
)
if %cuda_compiler_version% ==  "11.0" (
    set "CUDA_ARCH_LIST=%CUDA_ARCH_LIST% -gencode arch=compute_80,code=sm_80"
)

:: std=c++11 is required to compile some .cu files
:: TODO: See if that's required on Windows, and how to enable in that case

set CFLAGS=
set CXXFLAGS=
set CPPFLAGS=

echo nvcc is %CUDACXX%
echo cxx is %CXX%

md build
cd build
if errorlevel 1 exit /b 1

cmake %CMAKE_ARGS% .. ^
  -DUSE_FORTRAN=OFF ^
  -DGPU_TARGET="All" ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
  -DCUDA_ARCH_LIST="%CUDA_ARCH_LIST%" ^
  -DLAPACK_LIBRARIES="%LIBRARY_PREFIX%\lib\lapack.lib;%LIBRARY_PREFIX%\lib\blas.lib" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBUILD_SPARSE=OFF ^
  -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS:BOOL=ON
if errorlevel 1 exit /b 1

cmake --build . --config Release
if errorlevel 1 exit /b 1

cmake --install .
if errorlevel 1 exit /b 1
