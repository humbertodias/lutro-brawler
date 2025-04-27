FRONTEND   = $(shell which retroarch)
LOVE       = $(shell which love)
UNAME_S    = $(shell uname -s)
ARCH       = $(shell uname -m)
LUTRO_CORE = $(PWD)/lutro_libretro.so
LUTRO_URL  = https://buildbot.libretro.com/nightly/linux/$(ARCH)/latest/lutro_libretro.so.zip


ifeq ($(UNAME_S),Darwin)
    FRONTEND   = /Applications/RetroArch.app/Contents/MacOS/RetroArch
    LOVE       = /Applications/love.app/Contents/MacOS/love
    LUTRO_CORE = $(PWD)/lutro_libretro.dylib
    LUTRO_URL  = https://buildbot.libretro.com/nightly/apple/osx/$(ARCH)/latest/lutro_libretro.dylib.zip
endif

run/love:
	${LOVE} .

run/core:
	${FRONTEND} -L ${LUTRO_CORE} .

# cargo install stylua
format:
	stylua *.lua

get/lutro-core:
	wget -O lutro_libretro.zip ${LUTRO_URL}
	unzip lutro_libretro.zip
	rm lutro_libretro.zip
