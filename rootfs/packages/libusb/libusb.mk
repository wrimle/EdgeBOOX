#############################################################
#
#libusb provides libusb.so and libusbpp.so
#
#############################################################
LIBUSB_SOURCE=libusb-0.1.12.tar.gz

LIBUSB_DIR:=$(BUILD_DIR)/libusb-0.1.12

$(DL_DIR)/$(LIBUSB_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(LIBUSB_SOURCE)

$(LIBUSB_DIR)/.unpacked: $(DL_DIR)/$(LIBUSB_SOURCE)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(LIBUSB_SOURCE)
	touch $(LIBUSB_DIR)/.unpacked

$(LIBUSB_DIR)/.configured: $(LIBUSB_DIR)/.unpacked
	( cd $(LIBUSB_DIR); rm -rf config.cache; \
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	./configure \
		--target=arm-none-linux-gnueabi \
		--host=arm-none-linux-gnueabi \
		--build=$(GNU_HOST_NAME) \
		--prefix=/ \
		--exec-prefix=$(EPREFIX) \
		--includedir=$(EPREFIX)/include \
		--localstatedir=/var \
		--datadir=/usr/share \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--disable-build-docs \
	);
	touch $(LIBUSB_DIR)/.configured

$(LIBUSB_DIR)/.built: $(LIBUSB_DIR)/.configured
	$(MAKE)	CC=$(TARGET_CC) -C $(LIBUSB_DIR)
	touch $(LIBUSB_DIR)/.built

$(LIBUSB_DIR)/.installed:$(LIBUSB_DIR)/.built
	$(MAKE) LD=$(TARGET_LD) DESTDIR=$(HOST_DIR) -C $(LIBUSB_DIR) install

	mv $(HOST_DIR)$(EPREFIX)/lib/libusb.la $(HOST_DIR)$(EPREFIX)/lib/libusb.la.old
	$(SED) "s,^libdir=.*,libdir=\'$(HOST_DIR)$(EPREFIX)/lib\',g" $(HOST_DIR)$(EPREFIX)/lib/libusb.la.old > $(HOST_DIR)$(EPREFIX)/lib/libusb.la

	touch $(LIBUSB_DIR)/.installed

$(TARGET_DIR)$(EPREFIX)/lib/libusb.so: $(LIBUSB_DIR)/.installed 
	cp -dpf $(LIBUSB_DIR)/.libs/libusb.so $(TARGET_DIR)$(EPREFIX)/lib
	cp -dpf $(LIBUSB_DIR)/.libs/libusb-*.so* $(TARGET_DIR)$(EPREFIX)/lib
	$(TARGET_STRIP) $(TARGET_DIR)$(EPREFIX)/lib/libusb-0.1.so.4.4.4

libusb: $(TARGET_DIR)$(EPREFIX)/lib/libusb.so

libusb-source: $(DL_DIR)/$(LIBUSB_SOURCE)

libusb-clean:
	-$(MAKE) -C $(LIBUSB_DIR) clean
	-@rm -f $(TARGET_DIR)$(EPREFIX)/lib/libusb-*.so*
	-@rm -f $(LIBUSB_DIR)/.built

libusb-dirclean:
	rm -rf $(LIBUSB_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_LIBUSB)),y)
TARGETS+=libusb
endif
