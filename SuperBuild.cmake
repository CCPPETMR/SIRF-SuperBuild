#========================================================================
# Author: Benjamin A Thomas
# Author: Edoardo Pasca
# Author: Casper da Costa-Luis
# Author: Kris Thielemans
# Copyright 2017-2021 University College London
# Copyright 2017-2020 Science Technology Facilities Council
#
# This file is part of the CCP SyneRBI Synergistic Image Reconstruction Framework (SIRF) SuperBuild.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#=========================================================================
if (WIN32)
 # used to check for CMAKE_GENERATOR_PLATFORM but that no longer works in 3.10
 if(NOT "x_${CMAKE_VS_PLATFORM_NAME}" STREQUAL "x_x64")
    message(STATUS "CMAKE_GENERATOR: ${CMAKE_GENERATOR}")
    message(STATUS "CMAKE_GENERATOR_PLATFORM: ${CMAKE_GENERATOR_PLATFORM}")
    message(STATUS "CMAKE_VS_PLATFORM_NAME: ${CMAKE_VS_PLATFORM_NAME}")
    message( FATAL_ERROR "The SuperBuild currently has Win64 hard-wired for dependent libraries. Please use a Win64 generator/toolset. Currently using platform '${CMAKE_VS_PLATFORM_NAME}'.")
 endif()
endif()

set(SUPERBUILD_WORK_DIR ${CMAKE_CURRENT_BINARY_DIR} CACHE PATH
    "The path for downloading external source directories" )
set(SOURCE_ROOT_DIR "${CMAKE_CURRENT_BINARY_DIR}/sources/"  CACHE PATH "blabla")

mark_as_advanced( SOURCE_DOWNLOAD_CACHE )

set(externalProjName ${PRIMARY_PROJECT_NAME})
set(proj ${PRIMARY_PROJECT_NAME})

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/INSTALL" CACHE PATH "Prefix for path for installation" FORCE)
endif()

# Find CUDA
option(DISABLE_CUDA "Disable CUDA" OFF)
if (NOT DISABLE_CUDA)
  find_package(CUDA)
endif()
if (NOT DISABLE_CUDA AND CUDA_FOUND)
  message(STATUS "<<<<<<<<<<<<<<<<< CUDA FOUND >>>>>>>>>>>>>>>>>>>>>")
  message(STATUS "Will enable CUDA dependencies where possible.")
  set(USE_CUDA ON CACHE INTERNAL "Use CUDA")
else()
  set(USE_CUDA OFF CACHE INTERNAL "Use CUDA" FORCE)
endif()

# If OSX give the advanced option to use absolute paths for shared libraries
if (APPLE)
  option(SHARED_LIBS_ABS_PATH "Force shared libraries to be installed with absolute paths (as opposed to rpaths)" ON)
  mark_as_advanced( SHARED_LIBS_ABS_PATH )
  if (SHARED_LIBS_ABS_PATH)
    # Set install_name_dir as the absolute path to install_prefix/lib
    GET_FILENAME_COMPONENT(CMAKE_INSTALL_NAME_DIR ${CMAKE_INSTALL_PREFIX}/lib REALPATH)
    # Mark it as superbuild so that it gets passed to all dependencies
    mark_as_superbuild( ALL_PROJECTS VARS CMAKE_INSTALL_NAME_DIR:PATH )
  endif(SHARED_LIBS_ABS_PATH)
endif(APPLE)

set (SUPERBUILD_INSTALL_DIR ${CMAKE_INSTALL_PREFIX})

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING
      "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
      FORCE)
endif()

include(ExternalProject)

# Make sure that some CMake variables are passed to all dependencies
mark_as_superbuild(
   ALL_PROJECTS
   VARS CMAKE_GENERATOR:STRING CMAKE_GENERATOR_PLATFORM:STRING CMAKE_GENERATOR_TOOLSET:STRING
        CMAKE_C_COMPILER:FILEPATH CMAKE_CXX_COMPILER:FILEPATH
        CMAKE_INSTALL_PREFIX:PATH
        CMAKE_BUILD_TYPE:STRING
)

#### Python support

