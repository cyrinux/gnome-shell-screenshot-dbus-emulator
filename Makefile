BIN := gnome-shell-screenshot-dbus-emulator
VERSION := $(shell git describe --long --tags | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g')

PREFIX ?= /usr
LIB_DIR = $(DESTDIR)$(PREFIX)/lib
BIN_DIR = $(DESTDIR)$(PREFIX)/bin
SHARE_DIR = $(DESTDIR)$(PREFIX)/share

export CGO_CPPFLAGS := ${CPPFLAGS}
export CGO_CFLAGS := ${CFLAGS}
export CGO_CXXFLAGS := ${CXXFLAGS}
export CGO_LDFLAGS := ${LDFLAGS}
export GOFLAGS := -buildmode=pie -trimpath -mod=readonly -modcacherw

.PHONY: local
local: vendor build

.PHONY: run
run: local
	go run main.go

.PHONY: build
build: main.go
	go build -trimpath -o $(BIN) main.go

.PHONY: release
release: build
	strip $(BIN) 2>/dev/null || true
	upx -9 $(BIN) 2>/dev/null || true

.PHONY: vendor
vendor:
	go mod tidy
	go mod vendor

.PHONY: clean
clean:
	rm -f "$(BIN)"
	rm -rf dist
	rm -rf vendor

.PHONY: fmt
fmt: ## Verifies all files have been `gofmt`ed.
	@echo "+ $@"
	@gofmt -s -l .

.PHONY: lint
lint: ## Verifies `golint` passes.
	@echo "+ $@"
	@if [ ! -z "$(shell revive ./... | grep -v vendor | tee /dev/stderr)" ]; then \
		exit 1; \
	fi

.PHONY: vet
vet: ## Verifies `go vet` passes.
	@echo "+ $@"
	@if [ ! -z "$(shell go vet $(shell go list ./... | grep -v vendor) | tee /dev/stderr)" ]; then \
		exit 1; \
	fi

.PHONY: staticcheck
staticcheck: ## Verifies `staticcheck` passes
	@echo "+ $@"
	@if [ ! -z "$(shell staticcheck $(shell go list ./... | grep -v vendor) | tee /dev/stderr)" ]; then \
		exit 1; \
	fi

.PHONY: dist
dist: clean vendor build release
	$(eval TMP := $(shell mktemp -d))
	mkdir "$(TMP)/$(BIN)-$(VERSION)"
	cp -r * "$(TMP)/$(BIN)-$(VERSION)"
	(cd "$(TMP)" && tar -cvzf "$(BIN)-$(VERSION)-src.tar.gz" "$(BIN)-$(VERSION)")

	mkdir "$(TMP)/$(BIN)-$(VERSION)-linux64"
	cp LICENSE.md README.md example/style.css example/livestatus.toml "$(TMP)/$(BIN)-$(VERSION)-linux64"
	(cd "$(TMP)" && tar -cvzf "$(BIN)-$(VERSION)-linux64.tar.gz" "$(BIN)-$(VERSION)-linux64")

	mkdir -p dist
	mv "$(TMP)/$(BIN)-$(VERSION)"-*.tar.gz dist
	git archive -o "dist/$(BIN)-$(VERSION).tar.gz" --format tar.gz --prefix "$(BIN)-$(VERSION)/" "$(VERSION)"

	for file in dist/*; do \
	    gpg --detach-sign --armor "$$file"; \
	done

	rm -rf "$(TMP)"
	rm -f "dist/$(BIN)-$(VERSION).tar.gz"

.PHONY: install
install:
	install -Dm755 -t "$(BIN_DIR)/" $(BIN)
	install -Dm644 -t "$(SHARE_DIR)/licenses/$(BIN)/" LICENSE.md
	install -Dm644 -t "$(LIB_DIR)/systemd/user" gnome-shell-screenshot-dbus-emulator@.service
