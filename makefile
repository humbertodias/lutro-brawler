# Paths
FRONTEND    := $(shell which retroarch)
LOVE        := $(shell which love)
DOCKER      := $(shell which docker)
UNAME_S     := $(shell uname -s)
ARCH        := $(shell uname -m)
PWD         := $(shell pwd)
# Git versioning
TAG_NAME    := $(shell git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD)

# Lutro core defaults
LUTRO_CORE  := $(PWD)/lutro_libretro.so
LUTRO_URL   := https://buildbot.libretro.com/nightly/linux/$(ARCH)/latest/lutro_libretro.so.zip

# macOS overrides
ifeq ($(UNAME_S), Darwin)
    FRONTEND   := /Applications/RetroArch.app/Contents/MacOS/RetroArch
    LOVE       := /Applications/love.app/Contents/MacOS/love
    LUTRO_CORE := $(PWD)/lutro_libretro.dylib
    LUTRO_URL  := https://buildbot.libretro.com/nightly/apple/osx/$(ARCH)/latest/lutro_libretro.dylib.zip
endif

# Targets
.PHONY: run/love run/core lutro clean format get/lutro-core

run/love:
	$(LOVE) .

run/lutro:
	$(FRONTEND) --appendconfig=retroarch.cfg -v -L $(LUTRO_CORE) .

run/lutro-debug:
	gdb --args $(FRONTEND) -v -L $(LUTRO_CORE) .

lutro:	version
	zip -9 -r brawler-$(TAG_NAME).lutro ./assets ./*.lua

love:	version
	zip -9 -r brawler-$(TAG_NAME).love ./assets ./*.lua

version:
	@echo "Version: $(TAG_NAME)"
	sed -i.bak "s/^VERSION.*/VERSION = '${TAG_NAME}'/" global.lua && rm -f global.lua.bak

clean:
	rm -rf *.lutro *.love *.zip
	sudo rm -rf example

format:
	stylua *.lua

get/lutro-core:
	wget -O lutro_libretro.zip $(LUTRO_URL)
	unzip -o lutro_libretro.zip
	rm lutro_libretro.zip

wasm/build:	lutro
	$(DOCKER) build . --build-arg GAME_ROM=brawler-$(TAG_NAME).lutro -t wasm
	$(DOCKER) run -i -v $(PWD):/outside wasm sh -c 'cp -r /workdir/lotr/example /outside'

wasm:	version	wasm/build
	(cd example && zip -9 -r ../brawler-$(TAG_NAME).zip vendors/ brawler.* lutro_libretro.* main.js index.html)

run/wasm:
	@echo "Serving example on http://localhost:8000"
	python -m http.server 8000 --directory ./example
