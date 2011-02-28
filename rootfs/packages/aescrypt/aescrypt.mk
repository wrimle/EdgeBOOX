#############################################################
#
# aescrypt
#
#############################################################
AESCRYPT_SOURCE=aescrypt304_source.tar.gz
AESCRYPT_DIR := $(BUILD_DIR)/aescrypt304_source

#############################################################
#
# Build aescrypt for use on the local host system if
# needed by packages/rootfs/yaffs2.
#
#############################################################

$(DL_DIR)/$(AESCRYPT_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(AESCRYPT_SOURCE)

$(AESCRYPT_DIR)/.unpacked: $(DL_DIR)/$(AESCRYPT_SOURCE)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(AESCRYPT_SOURCE)
	$(PATCH) $(AESCRYPT_DIR) packages/aescrypt aescrypt\*.patch
	touch $(AESCRYPT_DIR)/.unpacked

$(AESCRYPT_DIR)/aescrypt: $(AESCRYPT_DIR)/.unpacked
	$(MAKE) CC=$(HOSTCC) -C $(AESCRYPT_DIR) aescrypt

$(HOST_DIR)/usr/bin/aescrypt: $(AESCRYPT_DIR)/aescrypt
	cp -dpf $(AESCRYPT_DIR)/aescrypt $(HOST_DIR)/usr/bin/aescrypt
	touch -c $(HOST_DIR)/usr/bin/aescrypt

aescrypt: $(HOST_DIR)/usr/bin/aescrypt

aescrypt-source: $(DL_DIR)/$(AESCRYPT_SOURCE)

aescrypt-clean:
	$(MAKE) -C $(AESCRYPT_DIR) clean
	-@rm -f $(HOST_DIR)/usr/bin/aescrypt

aescrypt-dirclean:
	-@rm -rf $(AESCRYPT_DIR)
