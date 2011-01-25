OPENSSL_SOURCE:=openssl-0.9.7m.tar.gz
OPENSSL_DIR:=$(BUILD_DIR)/openssl-0.9.7m
#OPENSSL_DOWNLOAD_SITE:="ftp://ftp.openssl.org/source/"

$(DL_DIR)/$(OPENSSL_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(OPENSSL_SOURCE)

$(OPENSSL_DIR)/.unpacked:$(DL_DIR)/$(OPENSSL_SOURCE)
	tar -C $(BUILD_DIR) -zxf $(DL_DIR)/$(OPENSSL_SOURCE)
	touch $(OPENSSL_DIR)/.unpacked

$(OPENSSL_DIR)/.patched:$(OPENSSL_DIR)/.unpacked
	touch $(OPENSSL_DIR)/.patched

$(OPENSSL_DIR)/.configured:$(OPENSSL_DIR)/.patched
	(cd $(OPENSSL_DIR); \
		CC=arm-none-linux-gnueabi-gcc ./Configure \
			--prefix=$(EPREFIX) \
			--openssldir=$(EPREFIX)/lib \
			no-threads \
			shared \
			no-idea \
			no-mdc2 \
			no-rc5 \
			linux-elf-arm\
			-L$(HOST_DIR)/lib -lgcc \
	);
	touch $(OPENSSL_DIR)/.configured

$(OPENSSL_DIR)/libssl.so.0.9.7:$(OPENSSL_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(OPENSSL_DIR)


$(HOST_DIR)$(EPREFIX)/lib/libssl.so.0.9.7:$(OPENSSL_DIR)/libssl.so.0.9.7
	$(MAKE) INSTALL_PREFIX=$(HOST_DIR) -C $(OPENSSL_DIR) install
	touch -c $(HOST_DIR)$(EPREFIX)/lib/libssl.so.0.9.7
	touch -c $(HOST_DIR)$(EPREFIX)/lib/libcrypto.so.0.9.7


$(TARGET_DIR)$(EPREFIX)/lib/libssl.so.0.9.7:$(HOST_DIR)$(EPREFIX)/lib/libssl.so.0.9.7
	cp -dpf $(HOST_DIR)$(EPREFIX)/lib/libssl.so* $(TARGET_DIR)$(EPREFIX)/lib
	chmod 0755 $(TARGET_DIR)$(EPREFIX)/lib/libssl.so.0.9.7
	-$(TARGET_STRIP) --strip-unneeded $(TARGET_DIR)$(EPREFIX)/lib/libssl.so.0.9.7
	cp -dpR $(HOST_DIR)$(EPREFIX)/lib/libcrypto.so* $(TARGET_DIR)$(EPREFIX)/lib
	chmod 0755 $(TARGET_DIR)$(EPREFIX)/lib/libcrypto.so.0.9.7
	-$(TARGET_STRIP) --strip-unneeded $(TARGET_DIR)$(EPREFIX)/lib/libcrypto.so.0.9.7
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/libssl.so.0.9.7
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/libcrypto.so.0.9.7


openssl:$(TARGET_DIR)$(EPREFIX)/lib/libssl.so.0.9.7

openssl-source:$(DL_DIR)/$(OPENSSL_SOURCE)

openssl-clean:
	-$(MAKE) -C $(OPENSSL_DIR) clean
	-@rm -f $(TARGET_DIR)$(EPREFIX)/lib/libssl.so*
	-@rm -f $(TARGET_DIR)$(EPREFIX)/lib/libcrypto.so*
	-@rm -f $(OPENSSL_DIR)/.configured

openssl-dirclean:
	rm -rf $(OPENSSL_DIR)
	

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_OPENSSL)),y)
TARGETS+=openssl
endif
