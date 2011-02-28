#############################################################
#
# curl
#
#############################################################
CURL_SOURCE:=curl-7.19.7.tar.bz2
CURL_DIR:=$(BUILD_DIR)/curl-7.19.7

$(DL_DIR)/$(CURL_SOURCE):
	 $(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(CURL_SOURCE)

curl-source: $(DL_DIR)/$(CURL_SOURCE)

$(CURL_DIR)/.unpacked: $(DL_DIR)/$(CURL_SOURCE)
	tar -C $(BUILD_DIR) -xjf $(DL_DIR)/$(CURL_SOURCE)
	touch $(CURL_DIR)/.unpacked

$(CURL_DIR)/.configured: $(CURL_DIR)/.unpacked
	(cd $(CURL_DIR); rm -rf config.cache; \
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
		--with-zlib=$(HOST_DIR)$(EPREFIX) \
		--without-libidn \
		--without-ssl \
		--without-krb4 \
		--without-libssh2 \
		--without-gnutls \
		--without-ca-bundle \
		--without-gssapi \
		--without-spnego \
		--without-ldap \
	);
	touch $(CURL_DIR)/.configured

$(CURL_DIR)/lib/.libs/libcurl.so: $(CURL_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(CURL_DIR)
	touch -c $(CURL_DIR)/lib/.libs/libcurl.so

$(HOST_DIR)$(EPREFIX)/lib/libcurl.so: $(CURL_DIR)/lib/.libs/libcurl.so
	$(MAKE) DESTDIR=$(HOST_DIR) -C $(CURL_DIR) install

	mv $(HOST_DIR)$(EPREFIX)/lib/libcurl.la $(HOST_DIR)$(EPREFIX)/lib/libcurl.la.old
	$(SED) "s,^libdir=.*,libdir=\'$(HOST_DIR)$(EPREFIX)/lib\',g" $(HOST_DIR)$(EPREFIX)/lib/libcurl.la.old > $(HOST_DIR)$(EPREFIX)/lib/libcurl.la

	touch -c $(HOST_DIR)$(EPREFIX)/lib/libcurl.so

$(TARGET_DIR)$(EPREFIX)/lib/libcurl.so: $(HOST_DIR)$(EPREFIX)/lib/libcurl.so
	cp -dpR $(HOST_DIR)$(EPREFIX)/lib/libcurl.so* $(TARGET_DIR)$(EPREFIX)/lib
	-$(TARGET_STRIP) $(TARGET_DIR)$(EPREFIX)/lib/libcurl.so*
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/libcurl.so

curl: zlib $(TARGET_DIR)$(EPREFIX)/lib/libcurl.so

curl-clean:
	$(MAKE) DESTDIR=$(HOST_DIR) CC=$(TARGET_CC) -C $(CURL_DIR) uninstall
	-$(MAKE) -C $(CURL_DIR) clean
	-@rm -f $(TARGET_DIR)$(EPREFIX)/lib/libcurl.so*

curl-dirclean:
	rm -rf $(CURL_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_CURL)),y)
TARGETS+=curl
endif
