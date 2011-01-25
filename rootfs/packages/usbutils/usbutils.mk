#############################################################
#
# usbutils provides lsusb
#
#############################################################
USBUTILS_SOURCE=usbutils-0.84.tar.gz

USBUTILS_DIR:=$(BUILD_DIR)/usbutils-0.84

$(DL_DIR)/$(USBUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(USBUTILS_SOURCE)

$(USBUTILS_DIR)/.unpacked: $(DL_DIR)/$(USBUTILS_SOURCE)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(USBUTILS_SOURCE)
	touch $(USBUTILS_DIR)/.unpacked

$(USBUTILS_DIR)/.configured: $(USBUTILS_DIR)/.unpacked
	(cd $(USBUTILS_DIR); $(TARGET_CONFIGURE_OPTS) \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	PKG_CONFIG_PATH="$(HOST_DIR)$(EPREFIX)/lib/pkgconfig:$$PATH" \
	ac_cv_func_malloc_0_nonnull=yes \
	./configure \
		--target=arm-none-linux-gnueabi \
		--host=arm-none-linux-gnueabi \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
	);
	touch $(USBUTILS_DIR)/.configured

$(USBUTILS_DIR)/lsusb: $(USBUTILS_DIR)/.configured
	$(MAKE)	CC=$(TARGET_CC) -C $(USBUTILS_DIR)

$(TARGET_DIR)/usr/bin/lsusb: $(USBUTILS_DIR)/lsusb
	cp -dpf $(USBUTILS_DIR)/lsusb $(TARGET_DIR)/usr/bin
	$(TARGET_STRIP) $(TARGET_DIR)/usr/bin/lsusb
	cp -dpf $(USBUTILS_DIR)/usb.ids $(TARGET_DIR)/usr/share
	touch -c $(TARGET_DIR)/usr/bin/lsusb

usbutils: libusb $(TARGET_DIR)/usr/bin/lsusb

usbutils-source: $(DL_DIR)/$(USBUTILS_SOURCE)

usbutils-clean:
	-$(MAKE) -C $(USBUTILS_DIR) clean
	-@rm -f $(TARGET_DIR)/usr/bin/lsusb
	-@rm -f $(TARGET_DIR)/usr/share/usb.ids
	-@rm -f $(USBUTILS_DIR)/.configured
	

usbutils-dirclean:
	rm -rf $(USBUTILS_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_USBUTILS)),y)
TARGETS+=usbutils
endif
