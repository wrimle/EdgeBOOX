#############################################################
#
# Setup the kernel headers. Be aware these kernel headers
# _will_ get blown away by a 'make clean' so don't put
# anything sacred in here...
#
#############################################################
DEFAULT_KERNEL_HEADERS:=$(strip $(subst ",, $(DEFAULT_KERNEL_VERSION)))
#"

LINUX_HEADERS_DIR:=$(HOST_DIR)/$(DEFAULT_KERNEL_HEADERS)

$(LINUX_HEADERS_DIR)/.unpacked:
	mkdir -p $(LINUX_HEADERS_DIR)
#	cp -dpfr $(KERNEL_DIR)/$(LINUX_VERSION)/include $(LINUX_HEADERS_DIR)
	@if [ "$(KERN_CONFIG)" != "CONFIG_$(ZIMAGE_TARGET_PROC)=y" ] ; then \
		$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(LINUX_SOURCE_DIR) mrproper; \
		$(MAKE) CC=$(TARGET_CC) ARCH=arm -C $(LINUX_SOURCE_DIR) $(PROC_CONFIG); \
	fi;
	$(MAKE) $(TARGET_CONFIGURE_OPTS) ARCH=arm -C $(LINUX_SOURCE_DIR) headers_check
	$(MAKE) $(TARGET_CONFIGURE_OPTS) ARCH=arm -C $(LINUX_SOURCE_DIR) INSTALL_HDR_PATH=$(LINUX_HEADERS_DIR) headers_install
	touch $(LINUX_HEADERS_DIR)/.unpacked

kernel-headers: linux-source $(LINUX_HEADERS_DIR)/.unpacked

kernel-headers-clean: clean
	rm -rf $(LINUX_HEADERS_DIR)

kernel-headers-dirclean:
	rm -rf $(LINUX_HEADERS_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_LINUX)),y)
TARGETS+=kernel-headers
endif
