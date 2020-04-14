#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Author: Edoardo Pasca
# Copyright 2017, 2020 University College London
# Copyright 2017, 2020 STFC
#
# This file is part of the CCP SyneRBI (formely PETMR) Synergistic Image Reconstruction Framework (SIRF) SuperBuild.
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
set(proj pet_rd_tools)

# Set dependency list
set(${proj}_DEPENDENCIES "Boost;ITK;glog")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

SetCanonicalDirectoryNames(${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here

  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${SUPERBUILD_INSTALL_DIR})
  set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${SUPERBUILD_INSTALL_DIR})

  set(pet_rd_tools_CMAKE_ARGS
    -DCMAKE_PREFIX_PATH=${SUPERBUILD_INSTALL_DIR}
    -DCMAKE_LIBRARY_PATH=${SUPERBUILD_INSTALL_DIR}/lib
    -DCMAKE_INCLUDE_PATH=${SUPERBUILD_INSTALL_DIR}
    -DCMAKE_INSTALL_PREFIX=${pet_rd_tools_INSTALL_DIR}
    -DBOOST_INCLUDEDIR=${BOOST_ROOT}/include/
    -DBOOST_LIBRARYDIR=${BOOST_LIBRARY_DIR}
    -Dglog_DIR:PATH=${glog_DIR}
  )

  if (USE_SYSTEM_ITK)
    set(pet_rd_tools_CMAKE_ARGS ${pet_rd_tools_CMAKE_ARGS}
      -DITK_DIR:PATH=${ITK_DIR}
      )
  endif()

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY ${${proj}_URL}
    GIT_TAG ${${proj}_TAG}
    ${${proj}_EP_ARGS_DIRS}

    CMAKE_ARGS ${pet_rd_tools_CMAKE_ARGS}
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

    set(pet_rd_tools_ROOT        ${pet_rd_tools_SOURCE_DIR})
    set(pet_rd_tools_INCLUDE_DIR ${pet_rd_tools_SOURCE_DIR})

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
