#===============================================================================
# Copyright 2020 Ryan Clarke
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
#===============================================================================

#===============================================================================
# Program   : Boot Loader
# File Name : Makefile
# Project   : Kit-3 8-bit Computer
# Author    : Ryan Clarke
# E-mail    : kj6msg@icloud.com
#-------------------------------------------------------------------------------
# Purpose   : Makefile for the Kit-3 boot loader.
#===============================================================================


SHELL = /bin/sh

.SUFFIXES:
.SUFFIXES: .a65 .o

PREFIX   = .
SRCDIR   := $(PREFIX)/src
BUILDDIR := $(PREFIX)/build

VPATH = $(SRCDIR):$(BUILDDIR)

SRCS := $(notdir $(wildcard */*.a65))

OBJS := $(SRCS:%.a65=%.o)
BIN  := bootload.bin
MEM  := bootload.mem

SIMOBJS := $(OBJS:%.o=%-sim.o)
SIMBIN  := $(basename $(BIN))_sim.bin

AS      = ca65
ASFLAGS = --cpu 65C02 -l $(BUILDDIR)/$(basename $@).lst -t none

LD       = ld65
LDCONFIG = memory.conf
LDFLAGS  = -C $(LDCONFIG) -m $(BUILDDIR)/$(basename $@).map --obj-path $(BUILDDIR)

BIN2HEX = tools/bin2hex.sh

.PHONY: all
all : $(MEM)

.PHONY: sim
sim : $(SIMBIN)

$(BUILDDIR) :
	mkdir -p $@

%.o %_sim.o : %.a65 bootload.inc | $(BUILDDIR)
	$(AS) $(ASFLAGS) -o $(BUILDDIR)/$@ $<

$(BIN) $(SIMBIN) : | $(BUILDDIR)
	$(LD) $(LDFLAGS) -o $(BUILDDIR)/$@ $^

$(BIN) : $(OBJS)

$(SIMBIN) : $(SIMOBJS)
$(SIMBIN) : ASFLAGS += -D SIM

$(MEM) : $(BIN)
	$(BIN2HEX) $(BUILDDIR)/$^

.PHONY: clean
clean :
	rm -rf $(BUILDDIR)

.PHONY: install
install : $(MEM)
	cp -v $^ ../hdl/
