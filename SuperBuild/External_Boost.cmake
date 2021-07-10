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
set(proj Boost)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})
SetCanonicalDirectoryNames(${proj})


if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  # If building own version of boost, try to minimise looking for other versions
  set(Boost_NO_BOOST_CMAKE ON)
  set(Boost_NO_SYSTEM_PATHS ON)
  mark_as_superbuild(Boost_NO_BOOST_CMAKE)
  mark_as_superbuild(Boost_NO_SYSTEM_PATHS)

  ### --- Project specific additions here
  set(${proj}_Install_Dir ${SUPERBUILD_INSTALL_DIR})
  set(Boost_Configure_Script ${CMAKE_CURRENT_LIST_DIR}/External_Boost_configureboost.cmake)
  set(Boost_Build_Script ${CMAKE_CURRENT_LIST_DIR}/External_Boost_buildboost.cmake)

  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

  #set(BOOST_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj})


  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    ${${proj}_EP_ARGS_DIRS}
    
    BUILD_IN_SOURCE 0

    CONFIGURE_COMMAND ${CMAKE_COMMAND}
      ${CLANG_ARG}
      -DBUILD_DIR:PATH=${${proj}_SOURCE_DIR}
      -DBOOST_INSTALL_DIR:PATH=${Boost_Install_Dir}
      -P ${Boost_Configure_Script}
    INSTALL_COMMAND ""
    BUILD_COMMAND ${CMAKE_COMMAND}
      -DBUILD_DIR:PATH=${${proj}_SOURCE_DIR}
      -DBOOST_INSTALL_DIR:PATH=${Boost_Install_Dir} -P ${Boost_Build_Script}
  )

  set(BOOST_ROOT        ${Boost_Install_Dir})
  set(BOOST_INCLUDEDIR  ${Boost_Install_Dir}/include)
  set(BOOST_LIBRARY_DIR ${Boost_Install_Dir}/lib)

  set(Boost_CMAKE_ARGS
      -DBOOST_INCLUDEDIR:PATH=${BOOST_ROOT}/include/
      -DBOOST_LIBRARYDIR:PATH=${BOOST_LIBRARY_DIR}
      -DBOOST_ROOT:PATH=${BOOST_ROOT}
  )

 else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
      set(Boost_CMAKE_ARGS -DBOOST_INCLUDEDIR:PATH=${Boost_INCLUDE_DIR})
      if (Boost_LIBRARY_DIR_RELEASE)
        # TODO might need to use Boost_LIBRARY_DIR_Debug for Debug builds
        set(Boost_CMAKE_ARGS ${Boost_CMAKE_ARGS} -DBOOST_LIBRARYDIR:PATH=${Boost_LIBRARY_DIR_RELEASE})
      endif()
      if (BOOST_ROOT)
        set(Boost_CMAKE_ARGS ${Boost_CMAKE_ARGS} -DBOOST_ROOT:PATH=${BOOST_ROOT})
      endif()
      if (WIN32)
        # need to tell boost to use dynamic libraries as otherwise it tends to compile as static, 
        # but link with dynamic libraries, resulting in linking problems
        # TODO this does not work yet, as it overrides any CMAKE_CXX_FLAGS set by other means
        # (CMake for VS 2015 sets by default CMAKE_CXX_FLAGS=/DWIN32 /D_WINDOWS /W3 /GR /EHsc)
        #set(Boost_CMAKE_ARGS ${Boost_CMAKE_ARGS} -DCMAKE_CXX_FLAGS:STRING="-DBOOST_ALL_DYN_LINK")
      endif()
      message(STATUS "USING the system ${externalProjName}, using Boost_CMAKE_ARGS=" "${Boost_CMAKE_ARGS}")
 endif()
   ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
                             ${${proj}_EP_ARGS_DIRS}
  )
endif()

if (NOT WIN32)
# Avoid linking problems with boost system, specifically 
# boost::system::detail::generic_category_instance
# by forcing Boost to use an inline variable, as opposed to
# the instantiated variable in the library
# See https://github.com/SyneRBI/SIRF-SuperBuild/issues/161
# However, this solution is flawed as it overrides any system compiler flags, see
# https://github.com/SyneRBI/SIRF-SuperBuild/issues/455
# Probably should check if it's still necessary for recent Boost.
set(Boost_CMAKE_ARGS ${Boost_CMAKE_ARGS}
        -DCMAKE_CXX_FLAGS:STRING=-DBOOST_ERROR_CODE_HEADER_ONLY\ -DBOOST_SYSTEM_NO_DEPRECATED)
endif()

mark_as_superbuild(
  VARS
    ${externalProjName}_DIR:PATH
  LABELS
    "FIND_PACKAGE"
)
