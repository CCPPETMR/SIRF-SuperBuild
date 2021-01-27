# ChangeLog
## v#.#.#
- renames the environment scripts to env_ccpsynerbi.* . Creates a symbolic link or a copy to env_ccppetmr.* for backward compatibility
- Enabled HDF5 support for STIR by default (build C++ libraries for HDF5)
- Fix some issues with finding Python [#472](https://github.com/SyneRBI/SIRF-SuperBuild/issues/472)
- Add option `BUILD_TESTING_JSON` (default OFF)
- added flag CC_9 and CXX_9 to pass to Gadgetron for build as it requires GCC9
- added range-v3
- Updated versions:
   - JSON: 3.9.1
   - SWIG: 4.0.2
   - Gadgetron: master
   - ACE: 6.5.9

## v2.2.0
- Updated to reflect change from CCPPETMR to CCPSyneRBI.
- Made ${proj}_SOURCE_DIR a cached variables such that the user can point to an existing directory.
- Added support for passing CMAKE args to projects from the SuperBuild call.
- Use macros to drastically simplify (and reduce size of) the External*.cmake files.
- Pass HDF5_ROOT through to projects if it's defined and USE_SYSTEM_HDF5=ON
- Added checking whether default SWIG executable exists.
- Corrected logic around building SIRF and Registration.
- Added JSON as external package.
- Added option to build ITK with static libraries.
- Added option to skip ITK path length checks.
- Added option to compile Armadillo without HDF5 support.
- Added options to disable STIR JSON support.
- Added option to disable CUDA.
- Added option to disable Gadgetron checkouts.
- Added option to disable Python or MATLAB support.
- Sorted out Nifty PET capitalisation.
- Unified OpenMP control.
- Updated versions:
   - STIR: rel_4.0.2
   - CIL:  20.04
   - SIRF: 2.2.0

## v2.1.0
- Switch NiftyReg remote from `rijobro` to `KCL-BMEIS` (following the acceptance of one of our PRs to their code).
- Azure:
    - Added NVIDIA GPU support
    - Now using Terraform HCL v0.12
- Added CCPi CIL support and various packages for that
- Added preliminary install option for NiftyPET
- Added CUDA and OpenMP support for some packages
- Improved documentation for docker
- Updated various versions
    - NiftyReg: 1.5.68
    - ISMRMRD: v1.4.1
    - STIR: stir_rel_4_00_alpha
    - SIRF: v2.1.0
    - PET RD Tools: v1.1.0
    - Armadillo: 9.800.2
- petmr-rd-tools -> pet-rd-tools fixes

## v2.0.0
- Added CMake Variable `Gadgetron_USE_MKL` to allow Gadgetron build with MKL if available
- Added build of NiftyReg and ACE (optional)
- Added tests for various packages, not just SIRF (CMake variables `BUILD_TESTING_*`)
- Updated various versions
    - ISMRMRD: v1.4.0
    - Gadgetron: [b6191ea](https://github.com/gadgetron/gadgetron/commit/b6191eaaa72ccca6c6a5fe4c0fa3319694f512ab)
    - Boost: 1.65.1 (linux) 1.68.0 (OSX)
    - STIR to version of 9 Apr 2019
    - SIRF v2.0.0. If NiftyReg is built (or provided), SIRF will be built with registration capabilities.
- docker images updates
  - Ubuntu: 18.04
  - `:service` images with `Jupyter` and `SIRF-Exercises`
- addition of Azure scripts
- require CMake: 3.10.0
- changed some CMake variable names:
   - `BUILD_GADGETRON` -> `BUILD_Gadgetron`
   - `BUILD_GADGETRON_NATIVE_MATLAB_SUPPORT` -> `Gadgetron_BUILD_MATLAB_SUPPORT`
   - `BUILD_STIR_WITH_OPENMP` -> `STIR_ENABLE_OPENMP`
   - `BUILD_STIR_EXECUTABLES` -> `STIR_BUILD_EXECUTABLES`
   - `BUILD_STIR_SWIG_PYTHON` -> `STIR_BUILD_SWIG_PYTHON`
- petmr-rd-tools -> pet-rd-tools

## v1.1.0

- Added PYTHON_DEST_DIR variable, which allows the user to select the install destination of the SIRF python modules. PYTHON_DEST_DIR is a cached variable which can be updated on the GUI. If PYTHON_DEST_DIR is not set, we will install in ${CMAKE_INSTALL_PREFIX}/python. Likewise for MATLAB_DEST_DIR.
- Export `GADGETRON_HOME` environment variable (necessary for recent versions of Gadgetron)
- Updates to Docker builds
- On OSX, use the system boost by default to avoid run-time problems with boost dynamic libraries
- Build STIR with OPENMP

## v1.0.0

 - optionally build siemens_to_ismrmrd
 - optionally build petmr_rd_tools
 - major [restructuring](https://github.com/CCPPETMR/SIRF-SuperBuild/issues/16#issuecomment-360772097) of SuperBuild build directory
 - User can specify the location of the sources via the variable `SOURCES_ROOT_DIR`
 - Updated dependency versions (STIR)
 - Defaults to `USE_SYSTEM_BOOST=ON` on Windows and MacOSX [#63](https://github.com/CCPPETMR/SIRF-SuperBuild/issues/63), see [here](https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-on-MacOS#2-boost-)

## New in Release 0.9.1

- build specific versions of dependencies (ISMRMRD, Gadgetron, STIR, SIRF)
- run tests via CTest
