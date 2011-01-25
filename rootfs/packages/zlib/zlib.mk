#############################################################
#
# zlib
#
#############################################################
ZLIB_SOURCE=zlib-1.2.3.tar.gz
ZLIB_DIR=$(BUILD_DIR)/zlib-1.2.3
ZLIB_CFLAGS= -fPIC -msoft-float
ifeq ($(LARGEFILE),y)
ZLIB_CFLAGS+= -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
endif

$(DL_DIR)/$(ZLIB_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(ZLIB_SOURCE)

$(ZLIB_DIR)/.source: $(DL_DIR)/$(ZLIB_SOURCE)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(ZLIB_SOURCE)
	touch $(ZLIB_DIR)/.source

$(ZLIB_DIR)/.configured: $(ZLIB_DIR)/.source
	(cd $(ZLIB_DIR); \
		./configure \
		--prefix=$(HOST_DIR)/usr \
		--exec_prefix=$(HOST_DIR)$(EPREFIX) \
		--libdir=$(HOST_DIR)$(EPREFIX)/lib \
		--includedir=$(HOST_DIR)$(EPREFIX)/include \
		--shared \
	);
	touch $(ZLIB_DIR)/.configured;

$(ZLIB_DIR)/libz.so.1.2.3: $(ZLIB_DIR)/.configured
	$(MAKE) LDSHARED="$(TARGET_CROSS)gcc -shared -Wl,-soname,libz.so.1 -shared-libgcc" \
		CFLAGS="$(ZLIB_CFLAGS)" CC=$(TARGET_CC) -C $(ZLIB_DIR) all libz.a ;
	touch -c $(ZLIB_DIR)/libz.so.1.2.3

$(HOST_DIR)$(EPREFIX)/lib/libz.so.1.2.3: $(ZLIB_DIR)/libz.so.1.2.3
	$(MAKE) -C $(ZLIB_DIR) install
	touch -c $(HOST_DIR)$(EPREFIX)/lib/libz.so.1.2.3

$(TARGET_DIR)$(EPREFIX)/lib/libz.so.1.2.3: $(HOST_DIR)$(EPREFIX)/lib/libz.so.1.2.3
	mkdir -p $(TARGET_DIR)$(EPREFIX)/lib
	cp -dpf $(HOST_DIR)$(EPREFIX)/lib/libz.so* $(TARGET_DIR)$(EPREFIX)/lib
	-$(TARGET_STRIP) $(TARGET_DIR)$(EPREFIX)/lib/libz.so*
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/libz.so.1.2.3

zlib-example: $(TARGET_DIR)$(EPREFIX)/lib/libz.so.1.2.3

ifeq ($(strip $(PACKAGE_UCLIBC)),y)
zlib: uclibc $(TARGET_DIR)$(EPREFIX)/lib/libz.so.1.2.3
else
zlib: $(TARGET_DIR)$(EPREFIX)/lib/libz.so.1.2.3
endif

zlib-source: $(DL_DIR)/$(ZLIB_SOURCE)

zlib-clean:
	-$(MAKE) -C $(ZLIB_DIR) clean
	-@rm -f $(TARGET_DIR)$(EPREFIX)/lib/libz*
	-@rm -f $(HOST_DIR)$(EPREFIX)/lib/libz*
	-@rm -f $(ZLIB_DIR)/.configured

zlib-dirclean:
	rm -rf $(ZLIB_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_ZLIB)),y)
TARGETS+=zlib
endif
