#############################################################
#
# Onyx binaries
#
#############################################################
ONYX_BINARIES_SOURCE=onyx-intl-boox-binaries-1.5.1.tar.gz
ONYX_BINARIES_DIR := $(BUILD_DIR)/onyx-intl-boox-binaries-1.5.1

$(DL_DIR)/$(ONYX_BINARIES_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(ONYX_BINARIES_SOURCE)

$(ONYX_BINARIES_DIR)/.unpacked: $(DL_DIR)/$(ONYX_BINARIES_SOURCE)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(ONYX_BINARIES_SOURCE)
	touch $(ONYX_BINARIES_DIR)/.unpacked

onyx-binaries: $(ONYX_BINARIES_DIR)/.unpacked

onyx-binaries-clean:
	-rm -rf $(ONYX_BINARIES_DIR)
