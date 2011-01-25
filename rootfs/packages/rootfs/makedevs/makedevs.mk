#############################################################
#
# build makedevs to run on the build system, in order to create
# device nodes and whatnot for the target device, in conjunction
# with fakeroot.
#
#############################################################
MAKEDEVS_DIR=$(BUILD_DIR)/makedevs

$(MAKEDEVS_DIR)/makedevs.c: packages/rootfs/makedevs/makedevs.c
	rm -rf $(MAKEDEVS_DIR)
	mkdir $(MAKEDEVS_DIR)
	cp packages/rootfs/makedevs/makedevs.c $(MAKEDEVS_DIR)

$(MAKEDEVS_DIR)/makedevs: $(MAKEDEVS_DIR)/makedevs.c
	gcc -Wall -O2 $(MAKEDEVS_DIR)/makedevs.c -o $(MAKEDEVS_DIR)/makedevs
	touch -c $(MAKEDEVS_DIR)/makedevs

$(HOST_DIR)/usr/bin/makedevs: $(MAKEDEVS_DIR)/makedevs
	$(INSTALL) -m 755 $(MAKEDEVS_DIR)/makedevs $(HOST_DIR)/usr/bin/makedevs
	touch -c $(HOST_DIR)/usr/bin/makedevs

makedevs: $(HOST_DIR)/usr/bin/makedevs

makedevs-source:

makedevs-clean:
	-rm -rf $(MAKEDEVS_DIR)

makedevs-dirclean:
	rm -rf $(MAKEDEVS_DIR)

