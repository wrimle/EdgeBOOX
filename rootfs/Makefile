# Makefile for buildroot2
#
# Copyright (C) 1999-2005 by Erik Andersen <andersen@codepoet.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

#--------------------------------------------------------------
# Just run 'make menuconfig', configure stuff, then run 'make'.
# You shouldn't need to mess with anything beyond this point...
#--------------------------------------------------------------
TOPDIR=./
CONFIG_CONFIG_IN = Config.in
CONFIG_HELP_IN = Config.help.in
CONFIG_DEFCONFIG = .defconfig
CONFIG = packages/config

noconfig_targets := menuconfig config oldconfig \
	defconfig help

# Pull in the user's configuration file
ifeq ($(filter $(noconfig_targets),$(MAKECMDGOALS)),)
-include $(TOPDIR).config
endif

ifeq ($(strip $(HAVE_DOT_CONFIG)),y)

#############################################################
#
# The list of stuff to build for the target toolchain
# along with the packages to build for the target.
#
##############################################################
include packages/Makefile.in

#############################################################
#
# You should probably leave this stuff alone unless you know
# what you are doing.
#
#############################################################



all:   diffclean world

# In this section, we need .config
include .config.cmd

# We also need the various per-package makefiles, which also add
# each selected package to TARGETS if that package was selected
# in the .config file.
include packages/kernel/*/*.mk
#include packages/bootloader/*/*.mk
include packages/*/*.mk
include packages/rootfs/*/*.mk


# target stuff is last so it can override anything else
include packages/rootfs/Makefile.in

TARGETS_CLEAN:=$(patsubst %,%-clean,$(TARGETS))
TARGETS_SOURCE:=$(patsubst %,%-source,$(TARGETS))
TARGETS_DIRCLEAN:=$(patsubst %,%-dirclean,$(TARGETS))

world: $(DL_DIR) $(BUILD_DIR) $(HOST_DIR) $(KERNEL_DIR) $(TARGETS)

.PHONY: all world clean dirclean distclean diffclean source \
	$(TARGETS) $(TARGETS_CLEAN) $(TARGETS_DIRCLEAN) $(TARGETS_SOURCE) \
	$(DL_DIR) $(BUILD_DIR) $(HOST_DIR) $(KERNEL_DIR)

#############################################################
#
# staging and target directories do NOT list these as
# dependancies anywhere else
#
#############################################################
$(DL_DIR):
	@mkdir -p $(DL_DIR)

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(HOST_DIR):
	@mkdir -p $(HOST_DIR)

$(KERNEL_DIR): dependencies
	@mkdir -p $(KERNEL_DIR)
	
source: $(TARGETS_SOURCE)

clean: $(TARGETS_CLEAN)
	rm -rf $(HOST_DIR)/bin
	rm -f $(HOST_DIR)/fakeroot.env.00000
	rm -rf $(BUILD_DIR)/root
	find images/ -name zImage -print | xargs rm -f
	find images/ -name ramdisk -print | xargs rm -f 
	find images/ -name ramdisk.gz -print | xargs rm -f
	find images/ -name rootfs.jffs2 -print | xargs rm -f
	find images/ -name rootfs.yaffs2 -print | xargs rm -f
	find images/ -name rootfs.cramfs -print | xargs rm -f	
	find images/ -name redboot.bin -print | xargs rm -f
	find images/ -name vmlinux.gz.img -print | xargs rm -f
	find images/ -name ramdisk.gz.img -print | xargs rm -f 
	find images/ -iname u-boot.bin -print | xargs rm -f
	

distclean:
	rm -f .tmpconfig.h download redboot*
	- $(MAKE) -C $(CONFIG) clean
	rm -rf $(IMAGE_DIR)
	rm -rf $(HOST_DIR)
	rm -rf $(BUILD_DIR)
	rm -rf $(KERNEL_DIR)

diffclean:
	@touch .config.diff
	@touch .config.diff.old
	@diff .config.old .config | grep \> | grep PACKAGE |grep is\ not\ set | sed -e 's/> \# PACKAGE_//' \
		-e 's/is not set//' | tr "[A-Z]" "[a-z]" >> .config.diff
	@diff -q .config.diff.old .config.diff > /dev/null;\
	if [ `echo $$?` != 0 ]; then \
		diff -bB .config.diff.old .config.diff | grep \> | sed -e 's/> //g' > .config.diff.old;\
		for PACKAGE in `cat .config.diff.old`; \
		do \
			if [ "$$PACKAGE" != "alsa" ]; then \
				$(MAKE) $$PACKAGE-clean; \
			fi;\
		done; \
	fi;
	@rm -f .config.diff


else # ifeq ($(strip $(HAVE_DOT_CONFIG)),y)

all: menuconfig

# configuration
# ---------------------------------------------------------------------------

$(CONFIG)/conf:
	$(MAKE) -C $(CONFIG) conf
	-@if [ ! -f .config ] ; then \
		cp $(CONFIG_DEFCONFIG) .config; \
	fi
$(CONFIG)/mconf:
	$(MAKE) -C $(CONFIG) ncurses conf mconf
	-@if [ ! -f .config ] ; then \
		cp $(CONFIG_DEFCONFIG) .config; \
	fi

menuconfig: $(CONFIG)/mconf
	@$(CONFIG)/mconf $(CONFIG_CONFIG_IN)

config: $(CONFIG)/conf
	@$(CONFIG)/conf $(CONFIG_CONFIG_IN)

oldconfig: $(CONFIG)/conf
	@$(CONFIG)/conf -o $(CONFIG_CONFIG_IN)

defconfig: $(CONFIG)/conf
	@$(CONFIG)/conf -d $(CONFIG_CONFIG_IN)

help:$(CONFIG)/mconf
	-@cp -dpf .config .config.backup
	-@cp -dpf .config.help  .config
	@$(CONFIG)/mconf $(CONFIG_HELP_IN)
	-@cp -dpf .config .config.help
	-@cp -dpf .config.backup .config

#############################################################
#
# Cleanup and misc junk
#
#############################################################
clean:
	rm -f .tmpconfig.h
	- $(MAKE) -C $(CONFIG) clean
	find images/ -name zImage -print | xargs rm -f
	find images/ -name ramdisk -print | xargs rm -f 
	find images/ -name ramdisk.gz -print | xargs rm -f
	find images/ -name rootfs.jffs2 -print | xargs rm -f
	find images/ -name rootfs.yaffs2 -print | xargs rm -f
	find images/ -name rootfs.cramfs -print | xargs rm -f
	find images/ -name redboot.bin -print | xargs rm -f
	find images/ -name vmlinux.gz.img -print | xargs rm -f
	find images/ -name ramdisk.gz.img -print | xargs rm -f
	find images/ -iname u-boot.bin -print | xargs rm -f	

distclean: 
	rm -f download redboot*
	rm -rf host/
	rm -rf images/
	rm -rf build/
	rm -rf kernel/
		
	
endif # ifeq ($(strip $(HAVE_DOT_CONFIG)),y)

.PHONY: dummy subdirs release distclean clean config oldconfig \
	menuconfig tags check test depend defconfig


