# Copyright 2019 University College London

# This file is part of SIRF.
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
#
# This file is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# See STIR/LICENSE.txt for details

if (NOT SPM12_DIR)
  set(SPM12_DIR "" CACHE PATH "Path to SPM12")
endif()

find_file(spm_realign "spm_realign.m" PATHS "${SPM12_DIR}" NO_DEFAULT_PATH)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SPM12
  FOUND_VAR SPM12_FOUND
  REQUIRED_VARS spm_realign
)

unset(spm_realign CACHE)