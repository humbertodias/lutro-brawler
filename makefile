FRONTEND=/Applications/RetroArch.app/Contents/MacOS/RetroArch
LUTRO_CORE=$(PWD)/lutro_libretro.dylib
LOVE=/Applications/love.app/Contents/MacOS/love

run/love:
	${LOVE} .
  
run/core:
	${FRONTEND} -L ${LUTRO_CORE} .

get/lutro-core:
	wget -O lutro_libretro.dylib.zip https://buildbot.libretro.com/nightly/apple/osx/arm64/latest/lutro_libretro.dylib.zip
	unzip lutro_libretro.dylib.zip
	rm lutro_libretro.dylib.zip
