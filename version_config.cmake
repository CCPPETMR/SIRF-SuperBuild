#========================================================================
# Author: Edoardo Pasca
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Copyright 2017-2021 University College London
# Copyright 2017-2021 Science Technology Facilities Council
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

## BOOST  # Gadgetron needs at least 1.65
if (APPLE) # really should be checking for CLang
	# Boost 1.65 contains a bug for recent Clang https://github.com/SyneRBI/SIRF-SuperBuild/issues/170
    set(Boost_VERSION 1.68.0)
    set(Boost_REQUIRED_VERSION 1.66.0)
    set(Boost_URL http://downloads.sourceforge.net/project/boost/boost/${Boost_VERSION}/boost_1_68_0.zip)
    set(Boost_MD5 f4096c4583947b0eb103c8539f1623a3)
else()
     # Use version in Ubuntu 18.04
     set(Boost_VERSION 1.65.1)
     if (BUILD_GADGETRON)
       set(Boost_REQUIRED_VERSION 1.65.1)
     else()
       # Ubutnu 16.04 version should be fine
       set(Boost_REQUIRED_VERSION 1.58.0)
     endif()
     set(Boost_URL http://downloads.sourceforge.net/project/boost/boost/${Boost_VERSION}/boost_1_65_1.zip)
     set(Boost_MD5 9824a7a3e25c9d4fdf2def07bce8651c)
endif()

## Armadillo
set(Armadillo_URL https://downloads.sourceforge.net/project/arma/armadillo-9.800.2.tar.xz)
set(Armadillo_MD5 c2fa488ea069b9972363ebad16e51ab5 )

## FFTW3
if(WIN32)
  # Just use precompiled version
  # TODO would prefer the next zip file but for KT using an ftp URL times-out (firewall?)
  set(FFTW3_URL https://github.com/SyneRBI/assets/releases/download/latest/fftw-3.3.5-dll64.zip )
  set(FFTW3_MD5 cb3c5ad19a89864f036e7a2dd5be168c )
  #set(FFTW3_URL https://s3.amazonaws.com/install-gadgetron-vs2013/Dependencies/FFTW/zip/FFTW3.zip )
  #set(FFTW3_MD5 a42eac92d9ad06d7c53fb82b09df2b6e )
else(WIN32)
  set(FFTW3_URL http://www.fftw.org/fftw-3.3.5.tar.gz ) 
  set(FFTW3_MD5 6cc08a3b9c7ee06fdd5b9eb02e06f569 )
endif(WIN32)

set(FFTW3double_URL ${FFTW3_URL})
set(FFTW3double_MD5 ${FFTW3_MD5})

## HDF5
set(DEFAULT_HDF5_URL https://github.com/HDFGroup/hdf5/)
if (WIN32)
  set(HDF5_REQUIRED_VERSION 1.8.12)
  # 1.8.15 hdf5-targets.cmake refers to non-existent zlib files
  # (or at least this was the case for older Anaconda installations)
else()
  set(HDF5_REQUIRED_VERSION 1.8)
endif()
if (BUILD_MATLAB)
  # Ideally would call MATLAB and use "[majnum,minnum,relnum]=H5.get_libversion()"
  # but it's been stuck on 1.8.12 for a long time
  set(DEFAULT_HDF5_TAG hdf5-1_8_12)
else()
  set(DEFAULT_HDF5_TAG hdf5-1_10_1)
endif()

## SWIG
set (SWIG_REQUIRED_VERSION 2)
if (WIN32)
  set(SWIG_URL http://downloads.sourceforge.net/swig/swigwin-4.0.2.zip  )
  set(SWIG_MD5 009926b512aee9318546bdd4c7eab6f9 )
else(WIN32)
  set(SWIG_URL http://downloads.sourceforge.net/swig/swig-4.0.2.tar.gz )
  set(SWIG_MD5 7c3e46cb5af2b469722cafa0d91e127b )
endif(WIN32)

option(DEVEL_BUILD "Use current versions of major packages" OFF)

## Googletest
set(GTest_URL https://github.com/google/googletest )
set(GTest_TAG release-1.8.0)

## glog
set(DEFAULT_glog_URL https://github.com/google/glog )
set(DEFAULT_glog_TAG v0.3.5)

## ITK
set(DEFAULT_ITK_URL https://github.com/InsightSoftwareConsortium/ITK.git)
set(DEFAULT_ITK_TAG v4.13.1)

## NIFTYREG
set(DEFAULT_NIFTYREG_URL https://github.com/KCL-BMEIS/niftyreg.git )
set(DEFAULT_NIFTYREG_TAG 99d584e2b8ea0bffe7e65e40c8dc818751782d92 )
set(DEFAULT_NIFTYREG_REQUIRED_VERSION 1.5.68)

## ISMRMRD
if (WIN32)
  set(DEFAULT_ISMRMRD_URL https://github.com/SyneRBI/ismrmrd )
  set(DEFAULT_ISMRMRD_TAG program_options_fix)
else()
  set(DEFAULT_ISMRMRD_URL https://github.com/ismrmrd/ismrmrd )
  set(DEFAULT_ISMRMRD_TAG v1.4.1)
endif()

## Gadgetron
set(DEFAULT_Gadgetron_URL https://github.com/gadgetron/gadgetron )
set(DEFAULT_Gadgetron_TAG v3.17.0)
#set(DEFAULT_Gadgetron_TAG b6191eaaa72ccca6c6a5fe4c0fa3319694f512ab)

## ASTRA
set(DEFAULT_astra-toolbox_URL https://github.com/astra-toolbox/astra-toolbox )
set(DEFAULT_astra-toolbox_TAG origin/master)

## TomoPhantom
set(DEFAULT_TomoPhantom_URL https://github.com/dkazanc/TomoPhantom )
set(DEFAULT_TomoPhantom_TAG v1.4)

## NiftyPET
set(DEFAULT_NiftyPET_URL https://github.com/pjmark/NIPET )
set(DEFAULT_NiftyPET_TAG 70b97da0a4eea9445e34831f7393947a37bc77e7)

## parallelproj
set(DEFAULT_parallelproj_URL https://github.com/gschramm/parallelproj )
set(DEFAULT_parallelproj_TAG v0.7)

## SIRF-Contribs
set(DEFAULT_SIRF-Contribs_URL https://github.com/SyneRBI/SIRF-Contribs )
set(DEFAULT_SIRF-Contribs_TAG origin/master )

## SPM
set(DEFAULT_SPM_URL https://github.com/spm/SPM12.git )
set(DEFAULT_SPM_TAG r7771)

set(DEFAULT_JSON_URL https://github.com/nlohmann/json.git )
set(DEFAULT_JSON_TAG v3.9.1)

# CCPi CIL
set(DEFAULT_CIL_URL https://github.com/TomographicImaging/CIL.git)
set(DEFAULT_CIL_TAG "v21.2.0")
set(DEFAULT_CIL-ASTRA_URL https://github.com/TomographicImaging/CIL-ASTRA.git)
set(DEFAULT_CIL-ASTRA_TAG "v21.2.0")
set(DEFAULT_CCPi-Regularisation-Toolkit_URL https://github.com/vais-ral/CCPi-Regularisation-Toolkit.git)
set(DEFAULT_CCPi-Regularisation-Toolkit_TAG "v20.09")

option (DEVEL_BUILD "Developer Build" OFF)
mark_as_advanced(DEVEL_BUILD)

#Set the default versions for SIRF, STIR, Gadgetron and ISMRMRD
# with devel build it uses latest version of upstream packages
# otherwise uses the versions for current SIRF

set(DEFAULT_SIRF_URL https://github.com/SyneRBI/SIRF )
if (DEVEL_BUILD)

  set (DEFAULT_SIRF_TAG origin/master)
  ## STIR
  set(DEFAULT_STIR_URL https://github.com/UCL/STIR )
  set(DEFAULT_STIR_TAG origin/master)

  ## siemens_to_ismrmrd
  set(DEFAULT_siemens_to_ismrmrd_URL https://github.com/ismrmrd/siemens_to_ismrmrd )
  set(DEFAULT_siemens_to_ismrmrd_TAG origin/master)

  ## pet-rd-tools
  set(DEFAULT_pet_rd_tools_URL https://github.com/UCL/pet-rd-tools )
  set(DEFAULT_pet_rd_tools_TAG origin/master)

  set(DEFAULT_ACE_URL https://github.com/paskino/libace-conda)
  set(DEFAULT_ACE_TAG origin/master)

  # CCPi CIL
  set(DEFAULT_CIL_URL https://github.com/TomographicImaging/CIL.git)
  set(DEFAULT_CIL_TAG origin/master)
  set(DEFAULT_CIL-ASTRA_URL https://github.com/TomographicImaging/CIL-ASTRA.git)
  set(DEFAULT_CIL-ASTRA_TAG origin/master)
  set(DEFAULT_CCPi-Regularisation-Toolkit_URL https://github.com/vais-ral/CCPi-Regularisation-Toolkit.git)
  set(DEFAULT_CCPi-Regularisation-Toolkit_TAG origin/master)

else()
  set(DEFAULT_SIRF_TAG v3.1.0)

  ## STIR
  set(DEFAULT_STIR_URL https://github.com/UCL/STIR )
  set(DEFAULT_STIR_TAG rel_4.1.1)

  ## siemens_to_ismrmrd
  set(DEFAULT_siemens_to_ismrmrd_URL https://github.com/ismrmrd/siemens_to_ismrmrd)
  set(DEFAULT_siemens_to_ismrmrd_TAG ba4773f9cf4bba5f3ccd19930e3548d8273fee01)

  ## pet-rd-tools
  set(DEFAULT_pet_rd_tools_URL https://github.com/UCL/pet-rd-tools )
  set(DEFAULT_pet_rd_tools_TAG v2.0.1)

  set(DEFAULT_ACE_URL https://github.com/paskino/libace-conda)
  set(DEFAULT_ACE_TAG origin/master)
  
  
endif()


# Set the tags for SIRF, STIR, Gadgetron and ISMRMRD etc
# these can be overridden by the user
SET(SIRF_URL ${DEFAULT_SIRF_URL} CACHE STRING ON)
SET(SIRF_TAG ${DEFAULT_SIRF_TAG} CACHE STRING ON)
 
SET(STIR_TAG ${DEFAULT_STIR_TAG} CACHE STRING ON)
SET(STIR_URL ${DEFAULT_STIR_URL} CACHE STRING ON)

SET(Gadgetron_TAG ${DEFAULT_Gadgetron_TAG} CACHE STRING ON)
SET(Gadgetron_URL ${DEFAULT_Gadgetron_URL} CACHE STRING ON)

SET(siemens_to_ismrmrd_TAG ${DEFAULT_siemens_to_ismrmrd_TAG} CACHE STRING ON)
SET(siemens_to_ismrmrd_URL ${DEFAULT_siemens_to_ismrmrd_URL} CACHE STRING ON)

SET(ISMRMRD_TAG ${DEFAULT_ISMRMRD_TAG} CACHE STRING ON)
SET(ISMRMRD_URL ${DEFAULT_ISMRMRD_URL} CACHE STRING ON)

SET(pet_rd_tools_TAG ${DEFAULT_pet_rd_tools_TAG} CACHE STRING ON)
SET(pet_rd_tools_URL ${DEFAULT_pet_rd_tools_URL} CACHE STRING ON)

SET(glog_URL ${DEFAULT_glog_URL} CACHE STRING ON)
SET(glog_TAG ${DEFAULT_glog_TAG} CACHE STRING ON)

set(ACE_URL ${DEFAULT_ACE_URL} CACHE STRING ON)
set(ACE_TAG ${DEFAULT_ACE_TAG} CACHE STRING ON)

set(JSON_URL ${DEFAULT_JSON_URL} CACHE STRING ON)
set(JSON_TAG ${DEFAULT_JSON_TAG} CACHE STRING ON)


set(CCPi-Regularisation-Toolkit_URL ${DEFAULT_CCPi-Regularisation-Toolkit_URL} CACHE STRING ON)
set(CCPi-Regularisation-Toolkit_TAG ${DEFAULT_CCPi-Regularisation-Toolkit_TAG} CACHE STRING ON)
set(CIL_URL ${DEFAULT_CIL_URL} CACHE STRING ON)
set(CIL_TAG ${DEFAULT_CIL_TAG} CACHE STRING ON)
set(CIL-ASTRA_URL ${DEFAULT_CIL-ASTRA_URL} CACHE STRING ON)
set(CIL-ASTRA_TAG ${DEFAULT_CIL-ASTRA_TAG} CACHE STRING ON)
set(astra-toolbox_URL ${DEFAULT_astra-toolbox_URL} CACHE STRING ON)
set(astra-toolbox_TAG ${DEFAULT_astra-toolbox_TAG} CACHE STRING ON)
set(astra-python-wrapper_URL ${DEFAULT_astra-toolbox_URL} CACHE STRING ON)
set(astra-python-wrapper_TAG ${DEFAULT_astra-toolbox_TAG} CACHE STRING ON)
set(TomoPhantom_URL ${DEFAULT_TomoPhantom_URL} CACHE STRING ON)
set(TomoPhantom_TAG ${DEFAULT_TomoPhantom_TAG} CACHE STRING ON)

set(NIFTYREG_URL ${DEFAULT_NIFTYREG_URL} CACHE STRING ON)
set(NIFTYREG_TAG ${DEFAULT_NIFTYREG_TAG} CACHE STRING ON)

set(NiftyPET_URL ${DEFAULT_NiftyPET_URL} CACHE STRING ON)
set(NiftyPET_TAG ${DEFAULT_NiftyPET_TAG} CACHE STRING ON)

set(parallelproj_URL ${DEFAULT_parallelproj_URL} CACHE STRING ON)
set(parallelproj_TAG ${DEFAULT_parallelproj_TAG} CACHE STRING ON)

set(SIRF-Contribs_URL ${DEFAULT_SIRF-Contribs_URL} CACHE STRING ON)
set(SIRF-Contribs_TAG ${DEFAULT_SIRF-Contribs_TAG} CACHE STRING ON)

set(HDF5_URL ${DEFAULT_HDF5_URL} CACHE STRING ON)
set(HDF5_TAG ${DEFAULT_HDF5_TAG} CACHE STRING ON)

set(ITK_URL ${DEFAULT_ITK_URL} CACHE STRING ON)
set(ITK_TAG ${DEFAULT_ITK_TAG} CACHE STRING ON)

set(SPM_URL ${DEFAULT_SPM_URL} CACHE STRING ON)
set(SPM_TAG ${DEFAULT_SPM_TAG} CACHE STRING ON)

set(JSON_URL ${DEFAULT_JSON_URL} CACHE STRING ON)
set(JSON_TAG ${DEFAULT_JSON_TAG} CACHE STRING ON)

mark_as_advanced(SIRF_URL SIRF_TAG STIR_URL STIR_TAG
  Gadgetron_URL Gadgetron_TAG
  siemens_to_ismrmrd_URL siemens_to_ismrmrd_TAG
  ISMRMRD_URL ISMRMRD_TAG
  pet_rd_tools_URL pet_rd_tools_TAG
  glog_URL glog_TAG
  NIFTYREG_URL NIFTYREG_TAG
  CIL_URL CIL_TAG
  CIL-ASTRA_URL CIL-ASTRA_TAG
  CCPi-Regularisation-Toolkit_URL CCPi-Regularisation-Toolkit_TAG
  NiftyPET_URL NiftyPET_TAG
  parallelproj_URL parallelproj_TAG
  SIRF-Contribs_URL SIRF-Contribs_TAG
  ITK_URL ITK_TAG
  SPM_URL SPM_TAG
  JSON_URL JSON_TAG
  astra-toolbox_URL astra-toolbox_TAG
  astra-python-wrapper_URL astra-python-wrapper_TAG
  ACE_URL ACE_TAG
  
)
