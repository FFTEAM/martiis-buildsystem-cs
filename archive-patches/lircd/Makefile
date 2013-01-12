all: ../lircd_spark.conf $(wildcard ../lircd_spark.conf.09*)

../lircd_spark.conf ../lircd_spark.conf.%: $(wildcard */*)
	DST=$@ ; \
	ID="$${DST#../lircd_spark.conf.}" ; \
	cp /dev/null $$DST ; \
	for A in */./ ; do \
		if [ -f "$$A/$$ID" ] ; then cat $$A/$$ID >> $$DST ; elif [ -f "$$A/all" ] ; then cat $$A/all >> $$DST ; fi \
	done