option(DISABLE_PYTHON "Disable building SIRF python support" OFF)
if (DISABLE_PYTHON)
  message(STATUS "Python support disabled")
else()

  # Attempt to make Python settings consistent
  set(PYVER 0 CACHE STRING "Python version")
  if(PYVER EQUAL 0)
    find_package(PythonInterp)
  else()
    find_package(PythonInterp ${PYVER})
  endif()
  if (PYTHONINTERP_FOUND)
    set(Python_ADDITIONAL_VERSIONS ${PYTHON_VERSION_STRING})
    message(STATUS "Found PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}")
    message(STATUS "Python version ${PYTHON_VERSION_STRING}")
  endif()
  # find_package(PythonLibs ${PYTHON_VERSION_STRING})
  if(PYVER EQUAL 0)
    find_package(PythonLibs)
  else()
    find_package(PythonLibs ${PYVER})
  endif()
  if (PYTHONLIBS_FOUND)
    message(STATUS "Found PYTHON_INCLUDE_DIRS=${PYTHON_INCLUDE_DIRS}")
    message(STATUS "Found PYTHON_LIBRARIES=${PYTHON_LIBRARIES}")
  endif()

  # Set destinations for Python files
  set (BUILD_PYTHON ${PYTHONLIBS_FOUND})
  if (BUILD_PYTHON)
    set(PYTHON_DEST_DIR "" CACHE PATH "Directory of the SIRF and/or STIR Python modules")
    if (PYTHON_DEST_DIR)
     set(PYTHON_DEST "${PYTHON_DEST_DIR}")
    else()
      set(PYTHON_DEST "${CMAKE_INSTALL_PREFIX}/python")
    endif()
    message(STATUS "Python libraries found")
    message(STATUS "SIRF and/or STIR Python modules will be installed in " ${PYTHON_DEST})

    set(PYTHON_STRATEGY "PYTHONPATH" CACHE STRING "\
      PYTHONPATH: prefix PYTHONPATH \n\
      SETUP_PY:   execute ${PYTHON_EXECUTABLE} setup.py install \n\
      CONDA:      do nothing")
    set_property(CACHE PYTHON_STRATEGY PROPERTY STRINGS PYTHONPATH SETUP_PY CONDA)
  endif()

  # set PYTHONLIBS_CMAKE_ARGS to be used in the ExternalProject_add calls
  # note: Find_package(PythonLibs) takes PYTHON_INCLUDE_DIR and PYTHON_LIBRARY as input
  set (PYTHONLIBS_CMAKE_ARGS -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE})
  if (EXISTS "${PYTHON_INCLUDE_DIR}")
    set (PYTHONLIBS_CMAKE_ARGS ${PYTHONLIBS_CMAKE_ARGS}
      -DPYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR})
  endif()
  if (EXISTS "${PYTHON_LIBRARY}")
    set (PYTHONLIBS_CMAKE_ARGS ${PYTHONLIBS_CMAKE_ARGS}
      -DPYTHON_LIBRARY:FILEPATH=${PYTHON_LIBRARY})
  endif()


  message(STATUS "PYTHONLIBS_CMAKE_ARGS= " "${PYTHONLIBS_CMAKE_ARGS}")
endif()

#### MATLAB support
option(DISABLE_Matlab "Disable building MATLAB support" OFF)
if (DISABLE_Matlab)
  message(STATUS "Matlab support disabled")
else()
  # Find Matlab
  set(Matlab_ROOT_DIR $ENV{Matlab_ROOT_DIR} CACHE PATH "Path to Matlab root directory" )
  # Note that we need the main program for the configuration files and the tests)
  find_package(Matlab COMPONENTS MAIN_PROGRAM)


  set (BUILD_MATLAB ${Matlab_FOUND})
  if (BUILD_MATLAB)
    set(MATLAB_DEST_DIR "" CACHE PATH "Directory of the SIRF and/or STIR Matlab libraries")
    if (MATLAB_DEST_DIR)
      set(MATLAB_DEST "${MATLAB_DEST_DIR}")
    else()
      set(MATLAB_DEST "${CMAKE_INSTALL_PREFIX}/matlab")
    endif()
    message(STATUS "Matlab libraries found")
    message(STATUS "SIRF and/or STIR Matlab libraries will be installed in " ${MATLAB_DEST})
  endif()
