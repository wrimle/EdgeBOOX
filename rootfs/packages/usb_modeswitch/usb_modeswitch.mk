USB_MODESWITCH_SOURCE=usb_modeswitch-1.0.2.tar.bz2
USB_MODESWITCH_DIR=$(BUILD_DIR)/usb_modeswitch-1.0.2

$(DL_DIR)/$(USB_MODESWITCH_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(USB_MODESWITCH_SOURCE)

$(USB_MODESWITCH_DIR)/.unpacked:$(DL_DIR)/$(USB_MODESWITCH_SOURCE)
	tar -C $(BUILD_DIR) -jxf $(DL_DIR)/$(USB_MODESWITCH_SOURCE)
	touch $(USB_MODESWITCH_DIR)/.unpacked

$(USB_MODESWITCH_DIR)/.patched:$(USB_MODESWITCH_DIR)/.unpacked
	$(PATCH) $(USB_MODESWITCH_DIR) packages/usb_modeswitch usb_modeswitch\*.patch
	-@rm -f $(USB_MODESWITCH_DIR)/usb_modeswitch
	touch $(USB_MODESWITCH_DIR)/.patched

$(USB_MODESWITCH_DIR)/usb_modeswitch:$(USB_MODESWITCH_DIR)/.patched
	$(MAKE) CC=$(TARGET_CC) STRIP=$(TARGET_STRIP) CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" -C $(USB_MODESWITCH_DIR)

$(TARGET_DIR)/usr/bin/usb_modeswitch:$(USB_MODESWITCH_DIR)/usb_modeswitch
	cp -dpf $(USB_MODESWITCH_DIR)/usb_modeswitch $(TARGET_DIR)/usr/bin
	touch -c $(TARGET_DIR)/usr/bin/usb_modeswitch

usb_modeswitch:libusb $(TARGET_DIR)/usr/bin/usb_modeswitch

usb_modeswitch-source:$(DL_DIR)/$(USB_MODESWITCH_SOURCE)

usb_modeswitch-clean:
	-$(MAKE) -C $(USB_MODESWITCH_DIR) clean
	-@rm -f $(TARGET_DIR)/usr/bin/usb_modeswitch

usb_modeswitch-dirclean:
	rm -rf $(USB_MODESWITCH_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_USB_MODESWITCH)),y)
TARGETS+=usb_modeswitch
endif
