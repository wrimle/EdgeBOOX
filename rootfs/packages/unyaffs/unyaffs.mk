#############################################################
#
# unyaffs utility
#
#############################################################
UNYAFFS_SOURCE=unyaffs.tar.gz
UNYAFFS_DIR=$(BUILD_DIR)/unyaffs

$(DL_DIR)/$(UNYAFFS_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(UNYAFFS_SOURCE)

$(UNYAFFS_DIR)/.unpacked:$(DL_DIR)/$(UNYAFFS_SOURCE)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(UNYAFFS_SOURCE)
	touch $(UNYAFFS_DIR)/.unpacked

$(UNYAFFS_DIR)/unyaffs:$(UNYAFFS_DIR)/.unpacked
	$(MAKE) CC=$(HOSTCC) -C $(UNYAFFS_DIR) all

$(HOST_DIR)/usr/bin/unyaffs:$(UNYAFFS_DIR)/unyaffs
	cp -dpf $(UNYAFFS_DIR)/unyaffs $(HOST_DIR)/usr/bin
	touch -c $(HOST_DIR)/usr/bin/unyaffs

unyaffs: $(HOST_DIR)/usr/bin/unyaffs

unyaffs-source: $(DL_DIR)/$(UNYAFFS_SOURCE)

unyaffs-clean:
	-$(MAKE) -C $(UNYAFFS_DIR) clean
	-@rm -f $(HOST_DIR)/usr/bin/unyaffs
	
unyaffs-dirclean:
	-rm -rf $(UNYAFFS_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(TARGET_ROOTFS_YAFFS2_UNYAFFS)),y)
TARGETS+=unyaffs
endif