endif()

# Include macro to sets ${proj}_URL_MODIFIED and ${proj}_TAG_MODIFIED
# If the user doesn't want git checkout to be performed, 
# these will be set to blank strings. Else, they'll be set to 
# ${${proj}_URL} and ${${proj}_TAG}, respectively.
include(${CMAKE_SOURCE_DIR}/CMake/SetGitTagAndRepo.cmake)
# Include macro to set SOURCE_DIR etc
include(${CMAKE_SOURCE_DIR}/CMake/SetCanonicalDirectoryNames.cmake)
# Include macro to be able to pass flags to project CMAKEs
include(${CMAKE_SOURCE_DIR}/CMake/SetExternalProjectFlags.cmake)

if (UNIX AND NOT APPLE)
  option(USE_SYSTEM_Boost "Build using an external version of Boost" OFF)
else()
  option(USE_SYSTEM_Boost "Build using an external version of Boost" ON)
endif()
option(USE_SYSTEM_STIR "Build using an external version of STIR" OFF)
option(USE_SYSTEM_HDF5 "Build using an external version of HDF5" OFF)
option(USE_SYSTEM_ISMRMRD "Build using an external version of ISMRMRD" OFF)
option(USE_SYSTEM_siemens_to_ismrmrd "Build using an external version of siemens_to_ismrmrd" OFF)
option(USE_SYSTEM_FFTW3 "Build using an external version of fftw" OFF)
option(USE_SYSTEM_Armadillo "Build using an external version of Armadillo" OFF)
option(USE_SYSTEM_SWIG "Build using an external version of SWIG" OFF)
#option(USE_SYSTEM_Gadgetron "Build using an external version of Gadgetron" OFF)
option(USE_SYSTEM_SIRF "Build using an external version of SIRF" OFF)
option(USE_SYSTEM_NIFTYREG "Build using an external version of NIFTYREG" OFF)
option(USE_SYSTEM_GTest "Build using an external version of GTest" OFF)
option(USE_SYSTEM_ACE "Build using an external version of ACE" ON)

# SPM requires matlab
if (BUILD_MATLAB)
  option(USE_SYSTEM_SPM "Build using an external version of SPM. Only SPM12 tested." OFF)
  option(BUILD_SPM "Build SPM. Only SPM12 tested" ON)
ENDIF()

if (WIN32)
  set(build_Gadgetron_default OFF)
else()
  set(build_Gadgetron_default ON)
endif()

include (RenameVariable)

RenameVariable(BUILD_GADGETRON BUILD_Gadgetron build_Gadgetron_default)

# OpenMP support
option(DISABLE_OpenMP "Disable OpenMP support for dependencies" OFF)
if (NOT DISABLE_OpenMP)
  find_package(OpenMP)
  if (OPENMP_FOUND)
    MESSAGE(STATUS "OpenMP found, support enabled")
    mark_as_superbuild(ALL_PROJECTS VARS 
      OpenMP_CXX_FLAGS:STRING OpenMP_CXX_LIB_NAMES:STRING OpenMP_C_FLAGS:STRING 
      OpenMP_C_LIB_NAMES:STRING OpenMP_CXX_FLAGS:STRING OpenMP_CXX_LIB_NAMES:STRING 
      OpenMP_libomp_LIBRARY:FILEPATH OpenMP_omp_LIBRARY:FILEPATH
      OpenMP_gomp_LIBRARY:FILEPATH OpenMP_pthread_LIBRARY:FILEPATH
      OPENMP_INCLUDES:PATH OPENMP_LIBRARIES:PATH
      )
  else()
    MESSAGE(STATUS "OpenMP not found, support disabled")
    SET(DISABLE_OpenMP ON CACHE BOOL "Disable OpenMP support for dependencies" FORCE)
  endif()
endif()

