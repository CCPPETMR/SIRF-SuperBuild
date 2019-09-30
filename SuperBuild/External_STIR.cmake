#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Copyright 2017-2019 University College London
#
# This file is part of the CCP PETMR Synergistic Image Reconstruction Framework (SIRF) SuperBuild.
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

# Set dependency list
if (USE_ITK)
  set(${proj}_DEPENDENCIES "Boost;ITK")
else()
  set(${proj}_DEPENDENCIES "Boost")
endif()
if (BUILD_STIR_SWIG_PYTHON)
  list(APPEND ${proj}_DEPENDENCIES "SWIG")
endif()
  
# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

set(${proj}_SOURCE_DIR "${SOURCE_ROOT_DIR}/${proj}" )
set(${proj}_BINARY_DIR "${SUPERBUILD_WORK_DIR}/builds/${proj}/build" )
set(${proj}_DOWNLOAD_DIR "${SUPERBUILD_WORK_DIR}/downloads/${proj}" )
set(${proj}_STAMP_DIR "${SUPERBUILD_WORK_DIR}/builds/${proj}/stamp" )
set(${proj}_TMP_DIR "${SUPERBUILD_WORK_DIR}/builds/${proj}/tmp" )


if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(STIR_Install_Dir ${SUPERBUILD_INSTALL_DIR})

  option(BUILD_TESTING_${proj} "Build tests for ${proj}" OFF)
  if (APPLE)
    set (build_STIR_OPENMP_default OFF)
  else()
    set (build_STIR_OPENMP_default ON)
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
  option(STIR_ENABLE_EXPERIMENTAL "Enable STIR experimental code" OFF)
  
  mark_as_advanced(BUILD_STIR_EXECUTABLES BUILD_STIR_SWIG_PYTHON STIR_DISABLE_CERN_ROOT)
  mark_as_advanced(STIR_DISABLE_LLN_MATRIX STIR_ENABLE_EXPERIMENTAL)

  if(${STIR_BUILD_SWIG_PYTHON} AND NOT "${PYTHON_STRATEGY}" STREQUAL "PYTHONPATH")
    message(FATAL_ERROR "STIR Python currently needs to have PYTHON_STRATEGY=PYTHONPATH")
  endif()

  set(STIR_CMAKE_ARGS
        -DSWIG_EXECUTABLE=${SWIG_EXECUTABLE}
        -DBUILD_EXECUTABLES=${STIR_BUILD_EXECUTABLES}
        -DBUILD_SWIG_PYTHON=${STIR_BUILD_SWIG_PYTHON}
        -DPYTHON_DEST=${PYTHON_DEST}
        -DMatlab_ROOT_DIR=${Matlab_ROOT_DIR}
        -DMATLAB_DEST=${MATLAB_DEST}
        -DBUILD_TESTING=${BUILD_TESTING_${proj}}
        -DBUILD_DOCUMENTATION=OFF
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
        -DBOOST_ROOT=${BOOST_ROOT}
        -DCMAKE_INSTALL_PREFIX=${STIR_Install_Dir}
        -DGRAPHICS=None
        -DCMAKE_CXX_STANDARD=11
        -DSTIR_OPENMP=${STIR_ENABLE_OPENMP}
        # Use 2 variables for ROOT to cover multiple STIR versions
        -DDISABLE_CERN_ROOT_SUPPORT=${STIR_DISABLE_CERN_ROOT} -DDISABLE_CERN_ROOT=${STIR_DISABLE_CERN_ROOT}
        -DDISABLE_LLN_MATRIX=${STIR_DISABLE_LLN_MATRIX}
        -DSTIR_ENABLE_EXPERIMENTAL=${STIR_ENABLE_EXPERIMENTAL}
   )

  # Append CMAKE_ARGS for ITK choices
  # 3 choices: 
  #     1. !USE_ITK                     <- Disable ITK
  #     2.  USE_ITK &&  USE_SYSTEM_ITK  <- Need to set ITK_DIR, set with find_package in External_ITK.cmake
  #     3.  USE_ITK && !USE_SYSTEM_ITK  <- No need to do anything (ITK_DIR will get set during the installation of ITK)
  # STIR enables ITK by default (If it is found, so no need to set -DDISABLE_ITK=OFF for cases 2 and 3)
  if (!USE_ITK)
    set(STIR_CMAKE_ARGS ${STIR_CMAKE_ARGS} -DDISABLE_ITK=ON)
  elseif (USE_ITK AND USE_SYSTEM_ITK)
    set(STIR_CMAKE_ARGS ${STIR_CMAKE_ARGS} -DITK_DIR=${ITK_DIR})
  endif()

  # Sets ${proj}_URL_MODIFIED and ${proj}_TAG_MODIFIED
  SetGitTagAndRepo("${proj}")
  
  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY "${${proj}_URL_MODIFIED}"
    GIT_TAG "${${proj}_TAG_MODIFIED}"
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${${proj}_BINARY_DIR}
    DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
    STAMP_DIR ${${proj}_STAMP_DIR}
    TMP_DIR ${${proj}_TMP_DIR}
	
    CMAKE_ARGS ${STIR_CMAKE_ARGS}
    INSTALL_DIR ${STIR_Install_Dir}
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

  set(STIR_ROOT       ${STIR_Install_Dir})
  set(STIR_DIR       ${SUPERBUILD_INSTALL_DIR}/lib/cmake)
  set(STIR_INCLUDE_DIRS ${STIR_ROOT}/stir)

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
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${${proj}_BINARY_DIR}
    DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
    STAMP_DIR ${${proj}_STAMP_DIR}
    TMP_DIR ${${proj}_TMP_DIR}
   )
  endif()

  mark_as_superbuild(
    VARS
      ${externalProjName}_DIR:PATH
    LABELS
      "FIND_PACKAGE"
  )
