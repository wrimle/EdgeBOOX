######################################################################
#
# gdb
#
######################################################################
GDB_SOURCE:=gdb-7.0.1.tar.bz2
GDB_DIR:=$(BUILD_DIR)/gdb-7.0.1
GDB_DOWNLOAD_SITE:="ftp://ftp.gnu.org/gnu/gdb"

$(DL_DIR)/$(GDB_SOURCE):
	$(WGET) -P $(DL_DIR) $(GDB_DOWNLOAD_SITE)/$(GDB_SOURCE)

gdb-source:$(DL_DIR)/$(GDB_SOURCE)

$(GDB_DIR)/.unpacked: $(DL_DIR)/$(GDB_SOURCE)
	tar -xjf $(DL_DIR)/$(GDB_SOURCE) -C $(BUILD_DIR) 
	touch $(GDB_DIR)/.unpacked

gdb-dirclean:
	rm -rf $(GDB_DIR)

######################################################################
#
# gdbserver
#
######################################################################

GDB_SERVER_DIR:=$(BUILD_DIR)/gdbserver-7.0.1

$(GDB_SERVER_DIR)/.configured: $(GDB_DIR)/.unpacked
	mkdir -p $(GDB_SERVER_DIR)
	(cd $(GDB_SERVER_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		gdb_cv_func_sigsetjmp=yes \
		$(GDB_DIR)/gdb/gdbserver/configure \
		--host=i386 \
		--target=arm-linux \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libexecdir=/usr/lib \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--mandir=/usr/man \
		--infodir=/usr/info \
		--includedir=$(HOST_DIR)/include \
		$(DISABLE_NLS) \
		--without-uiout \
		--disable-tui --disable-gdbtk --without-x \
		--without-included-gettext \
	);
	touch  $(GDB_SERVER_DIR)/.configured

$(GDB_SERVER_DIR)/gdbserver: $(GDB_SERVER_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) \
		-C $(GDB_SERVER_DIR)
	$(TARGET_STRIP) $(GDB_SERVER_DIR)/gdbserver

$(TARGET_DIR)/usr/bin/gdbserver: $(GDB_SERVER_DIR)/gdbserver
	cp -dpf $(GDB_SERVER_DIR)/gdbserver $(TARGET_DIR)/usr/bin/gdbserver
#	cp -dpR $(TOOLCHAIN_DIR)/arm-none-linux-gnueabi/libc/marvell-f/lib/libthread_db*so* $(TARGET_DIR)/lib
	touch -c $(TARGET_DIR)/usr/bin/gdbserver

gdb_server:$(TARGET_DIR)/usr/bin/gdbserver

gdb_server-clean:
	@if [ -r $(GDB_SERVER_DIR)/Makefile ] ; then \
		$(MAKE) -C $(GDB_SERVER_DIR) clean ; \
	fi;
	-@rm -f $(TARGET_DIR)/usr/bin/gdbserver
	-@rm -f $(TARGET_DIR)/lib/libthread_db*so*

gdb_server-dirclean:
	rm -rf $(GDB_SERVER_DIR)

######################################################################
#
# gdb on host
#
######################################################################

GDB_HOST_DIR:=$(BUILD_DIR)/gdbhost-7.0.1

$(GDB_HOST_DIR)/.configured: $(GDB_DIR)/.unpacked
	mkdir -p $(GDB_HOST_DIR)
	(cd $(GDB_HOST_DIR); \
		gdb_cv_func_sigsetjmp=yes \
		bash_cv_have_mbstate_t=yes \
		$(GDB_DIR)/configure \
		--prefix=$(HOST_DIR)/usr \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--disable-nls \
		--without-uiout \
		--disable-tui --disable-gdbtk --without-x \
		--without-included-gettext \
		--enable-threads \
	);
	touch  $(GDB_HOST_DIR)/.configured

$(GDB_HOST_DIR)/.built: $(GDB_HOST_DIR)/.configured
	$(MAKE) -C $(GDB_HOST_DIR)
	strip $(GDB_HOST_DIR)/gdb/gdb
	touch $(GDB_HOST_DIR)/.built

$(GDB_HOST_DIR)/.installed: $(GDB_HOST_DIR)/.built
	cp -dpf $(GDB_HOST_DIR)/gdb/gdb $(HOST_DIR)/usr/bin/gdb
#	ln -snf $(TARGET_CROSS)gdb $(HOST_DIR)/bin/gdb
	touch  $(GDB_HOST_DIR)/.installed
	
gdb_host: $(GDB_HOST_DIR)/.installed

gdb_host-clean:
	@if [ -r $(GDB_HOST_DIR)/Makefile ] ; then \
		$(MAKE) -C $(GDB_HOST_DIR) clean ; \
	fi;
	-@rm -f $(GDB_HOST_DIR)/.built

gdb_host-dirclean:
	rm -rf $(GDB_HOST_DIR)


#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(PACKAGE_GDB_SERVER)),y)
TARGETS+=gdb_server
endif
ifeq ($(strip $(PACKAGE_GDB_HOST)),y)
TARGETS+=gdb_host
endif