option(BUILD_SIRF "Build SIRF" ON)
option(BUILD_STIR "Build STIR" ON)
option(BUILD_Gadgetron "Build Gadgetron" ${build_Gadgetron_default})
option(BUILD_siemens_to_ismrmrd "Build siemens_to_ismrmrd" OFF)
option(BUILD_pet_rd_tools "Build pet_rd_tools" OFF)
option(BUILD_CIL "Build CCPi CIL Modules and ASTRA engine" OFF)
option(BUILD_CIL_LITE "Build CCPi CIL Modules" OFF)
option(BUILD_NIFTYREG "Build NIFTYREG" ON)
option(BUILD_SIRF_Contribs "Build SIRF-Contribs" ${BUILD_SIRF})
option(BUILD_SIRF_Registration "Build SIRFS's registration functionality" ${BUILD_NIFTYREG})
if (BUILD_SIRF AND BUILD_SIRF_Registration AND NOT BUILD_NIFTYREG)
  message(WARNING "Building SIRF registration is enabled, but BUILD_NIFTYREG=OFF. Reverting to BUILD_NIFTYREG=ON")
  set(BUILD_NIFTYREG ON CACHE BOOL "Build NIFTYREG" FORCE)
endif()

if (BUILD_pet_rd_tools)
    set(USE_ITK ON CACHE BOOL "Use ITK" FORCE)
    option(USE_SYSTEM_glog "Build using an external version of glog" OFF)
endif()

# ITK
option(USE_ITK "Use ITK" ON)
if (USE_ITK)
  option(USE_SYSTEM_ITK "Build using an external version of ITK" OFF)
endif()

# If building STIR and CUDA present, offer to build NiftyPET
if (USE_CUDA AND NOT USE_SYSTEM_STIR)
  set(USE_NiftyPET OFF CACHE BOOL "Build STIR with NiftyPET's projectors") # FORCE)
  if (USE_NiftyPET)
    option(USE_SYSTEM_NiftyPET "Build using an external version of NiftyPET" OFF)
  endif()
else()
  set(USE_NiftyPET OFF CACHE BOOL "Build STIR with NiftyPET's projectors" FORCE)
endif()

# parallelproj
set(USE_parallelproj ON CACHE BOOL "Build STIR with parallelproj's projectors") # FORCE)
if (USE_parallelproj)
  option(USE_SYSTEM_parallelproj "Build using an external version of parallelproj" OFF)
endif()

## set versions
include(version_config.cmake)

## build list of dependencies, based on options above
# first set to empty
set(${PRIMARY_PROJECT_NAME}_DEPENDENCIES)

if (BUILD_SIRF)
  list(APPEND ${PRIMARY_PROJECT_NAME}_DEPENDENCIES SIRF)
endif()

if (BUILD_STIR)
  list(APPEND ${PRIMARY_PROJECT_NAME}_DEPENDENCIES STIR)
endif()

if (BUILD_Gadgetron)
  list(APPEND ${PRIMARY_PROJECT_NAME}_DEPENDENCIES Gadgetron)
  set(Armadillo_REQUIRED_VERSION 4.600)
endif()

if (BUILD_siemens_to_ismrmrd)
  list(APPEND ${PRIMARY_PROJECT_NAME}_DEPENDENCIES siemens_to_ismrmrd)
endif()

if (BUILD_pet_rd_tools)
  list(APPEND ${PRIMARY_PROJECT_NAME}_DEPENDENCIES pet_rd_tools)
endif()

if ("${PYTHON_STRATEGY}" STREQUAL "CONDA")
  set (BUILD_CIL OFF)
endif()
if (BUILD_CIL)
  list(APPEND ${PRIMARY_PROJECT_NAME}_DEPENDENCIES CIL CIL-ASTRA CCPi-Regularisation-Toolkit TomoPhantom)
endif()
if (BUILD_CIL_LITE)
  list(APPEND ${PRIMARY_PROJECT_NAME}_DEPENDENCIES CIL CCPi-Regularisation-Toolkit)
endif()

if (BUILD_SIRF_Registration AND BUILD_SIRF)
  list(APPEND ${PRIMARY_PROJECT_NAME}_DEPENDENCIES NIFTYREG)
endif()

if (BUILD_SIRF_Contribs)
  list(APPEND ${PRIMARY_PROJECT_NAME}_DEPENDENCIES SIRF-Contribs)
