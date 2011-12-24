# example for own targets for simple tools

# this is the most trivial example:
# * only one source file
# * no configure / automake / anything
# The source file is kept in the patch directory simply to
# not add another directory for this single file
#
example: $(PATCHES)/hello-world.c | $(TARGETPREFIX)
	# make sure that the build directory is clean by removing and recreating it
	rm -rf $(BUILD_TMP)/example
	mkdir $(BUILD_TMP)/example
	# copy the source into the directory. in real live, you would probably unpack your tarball here
	cp $(PATCHES)/hello-world.c $(BUILD_TMP)/example
	set -e; cd $(BUILD_TMP)/example; \
		: compile the stuff. again, in real life this would be a "configure, make make install"; \
		$(TARGET)-gcc -W -Wall $(TARGET_CFLAGS) $(TARGET_LDFLAGS) hello-world.c -o hello-world; \
		: install into TARGETPREFIX; \
		cp -a hello-world $(TARGETPREFIX)/bin
	# clean up after ourselves. REMOVE is the same as "rm -rf $(BUILD_TMP)"
	$(REMOVE)/example
