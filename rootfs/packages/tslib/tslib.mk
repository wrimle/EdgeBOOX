TSLIB_SOURCE=tslib.tar.gz
TSLIB_DIR=$(BUILD_DIR)/tslib
TSLIB_CFLAGS=-fPIC -DGCC_HASCLASSVISIBILITY

$(DL_DIR)/$(TSLIB_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(TSLIB_SOURCE)

$(TSLIB_DIR)/.unpacked: $(DL_DIR)/$(TSLIB_SOURCE)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(TSLIB_SOURCE)
	touch $(TSLIB_DIR)/.unpacked

$(TSLIB_DIR)/.patched: $(TSLIB_DIR)/.unpacked
	touch $(TSLIB_DIR)/.patched

$(TSLIB_DIR)/.configured: $(TSLIB_DIR)/.patched
	(cd $(TSLIB_DIR); \
		configure; \
		CFLAGS="$(TARGET_CFLAGS) $(TSLIB_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) -shared-libgcc" \
		LIBS="-Wl,-rpath-link -Wl,$(HOST_DIR)$(EPREFIX)/lib -ldl" \
		./configure \
			--target=arm-none-linux-gnueabi \
			--host=arm-none-linux-gnueabi \
			--build=$(GNU_HOST_NAME) \
			--prefix=/ \
			--exec-prefix=$(EPREFIX) \
			--includedir=$(EPREFIX)/include \
			--localstatedir=/var \
			--datarootdir=/usr/share \
			--enable-shared=yes \
			--enable-static=yes \
			CC=$(TARGET_CC) \
	);
	touch $(TSLIB_DIR)/.configured

$(TSLIB_DIR)/src/.libs/libts-1.0.so.0.0.0: $(TSLIB_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(TSLIB_DIR)
	touch -c $(TSLIB_DIR)/src/.libs/libts-1.0.so.0.0.0

$(HOST_DIR)$(EPREFIX)/lib/libts-1.0.so.0.0.0: $(TSLIB_DIR)/src/.libs/libts-1.0.so.0.0.0
	$(MAKE) DESTDIR=$(HOST_DIR) -C $(TSLIB_DIR) install

	mv $(HOST_DIR)$(EPREFIX)/lib/libts.la $(HOST_DIR)$(EPREFIX)/lib/libts.la.old
	$(SED) "s,^libdir=.*,libdir=\'$(HOST_DIR)$(EPREFIX)/lib\',g" $(HOST_DIR)$(EPREFIX)/lib/libts.la.old > $(HOST_DIR)$(EPREFIX)/lib/libts.la

	touch -c $(HOST_DIR)$(EPREFIX)/lib/libts-1.0.so.0.0.0

$(TARGET_DIR)$(EPREFIX)/lib/libts-1.0.so.0.0.0: $(HOST_DIR)$(EPREFIX)/lib/libts-1.0.so.0.0.0
	cp $(TSLIB_DIR)/etc/ts.conf  $(TARGET_DIR)/etc
	cp -dpf $(HOST_DIR)$(EPREFIX)/lib/libts.so $(TARGET_DIR)$(EPREFIX)/lib
	cp -dpf $(HOST_DIR)$(EPREFIX)/lib/libts-1.0.so.0* $(TARGET_DIR)$(EPREFIX)/lib
	-$(TARGET_STRIP) --strip-unneeded $(TARGET_DIR)$(EPREFIX)/lib/libts-1.0.so.0.0.0
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/libts-1.0.so.0.0.0
	mkdir -p $(TARGET_DIR)$(EPREFIX)/lib/ts
	cp -dpf $(TSLIB_DIR)/plugins/.libs/dejitter.so $(TARGET_DIR)$(EPREFIX)/lib/ts
	-$(TARGET_STRIP) --strip-unneeded $(TARGET_DIR)$(EPREFIX)/lib/ts/dejitter.so
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/ts/dejitter.so
	cp -dpf $(TSLIB_DIR)/plugins/.libs/idsv4.so $(TARGET_DIR)$(EPREFIX)/lib/ts
	-$(TARGET_STRIP) --strip-unneeded $(TARGET_DIR)$(EPREFIX)/lib/ts/idsv4.so
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/ts/idsv4.so
	cp -dpf $(TSLIB_DIR)/plugins/.libs/variance.so $(TARGET_DIR)$(EPREFIX)/lib/ts
	-$(TARGET_STRIP) --strip-unneeded $(TARGET_DIR)$(EPREFIX)/lib/ts/variance.so
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/ts/variance.so
	cp -dpf $(TSLIB_DIR)/plugins/.libs/pthres.so $(TARGET_DIR)$(EPREFIX)/lib/ts
	-$(TARGET_STRIP) --strip-unneeded $(TARGET_DIR)$(EPREFIX)/lib/ts/pthres.so
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/ts/pthres.so
	cp -dpf $(TSLIB_DIR)/plugins/.libs/linear.so $(TARGET_DIR)$(EPREFIX)/lib/ts
	-$(TARGET_STRIP) --strip-unneeded $(TARGET_DIR)$(EPREFIX)/lib/ts/linear.so
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/ts/linear.so

tslib: $(TARGET_DIR)$(EPREFIX)/lib/libts-1.0.so.0.0.0

tslib-source: $(DL_DIR)/$(TSLIB_SOURCE)

tslib-clean:
	-$(MAKE) -C $(TSLIB_DIR) clean
	-@rm -f $(TARGET_DIR)$(EPREFIX)/lib/libts.so
	-@rm -f $(TARGET_DIR)$(EPREFIX)/lib/libts-1.0.so.0*
	-@rm -rf $(TARGET_DIR)$(EPREFIX)/lib/ts
	-@rm -f $(TARGET_DIR)/etc/ts.conf
	-@rm -f $(TARGET_DIR)/usr/bin/ts*
	-@rm -f $(HOST_DIR)/include/tslib*.h
	-@rm -f $(HOST_DIR)$(EPREFIX)/lib/libts*

tslib-dirclean:
	rm -rf $(TSLIB_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_TSLIB)),y)
TARGETS+=tslib
endif
