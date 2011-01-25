UDEV_SOURCE=udev-117.tar.bz2
UDEV_DIR=$(BUILD_DIR)/udev-117

$(DL_DIR)/$(UDEV_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(UDEV_SOURCE)

$(UDEV_DIR)/.unpacked:$(DL_DIR)/$(UDEV_SOURCE)
	tar -C $(BUILD_DIR) -jxf $(DL_DIR)/$(UDEV_SOURCE)
	touch $(UDEV_DIR)/.unpacked

$(UDEV_DIR)/udevd:$(UDEV_DIR)/.unpacked
	$(MAKE) CROSS_COMPILE=$(TARGET_CROSS) -C $(UDEV_DIR) all

$(HOST_DIR)/sbin/udevd:$(UDEV_DIR)/udevd
	$(MAKE) DESTDIR=$(HOST_DIR) -C $(UDEV_DIR) install

$(TARGET_DIR)/sbin/udevd:$(HOST_DIR)/sbin/udevd
	cp -dpR $(HOST_DIR)/etc/udev $(TARGET_DIR)/etc/
	cp -dpf $(HOST_DIR)/sbin/udev* $(TARGET_DIR)/sbin/
	-$(TARGET_STRIP) $(TARGET_DIR)/sbin/udev*
	cp -dpf $(HOST_DIR)/usr/bin/udev* $(TARGET_DIR)/usr/bin/
	cp -dpf $(HOST_DIR)/usr/sbin/udev* $(TARGET_DIR)/usr/sbin/
	touch -c $(TARGET_DIR)/sbin/udevadm
	touch -c $(TARGET_DIR)/sbin/udevd

udev: $(TARGET_DIR)/sbin/udevd

udev-source:$(DL_DIR)/$(UDEV_SOURCE)

udev-clean:
	-$(MAKE) DESTDIR=$(HOST_DIR) -C $(UDEV_DIR) uninstall
	-$(MAKE) -C $(UDEV_DIR) clean
	-@rm -rf $(TARGET_DIR)/etc/udev
	-@rm -f $(TARGET_DIR)/sbin/udev*
	-@rm -f $(TARGET_DIR)/usr/bin/udev*
	-@rm -f $(TARGET_DIR)/usr/sbin/udev*
	
udev-dirclean:
	rm -rf $(UDEV_DIR)


#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_UDEV)),y)
TARGETS+=udev
endif
