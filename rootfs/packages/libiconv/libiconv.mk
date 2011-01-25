#############################################################
#
# libiconv
#
#############################################################
LIBICONV_SOURCE:=libiconv-1.13.1.tar.gz
LIBICONV_DIR:=$(BUILD_DIR)/libiconv-1.13.1

$(DL_DIR)/$(LIBICONV_SOURCE):
	 $(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(LIBICONV_SOURCE)

libiconv-source: $(DL_DIR)/$(LIBICONV_SOURCE)

$(LIBICONV_DIR)/.unpacked: $(DL_DIR)/$(LIBICONV_SOURCE)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(LIBICONV_SOURCE)
	touch $(LIBICONV_DIR)/.unpacked

$(LIBICONV_DIR)/.configured: $(LIBICONV_DIR)/.unpacked
	(cd $(LIBICONV_DIR); rm -rf config.cache; \
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
		--datarootdir=/usr/share \
		--without-libiconv-prefix \
		--with-libintl-prefix=$(HOST_DIR) \
		--disable-nls \
	);
	touch $(LIBICONV_DIR)/.configured

$(LIBICONV_DIR)/.built: $(LIBICONV_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(LIBICONV_DIR)
	touch $(LIBICONV_DIR)/.built

$(HOST_DIR)$(EPREFIX)/lib/libiconv.so.2.5.0: $(LIBICONV_DIR)/.built
	$(MAKE) DESTDIR=$(HOST_DIR) -C $(LIBICONV_DIR) install

	mv $(HOST_DIR)$(EPREFIX)/lib/libiconv.la $(HOST_DIR)$(EPREFIX)/lib/libiconv.la.old
	$(SED) "s,^libdir=.*,libdir=\'$(HOST_DIR)$(EPREFIX)/lib\',g" $(HOST_DIR)$(EPREFIX)/lib/libiconv.la.old > $(HOST_DIR)$(EPREFIX)/lib/libiconv.la

	touch -c $(HOST_DIR)$(EPREFIX)/lib/libiconv.so.2.5.0

$(TARGET_DIR)$(EPREFIX)/lib/libiconv.so.2.5.0:$(HOST_DIR)$(EPREFIX)/lib/libiconv.so.2.5.0
	cp -dpf $(HOST_DIR)$(EPREFIX)/lib/libiconv.so* $(TARGET_DIR)$(EPREFIX)/lib
	-$(TARGET_STRIP) $(TARGET_DIR)$(EPREFIX)/lib/libiconv.so.2.5.0
	cp -dpf $(HOST_DIR)$(EPREFIX)/lib/libcharset.so* $(TARGET_DIR)$(EPREFIX)/lib
	-$(TARGET_STRIP) $(TARGET_DIR)$(EPREFIX)/lib/libcharset.so.1.0.0
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/libiconv.so.2.5.0
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/libcharset.so.1.0.0

libiconv: $(TARGET_DIR)$(EPREFIX)/lib/libiconv.so.2.5.0

libiconv-clean:
	$(MAKE) DESTDIR=$(TARGET_DIR) CC=$(TARGET_CC) -C $(LIBICONV_DIR) uninstall
	-$(MAKE) -C $(LIBICONV_DIR) clean
	-@rm -f $(TARGET_DIR)$(EPREFIX)/lib/libiconv.so*
	-@rm -f $(LIBICONV_DIR)/.built

libiconv-dirclean:
	rm -rf $(LIBICONV_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_LIBICONV)),y)
TARGETS+=libiconv
endif
