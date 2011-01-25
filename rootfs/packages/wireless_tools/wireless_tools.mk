WIRELESS_TOOLS_SOURCE=wireless_tools.29.tar.gz
WIRELESS_TOOLS_DIR=$(BUILD_DIR)/wireless_tools.29

$(DL_DIR)/$(WIRELESS_TOOLS_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(WIRELESS_TOOLS_SOURCE)

$(WIRELESS_TOOLS_DIR)/.unpacked:$(DL_DIR)/$(WIRELESS_TOOLS_SOURCE)
	tar -C $(BUILD_DIR) -zxf $(DL_DIR)/$(WIRELESS_TOOLS_SOURCE)
	touch $(WIRELESS_TOOLS_DIR)/.unpacked

$(WIRELESS_TOOLS_DIR)/iwconfig:$(WIRELESS_TOOLS_DIR)/.unpacked
	$(MAKE) CC=$(TARGET_CC) -C $(WIRELESS_TOOLS_DIR) all

$(HOST_DIR)/sbin/iwconfig:$(WIRELESS_TOOLS_DIR)/iwconfig
	$(MAKE) PREFIX=$(HOST_DIR) INSTALL_MAN=$(HOST_DIR)/usr/share/man -C $(WIRELESS_TOOLS_DIR) install

$(TARGET_DIR)/sbin/iwconfig:$(HOST_DIR)/sbin/iwconfig
	cp -dpf $(HOST_DIR)/sbin/iw* $(TARGET_DIR)/sbin/
	-$(TARGET_STRIP) $(TARGET_DIR)/sbin/iw*
	cp -dpf $(HOST_DIR)/sbin/ifrename $(TARGET_DIR)/sbin/
	-$(TARGET_STRIP) $(TARGET_DIR)/sbin/ifrename
	cp -dpf $(HOST_DIR)/lib/libiw.so* $(TARGET_DIR)/lib
	-$(TARGET_STRIP) $(TARGET_DIR)/lib/libiw.so*

wireless_tools: $(TARGET_DIR)/sbin/iwconfig

wireless_tools-source:$(DL_DIR)/$(WIRELESS_TOOLS_SOURCE)

wireless_tools-clean:
	-$(MAKE) PREFIX=$(HOST_DIR) -C $(WIRELESS_TOOLS_DIR) uninstall
	-$(MAKE) -C $(WIRELESS_TOOLS_DIR) clean
	-@rm -f $(TARGET_DIR)/sbin/iw*
	-@rm -f $(TARGET_DIR)/sbin/ifrename
	-@rm -f $(TARGET_DIR)/lib/libiw.so*
	
wireless_tools-dirclean:
	rm -rf $(WIRELESS_TOOLS_DIR)


#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_WIRELESS_TOOLS)),y)
TARGETS+=wireless_tools
endif
