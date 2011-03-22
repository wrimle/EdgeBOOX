QT_SOURCE= qt-embedded-linux-opensource-src-4.5.2.tar.gz
QT_DIR= $(BUILD_DIR)/qt-embedded-linux-opensource-src-4.5.2
#QT_DOWNLOAD_SITE= "http://get.qt.nokia.com/qt/source"

$(DL_DIR)/$(QT_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(QT_SOURCE)

$(QT_DIR)/.unpacked:$(DL_DIR)/$(QT_SOURCE)
	tar -C $(BUILD_DIR) -zxf $(DL_DIR)/$(QT_SOURCE)
	touch $(QT_DIR)/.unpacked

$(QT_DIR)/.patched:$(QT_DIR)/.unpacked
	$(PATCH) $(QT_DIR) packages/qt qt\*.patch
	touch $(QT_DIR)/.patched

$(QT_DIR)/.configured:$(QT_DIR)/.patched
	(cd $(QT_DIR); \
		export QTDIR=$(QT_DIR); \
		export PKG_CONFIG_PATH=$(HOST_DIR)$(EPREFIX)/lib/pkgconfig; \
		echo QMAKE_INCDIR=$(HOST_DIR)$(EPREFIX)/include >> $(QT_DIR)/mkspecs/qws/linux-arm-g++/qmake.conf; \
		echo QMAKE_LIBDIR=$(HOST_DIR)$(EPREFIX)/lib >> $(QT_DIR)/mkspecs/qws/linux-arm-g++/qmake.conf; \
		(echo o;echo yes) | ./configure \
			-prefix $(EPREFIX) \
			-release \
			-shared \
			-no-largefile \
			-no-exceptions \
			-no-accessibility \
			-stl \
			-no-qt3support \
			-no-phonon \
			-no-svg \
			-no-pch \
			-webkit \
			-xplatform qws/linux-arm-g++ \
			-embedded arm \
			-qt-zlib \
			-qt-gif \
			-qt-libtiff \
			-qt-libpng \
			-qt-libmng \
			-qt-libjpeg \
			-no-nis \
			-no-cups \
			-dbus \
			-qt-freetype \
			-depths 8 \
			-qt-decoration-windows \
			-plugin-gfx-transformed \
			-no-glib \
			-nomake tools \
			-nomake examples \
			-nomake demos \
			-force-pkg-config \
	);
	touch $(QT_DIR)/.configured

$(QT_DIR)/lib/libQtCore.so.4.5.2:$(QT_DIR)/.configured
	$(MAKE) -C $(QT_DIR)
	touch $(QT_DIR)/lib/libQtCore.so.4.5.2

$(HOST_DIR)$(EPREFIX)/lib/libQtCore.so.4.5.2:$(QT_DIR)/lib/libQtCore.so.4.5.2
	$(MAKE) INSTALL_ROOT=$(HOST_DIR) -C $(QT_DIR) install
	touch -c $(HOST_DIR)$(EPREFIX)/lib/libQtCore.so.4.5.2

$(TARGET_DIR)$(EPREFIX)/lib/libQtCore.so.4.5.2:$(HOST_DIR)$(EPREFIX)/lib/libQtCore.so.4.5.2
	cp -dpf $(HOST_DIR)$(EPREFIX)/lib/libQt*.so* $(TARGET_DIR)$(EPREFIX)/lib
	-$(TARGET_STRIP) --strip-unneeded $(TARGET_DIR)$(EPREFIX)/lib/libQt*.so*
	cp -dpR $(HOST_DIR)$(EPREFIX)/plugins $(TARGET_DIR)$(EPREFIX)
	mkdir -p $(TARGET_DIR)$(EPREFIX)/lib/fonts
	cp -dpf $(HOST_DIR)$(EPREFIX)/lib/fonts/*.ttf $(TARGET_DIR)$(EPREFIX)/lib/fonts
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/libQtCore.so.4.5.2

qt:dbus tslib openssl $(TARGET_DIR)$(EPREFIX)/lib/libQtCore.so.4.5.2

qt-source:$(DL_DIR)/$(QT_SOURCE)

qt-clean:
	-$(MAKE) -C $(QT_DIR) clean
	-@rm -f $(TARGET_DIR)$(EPREFIX)/lib/libQt*
	-@rm -rf $(TARGET_DIR)$(EPREFIX)/lib/fonts
	-@rm -f $(HOST_DIR)$(EPREFIX)/lib/libQt* 
	-@rm -f $(QT_DIR)/.configured

qt-dirclean:
	rm -rf $(QT_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_QT)),y)
TARGETS+=qt
endif
