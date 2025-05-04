FROM emscripten/emsdk:2.0.34

WORKDIR /workdir
# Clone lotr and compile lutro core using emscripten
RUN git clone --recursive https://github.com/kivutar/lotr.git && \
    cd lotr && make lutro

# Build Arguments
ARG GAME_NAME=brawler
ARG GAME_ROM=brawler.lutro

# Copy rom
WORKDIR /workdir/lotr
ADD ${GAME_ROM} .

# Sourcing ROMs for WASM
# Assets for wasm come as .js/.data pairs and are generated via Emscripten's file_packager.py.
# To package a rom from an original binary or disc:
RUN python3 ${EMSDK}/upstream/emscripten/tools/file_packager.py \
    "./example/${GAME_NAME}.data" \
    --preload "./${GAME_ROM}" \
    --js-output="./example/${GAME_NAME}.js"

# Your example/index.html will need to import the emulator and the ROM like this:
# And your example/main.js will need to launch the ROM:    
RUN sed -i "s|SMS Arena.js|${GAME_NAME}.js|g" example/index.html && \
    sed -i "s|main.lua|${GAME_ROM}|g" example/main.js