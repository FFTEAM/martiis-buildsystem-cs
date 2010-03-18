# basic clean rules. to be fixed up.
clean:
	make neutrino-clean

# rebuild all except the toolchain
rebuild-clean: clean
	-rm -rf $(TARGETPREFIX)
	-rm $(DEPDIR)/*

all-clean: rebuild-clean
	-rm -r $(CROSS_BASE)
	-rm -r $(HOSTPREFIX)

PHONY += clean rebuild-clean all-clean
