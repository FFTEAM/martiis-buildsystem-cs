# basic clean rules. to be fixed up.
clean:
	make neutrino-clean

# rebuild all except the toolchain
rebuild-clean: clean
	-rm -rf $(TARGETPREFIX)
	-rm $(DEPDIR)/*

all-clean: rebuild-clean
	-rm -rf $(CROSS_BASE)
	-rm -rf $(HOSTPREFIX)

PHONY += clean rebuild-clean all-clean
