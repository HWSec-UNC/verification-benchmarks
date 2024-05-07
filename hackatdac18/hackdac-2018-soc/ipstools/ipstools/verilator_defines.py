#!/usr/bin/env python3
#
# vivado_defines.py
# Francesco Conti <f.conti@unibo.it>
#
# Copyright (C) 2015-2017 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

VERILATOR_PREAMBLE = """#!/bin/tcsh

"""

VERILATOR_INCLUDES = """set VERILATOR_INCLUDES="%s" """

VERILATOR_COMMAND = """

verilator +1800-2012ext+ --trace -CFLAGS -std=c++0x -cc --Mdir verilator_libs -Wno-fatal %s $VERILATOR_INCLUDES

"""

