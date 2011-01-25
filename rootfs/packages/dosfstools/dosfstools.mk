#############################################################
#
# dosfstool provides mkdosfs and dosfsck
#
#############################################################
DOSFS_SOURCE=dosfstools-3.0.2.tar.gz
DOSFS_DIR:=$(BUILD_DIR)/dosfstools-3.0.2

$(DL_DIR)/$(DOSFS_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(DOSFS_SOURCE)

$(DOSFS_DIR)/.unpacked: $(DL_DIR)/$(DOSFS_SOURCE)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(DOSFS_SOURCE)
	touch $(DOSFS_DIR)/.unpacked

$(DOSFS_DIR)/mkdosfs: $(DOSFS_DIR)/.unpacked
	$(MAKE)	CC=$(TARGET_CC) CFLAGS="-I$(LINUX_HEADERS_DIR)/include" PREFIX="$(TARGET_DIR)/usr" -C $(DOSFS_DIR)
	
$(TARGET_DIR)/usr/bin/mkdosfs: $(DOSFS_DIR)/mkdosfs
	cp $(DOSFS_DIR)/mkdosfs $(TARGET_DIR)/usr/bin
	$(TARGET_STRIP) $(TARGET_DIR)/usr/bin/mkdosfs

dosfs_tools: kernel-headers $(TARGET_DIR)/usr/bin/mkdosfs

dosfs_tools-source: $(DL_DIR)/$(DOSFS_SOURCE)

dosfs_tools-clean:
	-$(MAKE) -C $(DOSFS_DIR) clean
	-@rm -f $(TARGET_DIR)/usr/bin/mkdosfs

dosfs_tools-dirclean:
	rm -rf $(DOSFS_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_DOSFS_TOOLS)),y)
TARGETS+=dosfs_tools
endif
