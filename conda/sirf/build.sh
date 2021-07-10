#!/bin/bash
#
# Script to install/update the CCP-PETMR VM. It could also be used for any other system
# but will currently change your .sirfrc. This is to be avoided later on.
#
# Author: Edoardo Pasca
# Copyright 2016-2018 University College London
# Copyright 2016-2018 Rutherford Appleton Laboratory STFC
#
# This is software developed for the Collaborative Computational
# Project in Positron Emission Tomography and Magnetic Resonance imaging
# (http://www.ccppetmr.ac.uk/).

#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0.txt
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#=========================================================================

#if [ -z "$SIRF_VERSION" ]; then
#    echo "Need to set SIRF_VERSION"
#    exit 1
#fi  

mkdir "$SRC_DIR/build"
mkdir "$SRC_DIR/SIRF-SuperBuild"
#cp -rv "$RECIPE_DIR/../../" "$SRC_DIR/SIRF-SuperBuild"
rsync -rv --exclude=.git "$RECIPE_DIR/../../" "$SRC_DIR/SIRF-SuperBuild"


cd $SRC_DIR/build


#site-packages ${SP_DIR}/sirf
cmake ../SIRF-SuperBuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DPYTHON_DEST_DIR=${SP_DIR}\
    -USIRF_URL \
    -USIRF_TAG \
    -DSIRF_TAG=v2.1.0\
    -USTIR_URL \
    -USTIR_TAG \
    -UGadgetron_URL \
    -UGadgetron_TAG \
    -UISMRMRD_URL \
    -UISMRMRD_TAG \
    -DBUILD_GADGETRON=Off \
    -DUSE_SYSTEM_SWIG=On \
    -DUSE_SYSTEM_Boost=On \
    -DUSE_SYSTEM_Armadillo=On \
    -DUSE_SYSTEM_ISMRMRD=ON\
    -DUSE_SYSTEM_STIR=Off\
    -DUSE_SYSTEM_FFTW3=On \
    -DUSE_SYSTEM_HDF5=ON \
    -DBUILD_siemens_to_ismrmrd=Off \
    -DUSE_SYSTEM_GTest=On\
    -DUSE_ITK=ON\
    -DUSE_SYSTEM_ITK=OFF\
    -DUSE_SYSTEM_NIFTYREG=OFF\
    -DCONDA_BUILD=On

make -j2 NIFTYREG
make -j2 STIR
make -j1 SIRF

# remove stuff installed by STIR
rm ${PREFIX}/lib/libdata_buildblock.a
rm ${PREFIX}/lib/libeval_buildblock.a
rm ${PREFIX}/lib/libnumerics_buildblock.a
rm ${PREFIX}/lib/libdisplay.a
rm ${PREFIX}/lib/libmodelling_buildblock.a
rm ${PREFIX}/lib/libanalytic_FBP2D.a
rm ${PREFIX}/lib/libiterative_KOSMAPOSL.a
rm ${PREFIX}/lib/libiterative_OSMAPOSL.a
rm ${PREFIX}/lib/libanalytic_FBP3DRP.a
rm ${PREFIX}/lib/libiterative_OSSPS.a
rm ${PREFIX}/lib/libShape_buildblock.a
rm ${PREFIX}/lib/libspatial_transformation_buildblock.a
rm ${PREFIX}/lib/libscatter_buildblock.a
rm ${PREFIX}/lib/liblistmode_buildblock.a
rm ${PREFIX}/lib/libIO.a
rm ${PREFIX}/lib/librecon_buildblock.a
rm ${PREFIX}/lib/libbuildblock.a
rm ${PREFIX}/lib/cmake/FindRDF.cmake
rm ${PREFIX}/lib/cmake/FindAVW.cmake
rm ${PREFIX}/lib/cmake/FindLLN.cmake
rm ${PREFIX}/lib/cmake/FindNumpy.cmake
rm ${PREFIX}/lib/cmake/STIRConfigVersion.cmake
rm ${PREFIX}/lib/cmake/FindAllHeaderFiles.cmake
rm ${PREFIX}/lib/cmake/FindCERN_ROOT.cmake
rm ${PREFIX}/lib/cmake/STIRConfig.cmake
rm ${PREFIX}/lib/cmake/STIRTargets.cmake
rm ${PREFIX}/lib/cmake/STIRTargets-release.cmake
rm -rf ${PREFIX}/include/stir
rm -rf ${PREFIX}/share/stir
rm -rf ${PREFIX}/include/stir_experimental


#cp ${PREFIX}/share/gadgetron/config/gadgetron.xml.example ${PREFIX}/share/gadgetron/config/gadgetron.xml

#cd ${PREFIX}/python
#${PYTHON} setup.py install

# add to 
#echo "${PREFIX}/python" > ${PREFIX}
#${PREFIX}/python
