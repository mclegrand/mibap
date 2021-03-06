#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 150-jhbuild_inkdeps.sh ###
# Install Inkscape dependencies (besides GTK3).

### settings and functions #####################################################

for script in $(dirname ${BASH_SOURCE[0]})/0??-*.sh; do source $script; done

### install Inkscape dependencies ##############################################

jhbuild build \
  bdw-gc \
  doubleconversion \
  googletest \
  gsl \
  gspell \
  imagemagick \
  libcdr \
  libsoup \
  libvisio \
  openjpeg \
  openmp \
  poppler \
  potrace
