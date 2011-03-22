#############################################################
#
# busybox
#
#############################################################

BUSYBOX_DIR:=$(BUILD_DIR)/busybox-1.6.1
BUSYBOX_SOURCE:=busybox-1.6.1.tar.bz2
#BUSYBOX_DOWNLOAD_SITE="http://www.busybox.net/downloads"

BUSYBOX_CONFIG_FILE=$(subst ",, $(strip $(PACKAGE_BUSYBOX_CONFIG)))

$(DL_DIR)/$(BUSYBOX_SOURCE):
	 $(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(BUSYBOX_SOURCE)

busybox-source: $(DL_DIR)/$(BUSYBOX_SOURCE) $(BUSYBOX_CONFIG_FILE)

$(BUSYBOX_DIR)/.unpacked: $(DL_DIR)/$(BUSYBOX_SOURCE)
	tar -C $(BUILD_DIR) -xjf $(DL_DIR)/$(BUSYBOX_SOURCE)
	$(PATCH) $(BUSYBOX_DIR) packages/busybox busybox-1.6.1\*.patch
	touch $(BUSYBOX_DIR)/.unpacked

$(BUSYBOX_DIR)/.configured: $(BUSYBOX_DIR)/.unpacked $(BUSYBOX_CONFIG_FILE)
	cp $(BUSYBOX_CONFIG_FILE) $(BUSYBOX_DIR)/.config
	$(MAKE) CC=$(TARGET_CC) CROSS_COMPILE="$(TARGET_CROSS)" -C $(BUSYBOX_DIR) oldconfig
	touch $(BUSYBOX_DIR)/.configured

$(BUSYBOX_DIR)/busybox: $(BUSYBOX_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) CROSS_COMPILE="$(TARGET_CROSS)" PREFIX="$(TARGET_DIR)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" -C $(BUSYBOX_DIR)

$(TARGET_DIR)/bin/busybox: $(BUSYBOX_DIR)/busybox
	$(MAKE) CC=$(TARGET_CC) CROSS_COMPILE="$(TARGET_CROSS)" PREFIX="$(TARGET_DIR)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" -C $(BUSYBOX_DIR) install
	# Just in case
	-chmod a+x $(TARGET_DIR)/usr/share/udhcpc/default.script

busybox: $(TARGET_DIR)/bin/busybox

busybox-clean:
	-$(MAKE) CC=$(TARGET_CC) LD=$(TARGET_LD) -C $(BUSYBOX_DIR) clean
	-@rm -f $(TARGET_DIR)/bin/busybox
	-@rm -f $(BUSYBOX_DIR)/.configured

busybox-dirclean:
	rm -rf $(BUSYBOX_DIR)
#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_BUSYBOX)),y)
TARGETS+=busybox
endif
