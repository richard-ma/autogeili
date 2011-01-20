# 
#
#

build:

version:

clean:

install:
	mkdir -p ~/.autogeili
	mkdir -p $(DESTDIR)/usr/share/autogeili
	install -m 0644 ./icons/* $(DESTDIR)/usr/share/autogeili
	install ./autogeili.sh $(DESTDIR)/usr/bin

test:
