FRONTEND   = $(shell which retroarch)
LOVE       = $(shell which love)
LUTRO_CORE = $(PWD)/lutro_libretro.so
LUTRO_URL  = https://buildbot.libretro.com/nightly/linux/x86_64/latest/lutro_libretro.so.zip

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
    FRONTEND = /Applications/RetroArch.app/Contents/MacOS/RetroArch
    LOVE = /Applications/love.app/Contents/MacOS/love
	LUTRO_CORE = $(PWD)/lutro_libretro.dylib
    LUTRO_URL = https://buildbot.libretro.com/nightly/apple/osx/arm64/latest/lutro_libretro.dylib.zip
endif

run/love:
	${LOVE} .

run/core:
	${FRONTEND} -L ${LUTRO_CORE} .

get/lutro-core:
	wget -O lutro_libretro.zip ${LUTRO_URL}
	unzip lutro_libretro.zip
	rm lutro_libretro.zip
