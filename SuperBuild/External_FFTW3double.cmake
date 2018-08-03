#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Author: Edoardo Pasca
# Copyright 2017 University College London
# Copyright 2017 STFC
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
set(proj FFTW3double)
set(proj_COMPONENTS "COMPONENTS double")
# Set dependency list
if (WIN32)
  # rely on the "single" version to install everything
  set(${proj}_DEPENDENCIES "FFTW3")
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

# use FFTW variable
if(NOT ( DEFINED "USE_SYSTEM_FFTW3" AND "${USE_SYSTEM_FFTW3}" ) )
  if (WIN32)
    # don't do anything
    ExternalProject_Add_Empty(${proj})
    return()
  endif()
    
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(FFTWdouble_Install_Dir ${SUPERBUILD_INSTALL_DIR})
  set(FFTWdouble_Configure_Script ${CMAKE_CURRENT_LIST_DIR}/External_FFTWdouble_configure.cmake)
  set(FFTWdouble_Build_Script ${CMAKE_CURRENT_LIST_DIR}/External_FFTWdouble_build.cmake)


  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

  #set(FFTWdouble_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj} )
  
  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_MD5 ${${proj}_MD5}
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${${proj}_BINARY_DIR}
    DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
    STAMP_DIR ${${proj}_STAMP_DIR}
    TMP_DIR ${${proj}_TMP_DIR}
    CONFIGURE_COMMAND ${${proj}_SOURCE_DIR}/configure --with-pic --prefix ${FFTWdouble_Install_Dir}
    INSTALL_DIR ${FFTWdouble_Install_Dir}
  )

  set( FFTW3_ROOT_DIR ${FFTWdouble_Install_Dir} )


 else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} ${${externalProjName}_COMPONENTS} REQUIRED)
      message(STATUS "USING the system ${externalProjName}, found FFTW3double_INCLUDE_DIR=${FFTW3double_INCLUDE_DIR}, FFTW3double_LIBRARY=${FFTW3double_LIBRARY}")
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