endif()

ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${PRIMARY_PROJECT_NAME}_DEPENDENCIES)

message(STATUS "")
message(STATUS "Boost_CMAKE_ARGS= " "${Boost_CMAKE_ARGS}")
message(STATUS "ISMRMRD_DIR = " ${ISMRMRD_DIR})
message(STATUS "STIR_DIR = " ${STIR_DIR})
message(STATUS "GTEST_ROOT = " ${GTEST_ROOT})
message(STATUS "Matlab_ROOT_DIR = " ${Matlab_ROOT_DIR})

#Need to configure main project here.
#set(proj ${PRIMARY_PROJECT_NAME})

# Make environment files
set(SyneRBI_INSTALL ${SUPERBUILD_INSTALL_DIR})

## configure the environment files env_ccppetmr.sh/csh
## We create a whole bash/csh block script which does set the appropriate
## environment variables for Python and Matlab.
## in the env_ccppetmr scripts we perform a substitution of the whole block
## during the configure_file() command call below.

if (BUILD_SPM AND NOT DISABLE_MATLAB AND Matlab_ROOT_DIR AND "${CMAKE_SYSTEM}" MATCHES "Linux")
  set(Matlab_extra_ld_path ":${Matlab_ROOT_DIR}/extern/bin/glnxa64")
endif()

set(ENV_PYTHON_BASH "#####    Python not found    #####")
set(ENV_PYTHON_CSH  "#####    Python not found    #####")
if(PYTHONINTERP_FOUND)
  if("${PYTHON_STRATEGY}" STREQUAL "PYTHONPATH")
    set(COMMENT_OUT_PREFIX "")
  else()
    set(COMMENT_OUT_PREFIX "#")
  endif()

  set (ENV_PYTHON_CSH "\
    ${COMMENT_OUT_PREFIX}if $?PYTHONPATH then \n\
    ${COMMENT_OUT_PREFIX}  setenv PYTHONPATH ${PYTHON_DEST}:$PYTHONPATH \n\
    ${COMMENT_OUT_PREFIX}else \n\
    ${COMMENT_OUT_PREFIX}  setenv PYTHONPATH ${PYTHON_DEST} \n\
    setenv SIRF_PYTHON_EXECUTABLE ${PYTHON_EXECUTABLE} \n\
    ${COMMENT_OUT_PREFIX}endif")

  set (ENV_PYTHON_BASH "\
    ${COMMENT_OUT_PREFIX}export PYTHONPATH=\"${PYTHON_DEST}\${PYTHONPATH:+:\${PYTHONPATH}}\" \n\
    export SIRF_PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}")
endif()

set(ENV_MATLAB_BASH "#####     Matlab not found     #####")
set(ENV_MATLAB_CSH  "#####     Matlab not found     #####")
if (Matlab_FOUND)
  set(ENV_MATLAB_BASH "\
  MATLABPATH=${MATLAB_DEST}:${SPM_DIR}\n\
export MATLABPATH\n\
SIRF_MATLAB_EXECUTABLE=${Matlab_MAIN_PROGRAM}\n\
export SIRF_MATLAB_EXECUTABLE")
  set(ENV_MATLAB_CSH "\
   if $?MATLABPATH then\n\
     setenv MATLABPATH ${MATLAB_DEST}:$MATLABPATH\n\
   else\n\
     setenv MATLABPATH ${MATLAB_DEST}\n\
   endif\n\
   setenv SIRF_MATLAB_EXECUTABLE ${Matlab_MAIN_PROGRAM}")
endif()

# set GADGETRON_HOME if Gadgetron is built
if (BUILD_GADGETRON)

  set(ENV_GADGETRON_HOME_SH "\
GADGETRON_HOME=${SyneRBI_INSTALL}\n\
export GADGETRON_HOME\n")
  set(ENV_GADGETRON_HOME_CSH "setenv GADGETRON_HOME ${SyneRBI_INSTALL}\n")
endif()

configure_file(env_sirf.sh.in ${SyneRBI_INSTALL}/bin/env_sirf.sh)
configure_file(env_sirf.csh.in ${SyneRBI_INSTALL}/bin/env_sirf.csh)

