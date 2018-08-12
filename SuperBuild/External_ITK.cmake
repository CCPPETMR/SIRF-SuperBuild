#========================================================================
# Author: Richard Brown
# Author: Benjamin A Thomas
# Author: Kris Thielemans
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
set(proj ITK)

# Set dependency list
set(${proj}_DEPENDENCIES "HDF5")

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
  set(${proj}_Install_Dir ${SUPERBUILD_INSTALL_DIR})

  #message(STATUS "HDF5_ROOT in External_SIRF: " ${HDF5_ROOT})
  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${SUPERBUILD_INSTALL_DIR})
  set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${SUPERBUILD_INSTALL_DIR})
  
  
  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY ${${proj}_URL}
    GIT_TAG ${${proj}_TAG}
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${${proj}_BINARY_DIR}
    DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
    STAMP_DIR ${${proj}_STAMP_DIR}
    TMP_DIR ${${proj}_TMP_DIR}
	
    CMAKE_ARGS
      -DCMAKE_PREFIX_PATH=${SUPERBUILD_INSTALL_DIR}
      -DCMAKE_LIBRARY_PATH=${SUPERBUILD_INSTALL_DIR}/lib
      -DCMAKE_INCLUDE_PATH=${SUPERBUILD_INSTALL_DIR}
      -DCMAKE_INSTALL_PREFIX=${${proj}_Install_Dir}
	    -DBUILD_SHARED_LIBS=ON
      -DCMAKE_BUILD_TYPE=${EXTERNAL_PROJECT_BUILD_TYPE}
      -DHDF5_ROOT=${HDF5_ROOT}
      -DHDF5_INCLUDE_DIRS=${HDF5_INCLUDE_DIRS}
      -DHDF5_LIBRARIES=${HDF5_LIBRARIES}
      -DITK_USE_SYSTEM_HDF5=ON
      -DBUILD_TESTING=OFF
      -DBUILD_EXAMPLES=OFF
	  INSTALL_DIR ${${proj}_Install_Dir}
    DEPENDS ${${proj}_DEPENDENCIES}
  )

  set(${proj}_INCLUDE_DIR ${${proj}_SOURCE_DIR})

else()
  if(${USE_SYSTEM_${externalProjName}})
    find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
    message("USING the system ${externalProjName}, set ${externalProjName}_DIR=${${externalProjName}_DIR}")
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
