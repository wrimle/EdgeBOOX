#############################################################
#
# Onyx cmake modules
#
#############################################################
ONYX_CMAKE_NAME=onyx-intl-cmake_modules-1e3ba82
ONYX_CMAKE_SOURCE=$(ONYX_CMAKE_NAME).tar.gz
ONYX_CMAKE_HOST_DIR	:=	$(HOST_DIR)$(EPREFIX)/$(ONYX_CMAKE_NAME)

$(DL_DIR)/$(ONYX_CMAKE_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(ONYX_CMAKE_SOURCE)

$(ONYX_CMAKE_HOST_DIR)/.unpacked: $(DL_DIR)/$(ONYX_CMAKE_SOURCE)
	tar -C $(HOST_DIR)$(EPREFIX) -xzf $(DL_DIR)/$(ONYX_CMAKE_SOURCE)
	$(PATCH) $(ONYX_CMAKE_HOST_DIR) packages/onyx onyx-cmake\*.patch
	(cd $(HOST_DIR)$(EPREFIX);ln -s $(ONYX_CMAKE_NAME) cmake_modules)
	touch $(ONYX_CMAKE_HOST_DIR)/.unpacked

onyx-cmake: $(ONYX_CMAKE_HOST_DIR)/.unpacked

onyx-cmake-host-clean:
	rm -rf $(ONYX_CMAKE_HOST_DIR)
