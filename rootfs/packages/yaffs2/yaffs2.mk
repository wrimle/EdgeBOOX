#############################################################
#
# yaffs2 utilities
#
#############################################################
YAFFS2_SOURCE=yaffs2-2d221c0839d2e8733f52ee31e72e7f81faecb6cc.tar.gz
YAFFS2_DIR	:=	$(BUILD_DIR)/yaffs2

#############################################################
#
# Build mkyaffs2image for use on the local host system if
# needed by packages/rootfs/yaffs2.
#
#############################################################

$(DL_DIR)/$(YAFFS2_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(YAFFS2_SOURCE)

$(YAFFS2_DIR)/.unpacked: $(DL_DIR)/$(YAFFS2_SOURCE)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(YAFFS2_SOURCE)
	$(PATCH) $(YAFFS2_DIR) packages/yaffs2 yaffs2\*.patch
	touch $(YAFFS2_DIR)/.unpacked

$(YAFFS2_DIR)/utils/mkyaffs2image: $(YAFFS2_DIR)/.unpacked
	$(MAKE) CC=$(HOSTCC) -C $(YAFFS2_DIR)/utils mkyaffs2image

$(HOST_DIR)/usr/bin/mkyaffs2image: $(YAFFS2_DIR)/utils/mkyaffs2image
	cp -dpf $(YAFFS2_DIR)/utils/mkyaffs2image $(HOST_DIR)/usr/bin/mkyaffs2image
	touch -c $(HOST_DIR)/usr/bin/mkyaffs2image

mkyaffs2image: $(HOST_DIR)/usr/bin/mkyaffs2image

mkyaffs2image-source: $(DL_DIR)/$(YAFFS2_SOURCE)

mkyaffs2image-clean:
	$(MAKE) -C $(YAFFS2_DIR)/utils clean
	-@rm -f $(HOST_DIR)/usr/bin/mkyaffs2image

yaffs2-dirclean:
	-@rm -rf $(YAFFS2_DIR)
