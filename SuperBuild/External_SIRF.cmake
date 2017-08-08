#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Copyright 2017 University College London
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
set(proj SIRF)

# Set dependency list
set(${proj}_DEPENDENCIES "STIR;Boost;HDF5;ISMRMRD;FFTW3;SWIG")

message(STATUS "MATLAB_ROOT=" ${MATLAB_ROOT})
message(STATUS "STIR_DIR=" ${STIR_DIR})

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(SIRF_Install_Dir ${SUPERBUILD_INSTALL_DIR})

  # Attempt to make Python settings consistent
  FIND_PACKAGE(PythonInterp)
  if (PYTHONINTERP_FOUND)
   set(Python_ADDITIONAL_VERSIONS ${PYTHON_VERSION_STRING})
    message(STATUS "Found PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}")
    message(STATUS "Python version ${PYTHON_VERSION_STRING}")
  endif()
  FIND_PACKAGE(PythonLibs)
  set (BUILD_PYTHON ${PYTHONLIBS_FOUND})
  if (BUILD_PYTHON)
    set(PYTHON_DEST "${SIRF_Install_Dir}/python" CACHE PATH "Destination for python modules")
    message(STATUS "Using PYTHON_LIBRARY=${PYTHON_LIBRARY}")
    message(STATUS "Using PYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}")
  endif()

  message(STATUS "HDF5_ROOT in External_SIRF: " ${HDF5_ROOT})
  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${SUPERBUILD_INSTALL_DIR})

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY ${${proj}_URL}
    GIT_TAG ${${proj}_TAG}
    SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}

    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH=${SUPERBUILD_INSTALL_DIR}
        -DCMAKE_LIBRARY_PATH=${SUPERBUILD_INSTALL_DIR}/lib
        -DCMAKE_INSTALL_PREFIX=${SIRF_Install_Dir}
        -DBOOST_INCLUDEDIR=${BOOST_ROOT}/include/
        -DBOOST_LIBRARYDIR=${BOOST_LIBRARY_DIR}
        -DMATLAB_ROOT=${MATLAB_ROOT}
        -DSTIR_DIR=${STIR_DIR}
        -DHDF5_ROOT=${HDF5_ROOT}
        -DHDF5_INCLUDE_DIRS=${HDF5_INCLUDE_DIRS}
        -DISMRMRD_DIR=${ISMRMRD_DIR}
        -DSWIG_EXECUTABLE=${SWIG_EXECUTABLE}
        -DPYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}
        -DPYTHON_LIBRARY=${PYTHON_LIBRARY}
        -DPYTHON_DEST=${PYTHON_DEST}
	INSTALL_DIR ${SIRF_Install_Dir}
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

    set(SIRF_ROOT        ${SIRF_SOURCE_DIR})
    set(SIRF_INCLUDE_DIR ${SIRF_SOURCE_DIR})

   else()
      if(${USE_SYSTEM_${externalProjName}})
        find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
        message("USING the system ${externalProjName}, set ${externalProjName}_DIR=${${externalProjName}_DIR}")
    endif()
    ExternalProject_Add_Empty(${proj} "${${proj}_DEPENDENCIES}")
  endif()

  mark_as_superbuild(
    VARS
      ${externalProjName}_DIR:PATH
    LABELS
      "FIND_PACKAGE"
  )
