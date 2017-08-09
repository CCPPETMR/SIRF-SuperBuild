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
#These need to be unique globally
set(proj HDF5)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(HDF5_Install_Dir ${SUPERBUILD_INSTALL_DIR})

  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

  set(HDF5_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}-prefix/src/HDF5/hdf5-1.10.0-patch1 )

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${proj}
    CONFIGURE_COMMAND ${CMAKE_COMMAND}
                             ${CLANG_ARG}
                             -DCMAKE_INSTALL_PREFIX:PATH=${HDF5_Install_Dir} "${HDF5_SOURCE_DIR}"

    INSTALL_DIR ${HDF5_Install_Dir}
  )

  set( HDF5_ROOT ${HDF5_Install_Dir} )
  set( HDF5_INCLUDE_DIRS ${HDF5_ROOT}/include )

 else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
      message(STATUS "USING the system ${externalProjName}, found HDF5_INCLUDE_DIRS=${HDF5_INCLUDE_DIRS}, HDF5_C_LIBRARY_hdf5=${HDF5_C_LIBRARY_hdf5},HDF5_LIBRARIES=${HDF5_LIBRARIES}")
  endif()
  ExternalProject_Add_Empty(${proj} "${${proj}_DEPENDENCIES}")
endif()

mark_as_superbuild(
  VARS
    ${externalProjName}_DIR:PATH
  LABELS
    "FIND_PACKAGE"
)