if (${CMAKE_VERSION} VERSION_LESS "3.14" OR WIN32)
  # CREATE_LINK has been introduced in CMake 3.14
  # we create a copy instead.
  configure_file(env_sirf.sh.in ${SyneRBI_INSTALL}/bin/env_ccppetmr.sh)
  configure_file(env_sirf.csh.in ${SyneRBI_INSTALL}/bin/env_ccppetmr.csh)
else ()
  file(CREATE_LINK ${SyneRBI_INSTALL}/bin/env_sirf.sh ${SyneRBI_INSTALL}/bin/env_ccppetmr.sh SYMBOLIC)
  file(CREATE_LINK ${SyneRBI_INSTALL}/bin/env_sirf.csh ${SyneRBI_INSTALL}/bin/env_ccppetmr.csh SYMBOLIC)
endif()

# Install python packages via pip and setup.py
if(PYTHONINTERP_FOUND)
  set(PYTHON_SETUP_PKGS "sirf" CACHE INTERNAL "list of provided python packages")

  # alias sirf.p* -> p* for backward-compatibility
  function(python_pkg_alias PY_PKG_NEW PY_PKG_OLD)
    list(APPEND PYTHON_SETUP_PKGS ${PY_PKG_NEW})
    set(PYTHON_SETUP_PKGS "${PYTHON_SETUP_PKGS}" PARENT_SCOPE)
    set(SETUP_PY_INIT_IN "${CMAKE_CURRENT_SOURCE_DIR}/SuperBuild/__init__.py.in")
    set(SETUP_PY_INIT "${PYTHON_DEST}/${PY_PKG_NEW}/__init__.py")
    configure_file("${SETUP_PY_INIT_IN}" "${SETUP_PY_INIT}")
    # message(STATUS "setup.py:${SETUP_PY_INIT}")
    message(STATUS "setup.py:${PY_PKG_NEW}<-${PY_PKG_OLD}")
  endfunction(python_pkg_alias)
  python_pkg_alias(pGadgetron "sirf.pGadgetron")
  python_pkg_alias(pSTIR "sirf.pSTIR")
  python_pkg_alias(pUtilities "sirf.pUtilities")
  python_pkg_alias(pygadgetron "sirf.pygadgetron")
  python_pkg_alias(pystir "sirf.pystir")
  python_pkg_alias(pyiutilities "sirf.pyiutilities")
  # convert to python CSV tuple for setup.py configure_file
  string(REPLACE ";" "', '" PYTHON_SETUP_PKGS_CSV "${PYTHON_SETUP_PKGS}")
  set(PYTHON_SETUP_PKGS_CSV "'${PYTHON_SETUP_PKGS_CSV}'")
  # message(STATUS "setup.py:pacakges:${PYTHON_SETUP_PKGS_CSV}")

  # Create setup.py
  set(SETUP_PY_IN "${CMAKE_CURRENT_SOURCE_DIR}/SuperBuild/setup.py.in")
  set(SETUP_PY "${PYTHON_DEST}/setup.py")
  set(SETUP_PY_INIT "${PYTHON_DEST}/sirf/__init__.py")
  message(STATUS "setup.py:${SETUP_PY}")
  configure_file("${SETUP_PY_IN}" "${SETUP_PY}")

  # python setup.py build
  add_custom_command(OUTPUT "${SETUP_PY_INIT}"
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${PYTHON_DEST}/sirf"
    COMMAND "${CMAKE_COMMAND}" -E touch "${SETUP_PY_INIT}"
    COMMAND "${PYTHON_EXECUTABLE}" setup.py build
    DEPENDS "${SETUP_PY_IN}"
    WORKING_DIRECTORY "${PYTHON_DEST}")

  add_custom_target(pybuild_sirf ALL DEPENDS ${SETUP_PY_INIT})

  if (NOT CONDA_BUILD)
    # python setup.py install
    install(CODE "execute_process(COMMAND\n\
      \"${PYTHON_EXECUTABLE}\" setup.py install\n\
      WORKING_DIRECTORY \"${PYTHON_DEST}\")")
  endif()
endif(PYTHONINTERP_FOUND)


# add tests
enable_testing()
