#############################################################
#
# dbus
#
#############################################################

DBUS_SOURCE=dbus-1.2.16.tar.gz
DBUS_DIR:=$(BUILD_DIR)/dbus-1.2.16

$(DL_DIR)/$(DBUS_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(DBUS_SOURCE)

dbus-source: $(DL_DIR)/$(DBUS_SOURCE)

$(DBUS_DIR)/.unpacked: $(DL_DIR)/$(DBUS_SOURCE)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(DBUS_SOURCE)
#	$(PATCH) $(DBUS_DIR) $(BASE_DIR)/packages/dbus/ \*.patch*
	touch $(DBUS_DIR)/.unpacked

$(DBUS_DIR)/.configured: $(DBUS_DIR)/.unpacked
	(cd $(DBUS_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
		--target=arm-none-linux-gnueabi \
		--host=arm-none-linux-gnueabi \
		--build=$(GNU_HOST_NAME) \
		--prefix=/ \
		--exec-prefix=$(EPREFIX) \
		--sysconfdir=$(EPREFIX)/etc \
		--includedir=$(EPREFIX)/include \
		--localstatedir=/var \
		--datarootdir=/usr/share \
		--enable-shared \
		--enable-inotify \
		--without-x \
		--with-xml=expat \
		--with-dbus-user=root \
		--with-system-pid-file=/var/run/dbus/pid \
		--with-system-socket=/var/run/dbus/system_bus_socket \
	);
	touch  $(DBUS_DIR)/.configured

$(DBUS_DIR)/dbus/.libs/libdbus-1.so.3.4.0: $(DBUS_DIR)/.configured
	$(MAKE) -C $(DBUS_DIR) all
	touch -c $(DBUS_DIR)/dbus/.libs/libdbus-1.so.3.4.0

$(HOST_DIR)$(EPREFIX)/lib/libdbus-1.so.3.4.0: $(DBUS_DIR)/dbus/.libs/libdbus-1.so.3.4.0
	$(MAKE) DESTDIR=$(HOST_DIR) -C $(DBUS_DIR) install

	mv $(HOST_DIR)$(EPREFIX)/lib/libdbus-1.la $(HOST_DIR)$(EPREFIX)/lib/libdbus-1.la.old
	$(SED) "s,^libdir=.*,libdir=\'$(HOST_DIR)$(EPREFIX)/lib\',g" $(HOST_DIR)$(EPREFIX)/lib/libdbus-1.la.old > $(HOST_DIR)$(EPREFIX)/lib/libdbus-1.la

	touch -c $(HOST_DIR)$(EPREFIX)/lib/libdbus-1.so.3.4.0

$(TARGET_DIR)$(EPREFIX)/lib/libdbus-1.so.3.4.0: $(HOST_DIR)$(EPREFIX)/lib/libdbus-1.so.3.4.0
	cp -dpf $(HOST_DIR)$(EPREFIX)/lib/libdbus-1.so* $(TARGET_DIR)$(EPREFIX)/lib/
	-$(TARGET_STRIP) --strip-unneeded $(TARGET_DIR)$(EPREFIX)/lib/libdbus-1.so.3.4.0
	cp -dpf $(HOST_DIR)$(EPREFIX)/bin/dbus-* $(TARGET_DIR)$(EPREFIX)/bin/
	-$(TARGET_STRIP) --strip-unneeded $(TARGET_DIR)$(EPREFIX)/bin/dbus-*
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/libdbus-1.so.3.4.0

dbus: expat $(TARGET_DIR)$(EPREFIX)/lib/libdbus-1.so.3.4.0

dbus-clean:
	rm -f $(DBUS_DIR)/.configured
	rm -f $(HOST_DIR)$(EPREFIX)/lib/libdbus-1.* $(TARGET_DIR)$(EPREFIX)/lib/libdbus-1.*
	rm -f $(HOST_DIR)$(EPREFIX)/bin/dbus-* $(TARGET_DIR)$(EPREFIX)/bin/dbus-*
	-$(MAKE) -C $(DBUS_DIR) clean
