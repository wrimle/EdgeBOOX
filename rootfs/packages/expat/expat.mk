#############################################################
#
# expat
#
#############################################################
EXPAT_SOURCE=expat-2.0.1.tar.gz
EXPAT_DIR:=$(BUILD_DIR)/expat-2.0.1

$(DL_DIR)/$(EXPAT_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(EXPAT_SOURCE)

$(EXPAT_DIR)/.unpacked: $(DL_DIR)/$(EXPAT_SOURCE)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(EXPAT_SOURCE)
	touch $(EXPAT_DIR)/.unpacked

$(EXPAT_DIR)/.configured: $(EXPAT_DIR)/.unpacked
	(cd $(EXPAT_DIR); rm -rf config.cache; \
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
		--enable-shared \
	);
	touch  $(EXPAT_DIR)/.configured

$(EXPAT_DIR)/.libs/libexpat.a: $(EXPAT_DIR)/.configured
	$(MAKE) -C $(EXPAT_DIR) all
	touch -c $(EXPAT_DIR)/.libs/libexpat.a

$(HOST_DIR)$(EPREFIX)/lib/libexpat.so.1: $(EXPAT_DIR)/.libs/libexpat.a
	$(MAKE) DESTDIR=$(HOST_DIR) -C $(EXPAT_DIR) install
	
	mv $(HOST_DIR)$(EPREFIX)/lib/libexpat.la $(HOST_DIR)$(EPREFIX)/lib/libexpat.la.old
	$(SED) "s,^libdir=.*,libdir=\'$(HOST_DIR)$(EPREFIX)/lib\',g" $(HOST_DIR)$(EPREFIX)/lib/libexpat.la.old > $(HOST_DIR)$(EPREFIX)/lib/libexpat.la

	touch -c $(HOST_DIR)$(EPREFIX)/lib/libexpat.so.1

$(TARGET_DIR)$(EPREFIX)/lib/libexpat.so.1: $(HOST_DIR)$(EPREFIX)/lib/libexpat.so.1
	cp -dpf $(HOST_DIR)$(EPREFIX)/lib/libexpat.so* $(TARGET_DIR)$(EPREFIX)/lib/
	-$(TARGET_STRIP) --strip-unneeded $(TARGET_DIR)$(EPREFIX)/lib/libexpat.so.1.5.2
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/libexpat.so.1

expat: $(TARGET_DIR)$(EPREFIX)/lib/libexpat.so.1

expat-source: $(DL_DIR)/$(EXPAT_SOURCE)

expat-clean:
	-$(MAKE) -C $(EXPAT_DIR) clean
	-rm -f $(EXPAT_DIR)/.configured
	-rm -f $(HOST_DIR)$(EPREFIX)/lib/libexpat.* $(TARGET_DIR)$(EPREFIX)/lib/libexpat.*

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_EXPAT)),y)
TARGETS+=expat
endif
