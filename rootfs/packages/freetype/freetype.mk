##########################################################
#
# freetype
#
#############################################################
FREETYPE_SOURCE:=freetype-2.3.7.tar.gz
FREETYPE_DIR:=$(BUILD_DIR)/freetype-2.3.7

$(DL_DIR)/$(FREETYPE_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(FREETYPE_SOURCE)

$(FREETYPE_DIR)/.unpacked: $(DL_DIR)/$(FREETYPE_SOURCE)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(FREETYPE_SOURCE)
	touch $(FREETYPE_DIR)/.unpacked

# freetype for the target
$(FREETYPE_DIR)/.configured: $(FREETYPE_DIR)/.unpacked
	(cd $(FREETYPE_DIR); \
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
	);
	touch $(FREETYPE_DIR)/.configured

$(FREETYPE_DIR)/objs/.libs/libfreetype.so: $(FREETYPE_DIR)/.configured
	$(MAKE) CCexe="$(HOSTCC)" -C $(FREETYPE_DIR)
	touch -c $(FREETYPE_DIR)/objs/.libs/libfreetype.so

$(HOST_DIR)$(EPREFIX)/lib/libfreetype.so: $(FREETYPE_DIR)/objs/.libs/libfreetype.so
	$(MAKE) DESTDIR=$(HOST_DIR) -C $(FREETYPE_DIR) install

	mv $(HOST_DIR)$(EPREFIX)/lib/libfreetype.la $(HOST_DIR)$(EPREFIX)/lib/libfreetype.la.old
	$(SED) "s,^libdir=.*,libdir=\'$(HOST_DIR)$(EPREFIX)/lib\',g" $(HOST_DIR)$(EPREFIX)/lib/libfreetype.la.old > $(HOST_DIR)$(EPREFIX)/lib/libfreetype.la
	
	touch -c $(HOST_DIR)$(EPREFIX)/lib/libfreetype.so
	
$(TARGET_DIR)$(EPREFIX)/lib/libfreetype.so: $(HOST_DIR)$(EPREFIX)/lib/libfreetype.so
	cp -dpf $(HOST_DIR)$(EPREFIX)/lib/libfreetype.so* $(TARGET_DIR)$(EPREFIX)/lib/
	-$(TARGET_STRIP) --strip-unneeded $(TARGET_DIR)$(EPREFIX)/lib/libfreetype.so
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/libfreetype.so

ifeq ($(strip $(PACKAGE_UCLIBC)),y)
freetype: uclibc expat $(TARGET_DIR)$(EPREFIX)/lib/libfreetype.so
else
freetype: expat $(TARGET_DIR)$(EPREFIX)/lib/libfreetype.so
endif

freetype-source: $(DL_DIR)/$(FREETYPE_SOURCE)

freetype-clean:
	$(MAKE) DESTDIR=$(HOST_DIR) CC=$(TARGET_CC) -C $(FREETYPE_DIR) uninstall
	-$(MAKE) -C $(FREETYPE_DIR) clean
	-@rm -f $(TARGET_DIR)$(EPREFIX)/lib/libfreetype.so*

freetype-dirclean:
	rm -rf $(FREETYPE_DIR)


#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_FREETYPE)),y)
TARGETS+=freetype
endif
