######################################################################
#
# Check buildroot dependencies and bail out if the user's
# system is judged to be lacking....
#
######################################################################

dependencies: hostdeps target-skel

hostdeps:
	@HOSTCC="$(firstword $(HOSTCC))" MAKE="$(MAKE)" \
		$(BASE_DIR)/packages/dependencies/dependencies.sh

target-skel: onyx-binaries
	# This seems to work better here
	# Every time you issue MAKE lets clean out the rootfs directory and rebuild.
	rm -rf $(BUILD_DIR)/root/*
	zcat $(TARGET_SKELETON) | tar -C $(BUILD_DIR) -xf -
	cp -dpR $(TARGET_SKEL_DIR)/* $(TARGET_DIR)/
	cp -dpR $(ONYX_BINARIES_DIR)/* $(TARGET_DIR)/
	echo "export VERSION=\"$(BOOX_VERSION) $(shell date +"%Y%m%d")\"" >> $(TARGET_DIR)/etc/version
	-find $(TARGET_DIR) -type d -name CVS | xargs rm -rf

dependencies-source:

dependencies-clean:
	rm -f $(SSTRIP_TARGET)

dependencies-dirclean:
	true

#############################################################
#
# Toplevel Makefile options
#
#############################################################
.PHONY: dependencies hostdeps
