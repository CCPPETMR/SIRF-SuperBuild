#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Copyright 2017, 2020 University College London
#
# This file is part of the CCP SyneRBI (formerly PETMR) Synergistic Image Reconstruction Framework (SIRF) SuperBuild.
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

#This needs to be unique globally
set(proj STIR)

# Set external name (same as internal for now)
set(externalProjName ${proj})

SetCanonicalDirectoryNames(${proj})
# Get any flag from the superbuild call that may be particular to this projects CMAKE_ARGS
SetExternalProjectFlags(${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here

  option(BUILD_TESTING_${proj} "Build tests for ${proj}" OFF)
  if (NOT DISABLE_OpenMP)
    set (build_STIR_OPENMP_default ON)
  else()
    set (build_STIR_OPENMP_default OFF)
  endif()
  RenameVariable(BUILD_STIR_WITH_OPENMP STIR_ENABLE_OPENMP build_STIR_OPENMP_default)
  option(STIR_ENABLE_OPENMP "Build STIR with OpenMP acceleration" ${build_STIR_OPENMP_default})
  set(default_STIR_BUILD_EXECUTABLES OFF)
  RenameVariable(BUILD_STIR_EXECUTABLES STIR_BUILD_EXECUTABLES default_STIR_BUILD_EXECUTABLES)
  option(STIR_BUILD_EXECUTABLES "Build all STIR executables" ${default_STIR_BUILD_EXECUTABLES})
  set(default_STIR_BUILD_SWIG_PYTHON OFF)
  RenameVariable(BUILD_STIR_SWIG_PYTHON STIR_BUILD_SWIG_PYTHON default_STIR_BUILD_SWIG_PYTHON)
  option(STIR_BUILD_SWIG_PYTHON "Build STIR Python interface" ${default_STIR_BUILD_SWIG_PYTHON})
  option(STIR_DISABLE_CERN_ROOT "Disable STIR ROOT interface" ON)
  option(STIR_DISABLE_LLN_MATRIX "Disable STIR Louvain-la-Neuve Matrix library for ECAT7 support" ON)
  option(STIR_DISABLE_HDF5 "Disable STIR use of HDF5 libraries (and hence GE Raw Data support)" OFF)
  option(STIR_ENABLE_EXPERIMENTAL "Enable STIR experimental code" OFF)

  mark_as_advanced(BUILD_STIR_EXECUTABLES BUILD_STIR_SWIG_PYTHON STIR_DISABLE_CERN_ROOT)
  mark_as_advanced(STIR_DISABLE_LLN_MATRIX STIR_ENABLE_EXPERIMENTAL)

  if(${STIR_BUILD_SWIG_PYTHON} AND NOT "${PYTHON_STRATEGY}" STREQUAL "PYTHONPATH")
    message(FATAL_ERROR "STIR Python currently needs to have PYTHON_STRATEGY=PYTHONPATH")
  endif()

  # Set dependency list
  set(${proj}_DEPENDENCIES "Boost")
  if (USE_ITK)
    list(APPEND ${proj}_DEPENDENCIES "ITK")
  endif()
  if (STIR_BUILD_SWIG_PYTHON)
    list(APPEND ${proj}_DEPENDENCIES "SWIG")
  endif()
  if (USE_NiftyPET)
    list(APPEND ${proj}_DEPENDENCIES "NiftyPET")
  endif()
  if (USE_parallelproj)
    list(APPEND ${proj}_DEPENDENCIES "parallelproj")
  endif()
  option(STIR_DISABLE_JSON "Disable JSON support in ${proj}" OFF)
  if (NOT STIR_DISABLE_JSON)
    list(APPEND ${proj}_DEPENDENCIES "JSON")
  endif()
  if (NOT STIR_DISABLE_HDF5)
    list(APPEND ${proj}_DEPENDENCIES "HDF5")
  endif()
  # Include dependent projects if any
  ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

  set(STIR_CMAKE_ARGS
    
    -DSWIG_EXECUTABLE:FILEPATH=${SWIG_EXECUTABLE}
    -DBUILD_EXECUTABLES:BOOL=${STIR_BUILD_EXECUTABLES}
    -DBUILD_SWIG_PYTHON:BOOL=${STIR_BUILD_SWIG_PYTHON}
    -DPYTHON_DEST:PATH=${PYTHON_DEST}
    ${PYTHONLIBS_CMAKE_ARGS}
    -DMatlab_ROOT_DIR:PATH=${Matlab_ROOT_DIR}
    -DMATLAB_DEST:PATH=${MATLAB_DEST}
    -DBUILD_TESTING:BOOL=${BUILD_TESTING_${proj}}
    -DBUILD_DOCUMENTATION:BOOL=OFF
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
    -DCMAKE_INSTALL_PREFIX:PATH=${STIR_INSTALL_DIR}
    -DGRAPHICS:STRING=None
    -DCMAKE_CXX_STANDARD:STRING=11
    -DSTIR_OPENMP:BOOL=${STIR_ENABLE_OPENMP}
    -DOPENMP_INCLUDES:PATH=${OPENMP_INCLUDES}
    -DOPENMP_LIBRARIES:PATH=${OPENMP_LIBRARIES}
    # Use 2 variables for ROOT to cover multiple STIR versions
    -DDISABLE_CERN_ROOT_SUPPORT:BOOL=${STIR_DISABLE_CERN_ROOT} -DDISABLE_CERN_ROOT:BOOL=${STIR_DISABLE_CERN_ROOT}
    -DDISABLE_HDF5:BOOL=${STIR_DISABLE_HDF5}
    -DDISABLE_LLN_MATRIX:BOOL=${STIR_DISABLE_LLN_MATRIX}
    -DSTIR_ENABLE_EXPERIMENTAL:BOOL=${STIR_ENABLE_EXPERIMENTAL}
    -DDISABLE_NLOHMANN_JSON:BOOL=${STIR_DISABLE_JSON}
   )

  # Append CMAKE_ARGS for ITK choices
  # 3 choices:
  #     1.  NOT USE_ITK                 <- Disable ITK
  #     2.  USE_ITK &&  USE_SYSTEM_ITK  <- Need to set ITK_DIR, set with find_package in External_ITK.cmake
  #     3.  USE_ITK && !USE_SYSTEM_ITK  <- No need to do anything (ITK_DIR will get set during the installation of ITK)
  # STIR enables ITK by default (If it is found, so no need to set -DDISABLE_ITK=OFF for cases 2 and 3)
  if (NOT USE_ITK) 
    set(STIR_CMAKE_ARGS ${STIR_CMAKE_ARGS} -DDISABLE_ITK:BOOL=ON)
  else()
    set(STIR_CMAKE_ARGS ${STIR_CMAKE_ARGS} -DDISABLE_ITK:BOOL=OFF)
    if (USE_SYSTEM_ITK)
      set(STIR_CMAKE_ARGS ${STIR_CMAKE_ARGS} -DITK_DIR:PATH=${ITK_DIR})
    endif()
  endif()

  ## If building with NiftyPET projector
  if (${USE_NiftyPET})
    set(STIR_CMAKE_ARGS ${STIR_CMAKE_ARGS} -DNiftyPET_PATH:PATH=${NiftyPET_PATH})
  endif()

  # Sets ${proj}_URL_MODIFIED and ${proj}_TAG_MODIFIED
  SetGitTagAndRepo("${proj}")

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    ${${proj}_EP_ARGS_GIT}
    ${${proj}_EP_ARGS_DIRS}
    CMAKE_ARGS
       ${STIR_CMAKE_ARGS}
       ${Boost_CMAKE_ARGS}
       ${HDF5_CMAKE_ARGS}
       ${${proj}_EXTRA_CMAKE_ARGS_LIST}
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

  set(STIR_DIR       ${SUPERBUILD_INSTALL_DIR}/lib/cmake)


  if (BUILD_TESTING_${proj})
    add_test(NAME ${proj}_TESTS
         COMMAND ${CMAKE_CTEST_COMMAND} -C $<CONFIGURATION> --output-on-failure
         WORKING_DIRECTORY ${${proj}_BINARY_DIR})
  endif()

   else()
      if(${USE_SYSTEM_${externalProjName}})
        find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
        message(STATUS "USING the system ${externalProjName}, set ${externalProjName}_DIR=${${externalProjName}_DIR}")
   endif()
    ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
    ${${proj}_EP_ARGS_DIRS}
   )
  endif()

  mark_as_superbuild(
    VARS
      ${externalProjName}_DIR:PATH
    LABELS
      "FIND_PACKAGE"
  )
