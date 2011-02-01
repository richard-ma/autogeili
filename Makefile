# 
#
#

build:

version:

clean:

install:
	install -d \
		$(DESTDIR)/usr/bin \
		$(DESTDIR)/usr/share/autogeili
	install -m 0644 icons/* $(DESTDIR)/usr/share/autogeili
	install -m 0755 autogeili.sh $(DESTDIR)/usr/bin

test:
