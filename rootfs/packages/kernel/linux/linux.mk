DFLT_KERNEL_VERSION:=$(strip $(subst ",, $(DEFAULT_KERNEL_VERSION)))
#"

ZIMAGE_CUSTOM_CONFIG=$(subst ",, $(strip $(ZIMAGE_CONFIG_FILE)))
#"
ifneq ("$(strip $(ZIMAGE_CUSTOM_CONFIG))",)
PROC_CONFIG:=
PROC_CONFIG:=$(ZIMAGE_CUSTOM_CONFIG)
endif

ifeq ("$(strip $(DFLT_KERNEL_VERSION))","2.6.26")
LINUX_SOURCE:=linux-2.6.26.tgz
LINUX_VERSION:=linux-2.6.26
endif

LINUX_SOURCE_DIR:=$(KERNEL_DIR)/$(LINUX_VERSION)
ZIMAGE_TARGET_BASE=$(BASE_DIR)/images

ifeq ($(strip $(KERNEL_IMX31)),y)
PROC_CONFIG:=onyx_defconfig
ZIMAGE_TARGET_PROC:=MACH_MX31_3DS
endif

KERNEL_VERSION:=${shell cat $(LINUX_SOURCE_DIR)/include/config/kernel.release}
KERN_CONFIG:=${shell grep "$(ZIMAGE_TARGET_PROC)=y" $(LINUX_SOURCE_DIR)/.config}

ZIMAGE_TARGET:=$(ZIMAGE_TARGET_BASE)/$(strip $(subst ",, $(DEFAULT_PACKAGE_BSP)))

$(DL_DIR)/$(LINUX_SOURCE):
	mkdir -p $(DL_DIR)
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(LINUX_SOURCE)

$(LINUX_SOURCE_DIR)/.unpacked: $(DL_DIR)/$(LINUX_SOURCE)
	mkdir -p $(BASE_DIR)/kernel
	tar -C $(KERNEL_DIR) -xzf $(DL_DIR)/$(LINUX_SOURCE)
	-mv $(KERNEL_DIR)/trunk $(LINUX_SOURCE_DIR)
	touch $(LINUX_SOURCE_DIR)/.unpacked

$(LINUX_SOURCE_DIR)/.patched: $(LINUX_SOURCE_DIR)/.unpacked
	$(PATCH) $(LINUX_SOURCE_DIR) packages/kernel/linux $(LINUX_VERSION)\*.patch
	touch $(LINUX_SOURCE_DIR)/.patched

$(LINUX_SOURCE_DIR)/menu_config:$(LINUX_SOURCE_DIR)/.patched
#	cp $(LINUX_SOURCE_DIR)/arch/arm/configs/$(PROC_CONFIG) $(LINUX_SOURCE_DIR)/.config
	$(MAKE) ARCH=arm CC=$(TARGET_CC) -C $(LINUX_SOURCE_DIR) menuconfig
#	$(MAKE) $(TARGET_CONFIGURE_OPTS) ARCH=arm -C $(LINUX_SOURCE_DIR) zImage
#	mkdir -p $(BASE_DIR)/images/${shell echo $(ep) | tr "[a-z]" "[A-Z]"}
#	cp -dpR $(LINUX_SOURCE_DIR)/arch/arm/boot/zImage $(BASE_DIR)/images/${shell echo $(ep) | tr "[a-z]" "[A-Z]"}

zImage:$(LINUX_SOURCE_DIR)/.patched
	mkdir -p $(ZIMAGE_TARGET_BASE)
	mkdir -p $(ZIMAGE_TARGET)
	@if [ "$(KERN_CONFIG)" != "CONFIG_$(ZIMAGE_TARGET_PROC)=y" ] ; then \
		$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(LINUX_SOURCE_DIR) mrproper; \
		$(MAKE) CC=$(TARGET_CC) ARCH=arm -C $(LINUX_SOURCE_DIR) $(PROC_CONFIG); \
	fi;
	@$(MAKE) $(TARGET_CONFIGURE_OPTS) ARCH=arm -C $(LINUX_SOURCE_DIR) zImage
	@$(MAKE) $(TARGET_CONFIGURE_OPTS) ARCH=arm -C $(LINUX_SOURCE_DIR) modules
	@$(MAKE) $(TARGET_CONFIGURE_OPTS) ARCH=arm -C $(LINUX_SOURCE_DIR) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	rm -Rf $(TARGET_DIR)/lib/modules/*/source
	rm -Rf $(TARGET_DIR)/lib/modules/*/build
	cp -dpR $(LINUX_SOURCE_DIR)/arch/arm/boot/zImage $(ZIMAGE_TARGET)
	@if [ "$(TARGET_ZIMAGE_COPYTO)" != "" ] ; then \
		cp -dpR $(LINUX_SOURCE_DIR)/arch/arm/boot/zImage $(TARGET_ZIMAGE_COPYTO); \
	fi;
	@for MODULE_DIR in `ls $(TARGET_DIR)/lib/modules`; \
        do \
                if [ $$MODULE_DIR != $(strip $(KERNEL_VERSION)) ]; then \
                        rm -Rf $(TARGET_DIR)/lib/modules/$$MODULE_DIR; \
                fi; \
        done;
	
linux: zImage

linux-config: $(LINUX_SOURCE_DIR)/menu_config

linux-source: $(LINUX_SOURCE_DIR)/.patched

linux-clean:
	-$(MAKE) CC=$(TARGET_CC) -C $(LINUX_SOURCE_DIR) mrproper
	-@rm -f $(LINUX_SOURCE_DIR)/.ep_name_*
	

linux-dirclean:
	rm -rf $(LINUX_SOURCE_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_LINUX)),y)
#TARGETS+=linux
endif
