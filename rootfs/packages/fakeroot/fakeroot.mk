#############################################################
#
# fakeroot
#
#############################################################
FAKEROOT_SOURCE:=fakeroot_1.11.tar.gz
FAKEROOT_DIR:=$(BUILD_DIR)/fakeroot-1.11
#FAKEROOT_DOWNLOAD_SITE:="ftp://ftp.debian.org/debian/pool/main/f/fakeroot"

$(DL_DIR)/$(FAKEROOT_SOURCE):
	 $(WGET) -P $(DL_DIR) $(DOWNLOAD_SITE)/$(FAKEROOT_SOURCE)

#############################################################
#
# build fakeroot for use on the host system
#
#############################################################
$(FAKEROOT_DIR)/.unpacked: $(DL_DIR)/$(FAKEROOT_SOURCE)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(FAKEROOT_SOURCE)

	$(SED) "s,getopt --version,getopt --version 2>/dev/null," \
		$(FAKEROOT_DIR)/scripts/fakeroot.in

	touch $(FAKEROOT_DIR)/.unpacked

$(FAKEROOT_DIR)/.configured: $(FAKEROOT_DIR)/.unpacked
	(cd $(FAKEROOT_DIR); rm -rf config.cache; \
		./configure \
		--prefix=/usr \
		--with-ipc=tcp \
	);
	touch  $(FAKEROOT_DIR)/.configured

$(FAKEROOT_DIR)/faked: $(FAKEROOT_DIR)/.configured

	mv $(FAKEROOT_DIR)/Makefile $(FAKEROOT_DIR)/Makefile.fakeroot
	$(SED) 's/doc test/test/'  $(FAKEROOT_DIR)/Makefile.fakeroot > $(FAKEROOT_DIR)/Makefile

	$(MAKE) -C $(FAKEROOT_DIR)

$(HOST_DIR)/usr/bin/fakeroot: $(FAKEROOT_DIR)/faked
	$(MAKE) DESTDIR=$(HOST_DIR) -C $(FAKEROOT_DIR) install
	$(SED) 's,^PREFIX=.*,PREFIX=$(HOST_DIR)/usr,g' $(HOST_DIR)/usr/bin/fakeroot
	$(SED) 's,^BINDIR=.*,BINDIR=$(HOST_DIR)/usr/bin,g' $(HOST_DIR)/usr/bin/fakeroot
	$(SED) 's,^PATHS=.*,PATHS=$(FAKEROOT_DIR)/.libs:/lib:/usr/lib,g' $(HOST_DIR)/usr/bin/fakeroot

fakeroot: $(HOST_DIR)/usr/bin/fakeroot

fakeroot-source: $(DL_DIR)/$(FAKEROOT_SOURCE)

fakeroot-clean:
	-$(MAKE) -C $(FAKEROOT_DIR) clean
	-@rm -f $(FAKEROOT_DIR)/.configured

fakeroot-dirclean:
	rm -rf $(FAKEROOT_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_FAKEROOT)),y)
TARGETS+=fakeroot
endif
