WPA_SUPPLICANT_SOURCE=wpa_supplicant-0.6.9.tar.gz
WPA_SUPPLICANT_DIR=$(BUILD_DIR)/wpa_supplicant-0.6.9
#WPA_SUPPLICANT_DOWNLOAD_SITE="http://w1.fi/releases"

$(DL_DIR)/$(WPA_SUPPLICANT_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(WPA_SUPPLICANT_SOURCE)

$(WPA_SUPPLICANT_DIR)/.unpacked:$(DL_DIR)/$(WPA_SUPPLICANT_SOURCE)
	tar -C $(BUILD_DIR) -zxf $(DL_DIR)/$(WPA_SUPPLICANT_SOURCE)
	touch $(WPA_SUPPLICANT_DIR)/.unpacked

$(WPA_SUPPLICANT_DIR)/.patched:$(WPA_SUPPLICANT_DIR)/.unpacked
	touch $(WPA_SUPPLICANT_DIR)/.patched

$(WPA_SUPPLICANT_DIR)/.configured:$(WPA_SUPPLICANT_DIR)/.patched
	cp packages/wpa_supplicant/defconfig $(WPA_SUPPLICANT_DIR)/wpa_supplicant/.config
	echo "CFLAGS += -I$(HOST_DIR)$(EPREFIX)/include" >> $(WPA_SUPPLICANT_DIR)/wpa_supplicant/.config
	echo "LIBS += -L$(HOST_DIR)$(EPREFIX)/lib" >> $(WPA_SUPPLICANT_DIR)/wpa_supplicant/.config
	echo "LIBS_p += -L$(HOST_DIR)$(EPREFIX)/lib" >> $(WPA_SUPPLICANT_DIR)/wpa_supplicant/.config
	touch $(WPA_SUPPLICANT_DIR)/.configured

$(WPA_SUPPLICANT_DIR)/wpa_supplicant/wpa_supplicant:$(WPA_SUPPLICANT_DIR)/.configured
	$(MAKE) BASEDIR=$(BUILD_DIR) CC=$(TARGET_CC) -C $(WPA_SUPPLICANT_DIR)/wpa_supplicant
	touch $(WPA_SUPPLICANT_DIR)/wpa_supplicant/wpa_supplicant
	touch $(WPA_SUPPLICANT_DIR)/wpa_supplicant/wpa_cli
	touch $(WPA_SUPPLICANT_DIR)/wpa_supplicant/wpa_passphrase

$(TARGET_DIR)/usr/bin/wpa_supplicant:$(WPA_SUPPLICANT_DIR)/wpa_supplicant/wpa_supplicant
	cp -dpf $(WPA_SUPPLICANT_DIR)/wpa_supplicant/wpa_supplicant $(TARGET_DIR)/usr/bin
	-$(TARGET_STRIP) $(TARGET_DIR)/usr/bin/wpa_supplicant

wpa_supplicant:openssl $(TARGET_DIR)/usr/bin/wpa_supplicant

wpa_supplicant-source:$(DL_DIR)/$(WPA_SUPPLICANT_SOURCE)

wpa_supplicant-clean:
	-$(MAKE) -C $(WPA_SUPPLICANT_DIR)/wpa_supplicant clean
	-@rm -f $(TARGET_DIR)/usr/bin/wpa*
	-@rm -f $(WPA_SUPPLICANT_DIR)/.configured

wpa_supplicant-dirclean:
	rm -rf $(WPA_SUPPLICANT_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_WPA_SUPPLICANT)),y)
TARGETS+=wpa_supplicant
endif
