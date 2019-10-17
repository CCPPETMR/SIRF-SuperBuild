# SIRF-SuperBuild

[![CI-badge]][CI-link] [![style-badge]][style-link] [![docker-badge]][docker-link]
![install-badge]

The SIRF-SuperBuild allows the user to download and compile most of the software
needed to compile SIRF and Gadgetron, and automatically build SIRF and Gadgetron.
There is still a small number of libraries that are not installed
by the SuperBuild, [see below for more info for your operating system](#os-specific-information).

## Table of Contents

1. [Dependencies](#Dependencies)
2. [Generic instructions](#Generic-instructions)
    1. [Create the SuperBuild directory](#Create-the-SuperBuild-directory)
    2. [Install CMake](#Install-CMake)
    3. [Clone the SIRF-SuperBuild project](#Clone-the-SIRF-SuperBuild-project)
    4. [Build and Install](#Build-and-Install)
    5. [Example Gadgetron configuration file](#Example-Gadgetron-configuration-file)
    6. [Set Environment variables](#Set-Environment-variables)
    7. [Open a terminal and start Gadgetron](#Open-a-terminal-and-start-Gadgetron)
    8. [Testing](#Testing)
    9. [Running examples](#Running-examples)
3. [OS specific information](#OS-specific-information)
   1. [Installation instructions for Ubuntu](#Ubuntu-install)
   2. [Installation instructions for Mac OS](#OSX-install)
   3. [Installation instructions for Docker](#Docker-install)
4. [Advanced installation](#Advanced-installation)
   1. [Compiling against your own packages](#Compiling-packages)
   2. [Python and MATLAB installation locations](#Python-and-MATLAB-installation-locations)
   3. [Building with specific versions of dependencies](#Building-with-specific-versions-of-dependencies)
   4. [Building with Intel Math Kernel Library](#Building-with-Intel-Math-Kernel-Library)
   5. [Building CCPi CIL](#Building-CCPi-CIL)

## Dependencies

The SuperBuild depends on CMake >= 3.10.

If you are building Gadgetron there are a series of [additional dependencies](https://github.com/gadgetron/gadgetron/wiki/List-of-Dependencies), which must be met.

## Generic instructions

To compile and install SIRF with the SuperBuild follow these steps:

### Create the SuperBuild directory
We will assume in these instructions that you want to install the software in `~/devel'. You
can of course decide to put it elsewhere. Let's create it first.
```bash
mkdir ~/devel
```

### Install CMake
If you do not have CMake >= 3.10 install it first ([download link](https://cmake.org/download/)). On Ubuntu Linux,
you can issue the following commands

```bash
ver=3.10.3
sudo mkdir /opt/cmake
cd /opt/cmake
wget -c https://github.com/Kitware/CMake/releases/download/v${ver}/cmake-${ver}-Linux-x86_64.tar.gz
tar xzf /tmp/cmake-${ver}-Linux-x86_64.tar.gz --strip 1
rm /tmp/cmake-${ver}-Linux-x86_64.tar.gz
export PATH=/opt/cmake/bin:$PATH
```
During installation you will be asked to read and accept CMake's license. If you answered the last question during the CMake installation with yes, then you should use

```
export PATH=/opt/cmake/cmake-${ver}-Linux-x86_64/bin:$PATH
```
Note that the above `PATH` statements won't work if you are running csh. The equivalent would be for instance
```csh
set path = ( /opt/cmake/bin $path )
```
You might want to add the `PATH` line to your start-up file (e.g. `.profile` or `.cshrc`).

### Clone the SIRF-SuperBuild project
```bash
cd ~
cd devel
git clone https://github.com/CCPPETMR/SIRF-SuperBuild.git
```

### Build and Install
Create a build directory and configure the software.

Note that if you want to use MATLAB, you need to use (and specify) a compiler supported by MATLAB
and might have to tell CMake where MATLAB is located. Please
check our [SIRF and MATLAB page](https://github.com/CCPPETMR/SIRF/wiki/SIRF-and-MATLAB).

```bash
cd ~/devel
mkdir build
cd build
cmake ../SIRF-SuperBuild
```
Use your build environment to build and install the project. On Linux/OSX etc, you would normally use
```bash
[sudo] make -jN
```
where `N` are the number of cores you want to use for the compilation. You will only need the `sudo` command if you are building in a system folder (e.g., `/usr/local`). For Eclipse/XCode/Visual Studio, you could open the project, or try something like
```bash
cmake --build . --config Release
```

Note that there is no separate install step.

### Example Gadgetron configuration file
Gadgetron requires a configuration file. An example is supplied and, as a starting point, this can be copied and used as the real thing:
```
mv INSTALL/share/gadgetron/config/gadgetron.xml.example INSTALL/share/gadgetron/config/gadgetron.xml
```

### Set Environment variables
Source a script with the environment variables appropriate for your shell

For instance, for sh/bash/ksh etc
```bash
cd ~/devel/build
source INSTALL/bin/env_ccppetmr.sh
```
You probably want to add a similar line (with absolute path) to your .bashrc/.profile.

Or for csh
```csh
cd ~/devel/build
source INSTALL/bin/env_ccppetmr.csh
```
You probably want to add a similar line (with absolute path) to your .cshrc.

### Open a terminal and start Gadgetron
To be able to use Gadgetron, a Gadgetron client must already be open in another terminal window. To do this, open a new terminal window and enter:

```
gadgetron
```

N.B.: If you didn't add any of the above statements to your .bashrc or .cshrc, you will have to source env_ccpetmr.* again in this terminal first.

### Testing
Tests for the SIRF-SuperBuild are currently the SIRF tests. The tests can contain tests from all SuperBuild projects.
After setting the environment variables and starting Gadgetron, you can run tests as:

```bash
cd ~/devel/build
ctest --verbose
```

Typical output will be something like
```
test 1
    Start 1: SIRF_TESTS

1: Test command: /usr/local/bin/ctest "test"
1: Test timeout computed to be: 9.99988e+06
1: Test project /home/sirfuser/devel/SIRF-SuperBuild/SIRF-prefix/src/SIRF-build
1:     Start 1: PET_TEST1
1: 1/3 Test #1: PET_TEST1 ........................   Passed    2.94 sec
1:     Start 2: MR_FULLY_SAMPLED
1: 2/3 Test #2: MR_FULLY_SAMPLED .................   Passed    3.83 sec
1:     Start 3: MR_UNDER_SAMPLED
1: 3/3 Test #3: MR_UNDER_SAMPLED .................   Passed    2.93 sec
1:
1: 100% tests passed, 0 tests failed out of 3
1:
1: Total Test time (real) =   9.70 sec
1/1 Test #1: SIRF_TESTS .......................   Passed    9.70 sec

100% tests passed, 0 tests failed out of 1

Total Test time (real) =   9.70 sec
```

The user may also run the SIRF tests independently of the SuperBuild. Just enter the SIRF build directory and launch `ctest`:

```bash
cd ~/devel/build
cd SIRF-prefix/src/SIRF-build
ctest --verbose
```
If you see failures, you might not have followed the above steps correctly, or have some missing Python modules.

### Running examples
We distribute examples for both Python and MATLAB. You can find them as follows:
```bash
cd $SIRF_PATH
cd examples
ls
```
See [our related Wiki page](https://github.com/CCPPETMR/SIRF/wiki/Examples) for more information.

## OS specific information

### Installation instructions for Ubuntu <a name="Ubuntu-install"></a>
They can be found [here](https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-Ubuntu-16.04)

### Installation instructions for Mac OS <a name="OSX-install"></a>
They can be found [here](https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-on-MacOS)

### Installation instructions for Docker <a name="Docker-install"></a>
They can be found [here](https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-on-Docker)

## Advanced installation

### Compiling against your own packages <a name="Compiling-packages"></a>
SIRF depends on many packages. By default, these packages are installed by the Superbuild. However, the user can decide to compile SIRF against their own versions of certain packages. This can be done via the `USE_SYSTEM_*` options in `CMake`. For example, if you wish to compile SIRF against a version of Boost that is already on your machine, you could set `USE_SYSTEM_BOOST` to `ON`.

This `USE_SYSTEM_*` function can be used for as many or as few packages as desired. Advantages to building against your own version of certain packages are decreased compilation times and the potential to use newer versions of these packages.

However, we have only tested SIRF with the versions of the required dependencies that are built by default in the Superbuild. If you decide to compile SIRF using system versions of the dependencies, you run a greater risk of something going wrong.

For this reason, we advise new SIRF users to compile with all the `USE_SYSTEM_*` options disabled. If you decide to use system versions of certain packages, we would be interested to hear about it any compatibility issues that you may run into.

### Python and MATLAB installation locations
By default, Python and MATLAB executables and libraries are installed under `CMAKE_INSTALL_PREFIX/python` and `CMAKE_INSTALL_PREFIX/matlab`, respectively. If you wish for them to be installed elsewhere, you can simply cut and paste these folders to their desired locations.

In this case, you would then need to ensure that `PYTHONPATH` and `MATLABPATH` are updated accordingly. This is because the sourced `env_ccppetmr` will point to the original (old) location.

### Building with specific versions of dependencies
By default, the SuperBuild will build the latest stable release of SIRF and associated versions of the dependencies. However, the SuperBuild allows the user to change the versions of the projects it's building.

This is done at the configuration stage that happens when you run `cmake`.

There is a `DEVEL_BUILD` tag that allows to build the upstream/master versions of all packages (`DEVEL_BUILD=ON`). In the following table are listed example versions (hashes) of dependencies that are built by the SuperBuild. The current default values can be found in [version_config.cmake](version_config.cmake).

|TAG        | DEVEL_BUILD=OFF (default) | DEVEL_BUILD=ON |
|:--------- |:--------------- |:-------------- |
|`SIRF_TAG` | `v2.0.0`          | `origin/master`         |
|`STIR_URL` |  https://github.com/UCL/STIR | https://github.com/UCL/STIR |
|`STIR_TAG` | `3a277f7a819f35a553a8d6097402ea25cf55a240` | `origin/master` |
|`Gadgetron_URL` | https://github.com/gadgetron/gadgetron |https://github.com/gadgetron/gadgetron |
|`Gadgetron_TAG` | `b6191eaaa72ccca6c6a5fe4c0fa3319694f512ab`  | `origin/master` |
|`ISMRMRD_URL` | https://github.com/ismrmrd/ismrmrd | https://github.com/ismrmrd/ismrmrd |
|`ISMRMRD_TAG` | `v1.4.0` | `origin/master` |
|`NIFTYREG` | `99d584e2b8ea0bffe7e65e40c8dc818751782d92` | `99d584e2b8ea0bffe7e65e40c8dc818751782d92` |

One may want to use only a specific version of a package. This is achieved by adding the right tag to the command line (see the table above for some available tags):

```bash
cd ~/devel/build
cmake ../SIRF-SuperBuild -DSIRF_TAG=<a valid hash>
```

To use the `DEVEL_BUILD` option one may (on the terminal)

```bash
cd ~/devel/build
cmake ../SIRF-SuperBuild -DDEVEL_BUILD=ON -U*_TAG -U*_URL
```
The `-U` flags will make sure that cached CMake variables are removed such that `DEVEL_BUILD=ON` will
set them to the desired versions.

Note that the CMake options in the table are Advanced Options. When running the CMake GUI (or ccmake) they will therefore only be visible when you toggle those on.

*Warning:* All these variables are cached. This means that once set, you have to change them one by one. Setting
`DEVEL_BUILD=ON` will therefore not work as expected on an existing build. You will need to delete the cached variables first.
You could do
```sh
cmake -DDEVEL_BUILD=ON -USIRF_URL -USIRF_TAG -USTIR_URL -USTIR_TAG -UGadgetron_URL -UGadgetron_TAG -UISMRMRD_URL -UISMRMRD_TAG .
```

### Building with Intel Math Kernel Library

[Gadgetron](https://github.com/CCPPETMR/SIRF/wiki/SIRF,-Gadgetron-and-MKL) and Armadillo can make use of Intel's Math Kernel Library. 

1. Install Intel MKL following the instructions at [their](https://software.intel.com/en-us/mkl) website. For debian based linux follow [this link](https://software.intel.com/en-us/articles/installing-intel-free-libs-and-python-apt-repo). The latter will install MKL in `opt/intel`
2. Gadgetron's [FindMKL.cmake](https://github.com/gadgetron/gadgetron/blob/master/cmake/FindMKL.cmake#L23) will try to look for MKL libraries in `/opt/intel` on Unix/Apple and in `C:/Program Files (x86)/Intel/Composer XE` in Windows. Make sure that this is the location of the library or pass the vatiable `MKLROOT_PATH` (Unix/Apple) or set the environment variable `MKLROOT_PATH` on Windows.
3. Configure the SuperBuild to pass `Gadgetron_USE_MKL=ON`. To disable/enable after you've run `cmake` use `-UGadgetron_USE_MKL -DGadgetron_USE_MKL=ON` or `OFF` accordingly. 

Notice that other packages may look for a blas implementation issuing CMake's [`find_package(BLAS)`](https://github.com/Kitware/CMake/blob/master/Modules/FindBLAS.cmake#L142L148). This will look for MKL taking hint directories from the environment variable `LD_LIBRARY_PATH`, `DYLD_LIBRARY_PATH` and `LIB`, on Unix, Apple and Windows respectively. 

### Building CCPi CIL

It is possible to build the [CCPi Core Imaging Library CIL](https://www.ccpi.ac.uk/CIL) as part of the SuperBuild. The CIL consists on a few pieces of software (`CCPi-Framework`, `CCPi-FrameworkPlugins`, `CCPi-Regularisation-Toolkit`, `CCPi-Astra`)There are 2 options: 

1. `BUILD_CIL` will build CIL and [ASTRA-toolbox](https://github.com/astra-toolbox/astra-toolbox) and [TomoPhantom](https://github.com/dkazanc/TomoPhantom)
2. `BUILD_CIL_LITE` will build only CIL (and leave out `CCPi-Astra`)

## Notes

* As CMake doesn't come with FFTW3 support, it is currently necessary to have `FindFFTW3.cmake` reproduced 3 times. sigh.

* This is poorely documented in FindFFTW3.cmake, which could be fixed by a PR to Gadgetron, ISMRMRD and SIRF. Similarly, we could fix `FindFFTW3.cmake` to also use the CMake variable.

* KT has tried to use `set(ENV{FFTW3_ROOT_DIR} bloe)` in our `External_FindFFTW.cmake`. This however doesn't pass the environment variable to the CMake instances for Gadgetron etc.

* By the way, when using `USE_SYSTEM_FFTW3=OFF`, CMake currently does find our own installation even if the `FFTW3_ROOT_DIR` env variable (as find_library etc give precedence to `MAKE_PREFIX_PATH` over `HINTS` ).

* CMake does come with FindArmadillo.cmake but it currently (at least up to CMake 3.12) has no variable to specify its location at all. This implies that when using `USE_SYSTEM_ARMADILLO=On`, you have to install armadillo in a system location, unless some extra work is done. See [this post on stackoverflow](https://stackoverflow.com/questions/35304513/cmake-find-armadillo-library-installed-in-a-custom-location) for some suggestions, which we haven't tried.

[CI-badge]: https://travis-ci.org/CCPPETMR/SIRF-SuperBuild.svg?branch=master
[CI-link]: https://travis-ci.org/CCPPETMR/SIRF-SuperBuild
[style-badge]: https://api.codacy.com/project/badge/Grade/c1a4613d4bd247d19780881f8194eaf8
[style-link]: https://www.codacy.com/app/CCP-PETMR/SIRF-SuperBuild
[docker-badge]: https://img.shields.io/docker/pulls/ccppetmr/sirf.svg
[docker-link]: https://hub.docker.com/r/ccppetmr/sirf
[install-badge]: https://img.shields.io/badge/dynamic/json.svg?label=users&uri=https%3A//raw.githubusercontent.com/ccp-petmr-codebot/github-stats/CCPPETMR/SIRF-SuperBuild/CCPPETMR_SIRF_SuperBuild.json&query=total&colorB=8000f0&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAD0ElEQVR4nMSXS2ic5RfGf5lL/pPMZP7JjB0ba53axkvRegGhpFaxVkqjOxetoi6UUjG4ELdVFy50I6gLtfUCFilUiwheilZXIm1FiZSCpYmYRppoUpvRJONMOpmJnOT54DBtxk4CmQPDl/d85z3vc55zeb%2BEWJr0AE8uxcFSAWwE7mwkgE7gqkYCWAGkGwkgBVQaCSACFBsJwPaXgGijAJhMAonlAvAc0OHWlv8pB8BS8hLQtFhAtaRFdD%2BodQz4BngbuEm624BZ4MYFfFwUcD0MdAGjeqKojf4Jx8B1wAhwwwI%2BLuqYegBkgePAKq2Tot9AtEln744Bay7XaS0Are4wk6uBPmCl1gkByDsGMrLx%2B1L61Q3gBeBTt7axe9I5C1LgGcjIxo/nvcC%2BhQ6J1ACwWREmlWeLfNBVeELR5x0AA/czcKXzE6SjSQV6SQbiwLdAt9bNMu5zFZ5REXoAU6F5u4TTjcgfAvI78AuwVrprge%2BB1R7Aw0Leq7VV82mgX3%2BbXAGcd1G0J0Ik18foSoVply4MFFyA64ABpSUI5HEFNndW5NEo2c9LPNQT5fkS7IxBdqDCXRUY6wpxtgKZKGS/KNH6QJTV09D3P1hzqkznvRl2b2%2Bj8P4Qr8%2BGyB6ZoXlbhGwRfjA//RXuaIKJtSFOV6DD/BwuseX%2BKE8VYHcLZJuOZ3hr1zjbDqb5%2BAK0hGFm7xTd6yMM3hNj2HQxyO88zyMfpjkwDfEoFF6bZOPdGTZvbeOfE6McWgVju3Ls2J/ioyLEm6HwTp7udWGGt8YYsn3lWSq9OXr2p%2BbPCkHZWPgAeFr0GC1PAJ%2Bokls17ez5tWz2aRi9uCnOm70reKMzwgHR/6VsrPI3yHaD3h0FtgCvyGY7cMi64DfgXSnN6Bn1/IgrrE4Vk8lfug/ix/IcPFWkmCuzB/i/WhLZrtTwGmI%2B0gv6hjwqm6%2BA260I97g7/QRwq4omkBngGgfobytAa71ZOJcrz%2B1JCEBONsMKol0tbHIEeEyMomJ%2BuXoOmHIHMO50Z4FNYgod0uFG8bQuprTYCfZ0K/JAXgU%2Bc4Dm5FKTcEDtFki/qBvUekLRJsUGmg1Jl4JfgfuAM85PoYrZBQFUy0/69D7pGEi5uyCQtGPOANyifq8ptUZxIFbZz4pWXBGG3fVaUb6DFMyomA//l/PLYaCg/AUyrmj93mmNVl8777nOWRKAavlT94L/uLCauV7v6pLFABhXf09WgboZGFsOAEG%2BR53uDzEwuhwA0HQbdOszOrzuf1LCiwRg7fedi/icfj/W6%2BjfAAAA///cZAAN8LSlZAAAAABJRU5ErkJggg%3D%3D
