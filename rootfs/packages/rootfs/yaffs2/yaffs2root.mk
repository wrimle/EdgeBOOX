#############################################################
#
# Build the yaffs2 root filesystem image
#
#############################################################

YAFFS2_IMAGE_LOCATION=$(BASE_DIR)/images

IMAGE_LOCATION:=$(strip $(subst ",, $(DEFAULT_PACKAGE_BSP)))

ifeq ($(IMAGE_LOCATION),)
	IMAGE_LOCATION:=custom
endif

YAFFS2_TARGET :=$(YAFFS2_IMAGE_LOCATION)/$(IMAGE_LOCATION)/rootfs.yaffs2

$(YAFFS2_TARGET): fakeroot makedevs mkyaffs2image
	mkdir -p $(YAFFS2_IMAGE_LOCATION)
	mkdir -p $(YAFFS2_IMAGE_LOCATION)/$(IMAGE_LOCATION)
	-@find $(TARGET_DIR) -type f -perm +111 | xargs $(STRIP) 2>/dev/null || true;
	@rm -rf $(TARGET_DIR)/usr/man
	@rm -rf $(TARGET_DIR)/usr/share/man
	@rm -rf $(TARGET_DIR)/usr/info
	test -e "$(TARGET_DIR)/etc/ld.so.conf" \
		&& /sbin/ldconfig -r $(TARGET_DIR) \
		|| true
	-rm -f $(YAFFS2_IMAGE_LOCATION)/fakeroot.env.00000
	# Use fakeroot to pretend all target binaries are owned by root
	$(HOST_DIR)/usr/bin/fakeroot \
		-l $(HOST_DIR)/usr/lib/libfakeroot-0.so \
		-f $(HOST_DIR)/usr/bin/faked \
		-i $(YAFFS2_IMAGE_LOCATION)/fakeroot.env.00000 \
		-s $(YAFFS2_IMAGE_LOCATION)/fakeroot.env.00000 -- \
		chown -R root:root $(TARGET_DIR)
	# Use fakeroot to pretend to create all needed device nodes
	$(HOST_DIR)/usr/bin/fakeroot \
		-l $(HOST_DIR)/usr/lib/libfakeroot-0.so \
		-f $(HOST_DIR)/usr/bin/faked \
		-i $(YAFFS2_IMAGE_LOCATION)/fakeroot.env.00000 \
		-s $(YAFFS2_IMAGE_LOCATION)/fakeroot.env.00000 -- \
		$(HOST_DIR)/usr/bin/makedevs \
		-d $(TARGET_DEVICE_TABLE) \
		$(TARGET_DIR)
	# Use fakeroot so mkyaffs2image believes the previous fakery
	$(HOST_DIR)/usr/bin/fakeroot \
		-l $(HOST_DIR)/usr/lib/libfakeroot-0.so \
		-f $(HOST_DIR)/usr/bin/faked \
		-i $(YAFFS2_IMAGE_LOCATION)/fakeroot.env.00000 \
		-s $(YAFFS2_IMAGE_LOCATION)/fakeroot.env.00000 -- \
		$(HOST_DIR)/usr/bin/mkyaffs2image \
		$(BUILD_DIR)/root \
		$(YAFFS2_TARGET) > rootfs.log 2>&1
	@ls -l $(YAFFS2_TARGET)

YAFFS2_COPYTO := $(strip $(subst ",,$(TARGET_ROOTFS_YAFFS2_COPYTO)))

yaffs2root: $(YAFFS2_TARGET)
ifneq ($(YAFFS2_COPYTO),)
	@cp -f $(YAFFS2_TARGET) $(YAFFS2_COPYTO)
endif

BOOX_UPDATE_TARGET :=$(YAFFS2_IMAGE_LOCATION)/$(IMAGE_LOCATION)/update
PACKAGE_DIR := $(YAFFS2_IMAGE_LOCATION)/packaging

$(PACKAGE_DIR)/.unpacked: packages/rootfs/yaffs2/packaging.tar.gz
	mkdir -p $(PACKAGE_DIR)
	tar -C $(PACKAGE_DIR) -xzf packages/rootfs/yaffs2/packaging.tar.gz
	touch $(PACKAGE_DIR)/.unpacked

$(BOOX_UPDATE_TARGET): linux yaffs2root aescrypt $(PACKAGE_DIR)/.unpacked
	echo "$(BOOX_VERSION) $(shell date +"%Y%m%d")" > $(PACKAGE_DIR)/onyx_update/version
	@if [ "$(TARGET_ROOTFS_YAFFS2_BOOX_UPDATE_KERNEL)" == "y" ] ; then \
		cp -dpf $(ZIMAGE_TARGET)/zImage $(PACKAGE_DIR)/onyx_update/images; \
		cp -dpf packages/rootfs/yaffs2/zImage-initramfs $(PACKAGE_DIR)/onyx_update/images; \
	else \
		rm -f $(PACKAGE_DIR)/onyx_update/images/zImage*; \
	fi;
	@cp -dpf $(YAFFS2_TARGET) $(PACKAGE_DIR)/opt/freescale/ltib
	(cd $(PACKAGE_DIR);tar --owner=root --group=root -czf $(PACKAGE_DIR)/onyx_update/images/rootfs.tar.gz opt/)
	(cd $(PACKAGE_DIR);tar --owner=root --group=root -czf $(BOOX_UPDATE_TARGET) onyx_update/)
	-@$(HOST_DIR)/usr/bin/aescrypt -e -p a8wZ49?b -o $(BOOX_UPDATE_TARGET).upd $(BOOX_UPDATE_TARGET)

yaffs2root-source: mkyaffs2image-source

yaffs2root-clean: mkyaffs2image-clean
	-rm -f $(YAFFS2_TARGET)

yaffs2root-dirclean: yaffs2-dirclean
	-rm -f $(YAFFS2_TARGET)

yaffs2booxupdate: $(BOOX_UPDATE_TARGET)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(TARGET_ROOTFS_YAFFS2)),y)
TARGETS+=yaffs2root
endif

ifeq ($(strip $(TARGET_ROOTFS_YAFFS2_BOOX_UPDATE)),y)
TARGETS+=yaffs2booxupdate
endif
