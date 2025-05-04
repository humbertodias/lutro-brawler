# Paths
FRONTEND    := $(shell which retroarch)
LOVE        := $(shell which love)
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

lutro:
	zip -9 -r brawler-$(TAG_NAME).lutro ./assets ./*.lua

love:
	zip -9 -r brawler-$(TAG_NAME).love ./assets ./*.lua

js:
	echo "EMSDK:$(EMSDK)"
	source ${EMSDK}/emsdk_env.sh
	emsdk install binaryen-main-64bit
	python3 ${EMSDK}/upstream/emscripten/tools/file_packager.py brawler.data --preload ./lutro --js-output=brawler.js	

clean:
	rm -rf *.lutro *.love
	sudo rm -rf example

format:
	stylua *.lua

get/lutro-core:
	wget -O lutro_libretro.zip $(LUTRO_URL)
	unzip -o lutro_libretro.zip
	rm lutro_libretro.zip

wasm/build:	lutro
	docker build . --build-arg GAME_ROM=brawler-$(TAG_NAME).lutro -t wasm
	docker run -i -v $(PWD):/outside wasm sh -c 'cp -r /workdir/lotr/example /outside'

wasm:	wasm/build
	(cd example && zip -9 -r ../brawler-$(TAG_NAME).zip vendors/ brawler.* lutro_libretro.* index.html)

wasm/serve:
	python -m http.server 8000 --directory ./example
