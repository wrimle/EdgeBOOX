ONYX_LIB_NAME=onyx-intl-booxsdk-3299a8a
ONYX_LIB_SOURCE=$(ONYX_LIB_NAME).tar.gz
ONYX_LIB_DIR=$(BUILD_DIR)/$(ONYX_LIB_NAME)

$(DL_DIR)/$(ONYX_LIB_SOURCE):
	mkdir -p $(DL_DIR)
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(ONYX_LIB_SOURCE)

$(ONYX_LIB_DIR)/.unpacked:$(DL_DIR)/$(ONYX_LIB_SOURCE)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) -zxf $(DL_DIR)/$(ONYX_LIB_SOURCE)
	$(PATCH) $(ONYX_LIB_DIR) packages/onyx $(ONYX_LIB_NAME).patch
	touch $(ONYX_LIB_DIR)/.unpacked

$(ONYX_LIB_DIR)/.configured:$(ONYX_LIB_DIR)/.unpacked
	(cd $(ONYX_LIB_DIR);\
	export QMAKESPEC=$(HOST_DIR)$(EPREFIX)/mkspecs/qws/linux-arm-g++/;\
	export PATH=$(HOST_DIR)$(EPREFIX)/bin:$(PATH);\
	cmake \
	-DBUILD_FOR_ARM:BOOL=ON \
	-DONYX_SDK_ROOT:PATH=$(EPREFIX) \
	.\
	);
	touch $(ONYX_LIB_DIR)/.configured

$(ONYX_LIB_DIR)/libs/libonyx_ui.so:$(ONYX_LIB_DIR)/.configured
	$(MAKE) -C $(ONYX_LIB_DIR) all


$(HOST_DIR)$(EPREFIX)/lib/libonyx_ui.so:$(ONYX_LIB_DIR)/libs/libonyx_ui.so
	cp -dpR $(ONYX_LIB_DIR)/code/include/onyx $(HOST_DIR)$(EPREFIX)/include/
	cp -dpf $(ONYX_LIB_DIR)/libs/*.so $(HOST_DIR)$(EPREFIX)/lib/
	touch -c $(HOST_DIR)$(EPREFIX)/lib/libonyx_ui.so

$(TARGET_DIR)$(EPREFIX)/lib/libonyx_ui.so:$(HOST_DIR)$(EPREFIX)/lib/libonyx_ui.so
	$(TARGET_STRIP) --strip-unneeded $(ONYX_LIB_DIR)/libs/*.so
	cp -dpf $(ONYX_LIB_DIR)/libs/*.so $(TARGET_DIR)$(EPREFIX)/lib/
	$(TARGET_STRIP) --strip-unneeded $(ONYX_LIB_DIR)/bin/*
	cp -dpf $(ONYX_LIB_DIR)/bin/* $(TARGET_DIR)$(EPREFIX)/bin/
	touch -c $(TARGET_DIR)$(EPREFIX)/lib/libonyx_ui.so

onyx-lib:qt onyx-cmake $(TARGET_DIR)$(EPREFIX)/lib/libonyx_ui.so

onyx-lib-source:$(DL_DIR)/$(ONYX_LIB_SOURCE)

onyx-lib-clean:
	-$(MAKE) -C $(ONYX_LIB_DIR) clean
	-@rm -f $(TARGET_DIR)$(EPREFIX)/lib/libonyx_ui.so
	-@rm -f $(HOST_DIR)$(EPREFIX)/lib/libonyx_ui.so
	-@rm -f $(ONYX_LIB_DIR)/.configured
onyx-lib-dirclean:
	rm -rf $(ONYX_LIB_DIR)


#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_ONYX_LIB)),y)
TARGETS+=onyx-lib
endif

