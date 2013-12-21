NAME=cpuinfo
all: version documentation build

# Builds the project. Since this is only a fake project, it just copies a script.
build:
	test ! -d ./bin && mkdir ./bin || exit 0
	sed "s/VERSION/$$(cat .version)/" src/$(NAME) > ./bin/$(NAME)
	chmod 755 ./bin/$(NAME)
	
# 'install' installes a fake-root, which will be used to build the Debian package
# $DESTDIR is actually set by the Debian tools.
install:
	test ! -d $(DESTDIR)/usr/bin && mkdir -p $(DESTDIR)/usr/bin || exit 0
	cp ./bin/* $(DESTDIR)/usr/bin

deinstall:
	test ! -z "$(DESTDIR)" && test -f $(DESTDIR)/usr/bin/$(NAME) && rm $(DESTDIR)/usr/bin/$(NAME) || exit 0

clean:
	test -d ./bin && rm -Rf ./bin || exit 0

# ADDITIONAL RULES:

# Parses the version out of the Debian changelog
version:
	cut -d' ' -f2 debian/changelog | head -n 1 | sed 's/(//;s/)//' > .version

# Builds the documentation into a manpage
documentation:
	pod2man --release="$(NAME) $$(cat .version)" \
		--center="User Commands" ./docs/$(NAME).pod > ./docs/$(NAME).1
	pod2text ./docs/$(NAME).pod > ./docs/$(NAME).txt

# Build a debian package (don't sign it, modify the arguments if you want to sign it)
deb: all
	dpkg-buildpackage 

dch: 
	dch -i

dput:
	dput -u wheezy-buetowdotorg ../$(NAME)_$$(cat ./.version)_amd64.changes

release: dch deb dput
	bash -c "git tag $$(cat .version)"
	git push --tags
	git commit -a -m 'New release'
	git push origin master

clean-top:
	rm ../$(NAME)_*.tar.gz
	rm ../$(NAME)_*.dsc
	rm ../$(NAME)_*.changes
	rm ../$(NAME)_*.deb

