PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
SCRIPT  := kirasay
VERSION := 2.0.0
PKGDIR  := $(SCRIPT)-$(VERSION)
TARFILE := $(PKGDIR).tar.gz

.PHONY: all install uninstall test release clean help

all: help

help:
	@echo "KiraSay Makefile targets:"
	@echo "  make install [PREFIX=...] [DESTDIR=...]
	@echo "  make uninstall [PREFIX=...] [DESTDIR=...]
	@echo "  make test
	@echo "  make release
	@echo "  make clean

install:
	@echo "Installing $(SCRIPT) to $(DESTDIR)$(BINDIR)"
	install -d "$(DESTDIR)$(BINDIR)"
	install -m 0755 "$(SCRIPT)" "$(DESTDIR)$(BINDIR)/$(SCRIPT)"
	@echo "Installed $(SCRIPT) to $(DESTDIR)$(BINDIR)/$(SCRIPT)"

uninstall:
	@echo "Removing $(DESTDIR)$(BINDIR)/$(SCRIPT)"
	-rm -f "$(DESTDIR)$(BINDIR)/$(SCRIPT)"
	@echo "Removed $(SCRIPT) from $(DESTDIR)$(BINDIR) (if it existed)"

test:
	@echo "Running basic smoke test for $(SCRIPT)"
	@if [ ! -x "./$(SCRIPT)" ]; then \
	  echo "Executable ./$(SCRIPT) not found or not executable. Trying to chmod +x..."; \
	  chmod +x "./$(SCRIPT)" || true; \
	fi
	@./$(SCRIPT) "Kira test message" >/dev/null 2>&1 && echo "OK: $(SCRIPT) ran successfully" || (echo "FAILED: $(SCRIPT) did not run correctly"; exit 1)

release: clean
	@echo "Creating release $(TARFILE)"
	@mkdir -p "$(PKGDIR)"
	@cp -p "$(SCRIPT)" LICENSE README.md "$(PKGDIR)/" || true
	@tar -czf "$(TARFILE)" "$(PKGDIR)"
	@rm -rf "$(PKGDIR)"
	@echo "Created $(TARFILE)"
	@{ \
		if command -v sha256sum >/dev/null 2>&1; then \
			sha256sum "$(TARFILE)"; \
		else \
			shasum -a 256 "$(TARFILE)"; \
		fi \
	} > "$(TARFILE).sha256"
	@echo "Wrote checksum to $(TARFILE).sha256"

clean:
	@echo "Cleaning generated files"
	-rm -f "$(TARFILE)" "$(TARFILE).sha256"
	-rm -rf "$(PKGDIR)"

install-user:
	@mkdir -p "$(HOME)/bin"
	install -m 0755 "$(SCRIPT)" "$(HOME)/bin/$(SCRIPT)"
	@echo "Installed $(SCRIPT) to $(HOME)/bin/$(SCRIPT)"
