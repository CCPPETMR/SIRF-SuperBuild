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
cp -rv "$RECIPE_DIR/../../" "$SRC_DIR/SIRF-SuperBuild"

cd $SRC_DIR/build


#site-packages ${SP_DIR}/sirf
cmake ../SIRF-SuperBuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DPYTHON_DEST_DIR=${PREFIX}/python\
    -USIRF_URL \
    -USIRF_TAG \
    -DSIRF_TAG=v2.0.0\
    -USTIR_URL \
    -USTIR_TAG \
    -UGadgetron_URL \
    -UGadgetron_TAG \
    -UISMRMRD_URL \
    -UISMRMRD_TAG \
    -DBUILD_GADGETRON=On \
    -DUSE_SYSTEM_SWIG=Off \
    -DUSE_SYSTEM_Boost=On \
    -DUSE_SYSTEM_Armadillo=Off \
    -DUSE_SYSTEM_FFTW3=On \
    -DUSE_SYSTEM_HDF5=ON \
    -DBUILD_siemens_to_ismrmrd=Off \
    -DUSE_SYSTEM_GTest=Off\
    -DCONDA_BUILD=On

make  -j1 Armadillo

#cp ${PREFIX}/share/gadgetron/config/gadgetron.xml.example ${PREFIX}/share/gadgetron/config/gadgetron.xml

#cd ${PREFIX}/python
#${PYTHON} setup.py install

# add to 
#echo "${PREFIX}/python" > ${PREFIX}
#${PREFIX}/python
