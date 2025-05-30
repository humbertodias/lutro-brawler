[![CD](https://github.com/humbertodias/lutro-brawler/actions/workflows/cd.yml/badge.svg)](https://github.com/humbertodias/lutro-brawler/actions/workflows/cd.yml)
![GitHub all downloads](https://img.shields.io/github/downloads/humbertodias/lutro-brawler/total)

# 🥊 Lutro Brawler

A **Street Fighter**-style 2D fighting game built with **Lua**, compatible with both [Love2D](https://love2d.org) and [Lutro](http://lutro.libretro.com).

[Play online](https://humbertodias.github.io/lutro-brawler/) or [Download the latest release](https://github.com/humbertodias/lutro-brawler/releases).

![Gameplay Screenshot](https://github.com/user-attachments/assets/d5fee812-c1bf-459a-9e25-034702be62af)

> Featuring pixel art from [Fantasy Warrior](https://luizmelo.itch.io/fantasy-warrior) and [Evil Wizard 2](https://luizmelo.itch.io/evil-wizard-2) by [LuizMelo](https://luizmelo.itch.io).

## 🎮 Controls

### Player 1 (Keyboard)

| Action   | Key(s)            |
| -------- | ----------------- |
| Move     | Arrow Keys (↑↓←→) |
| Attack 1 | A                 |
| Attack 2 | S/Z               |

### Player 1/2 (Joystick)

| Action   | Key(s)     |
| -------- | ---------- |
| Move     | D-Pad ←/→  |
| Attack 1 | B          |
| Attack 2 | Y          |
| Select   | Debug      |
| Startt   | Pause      |

> Supports standard controllers via Love2D's [Gamepad API](https://love2d.org/wiki/Joystick:isGamepad) and Lutro's [Joystick](https://lutro.libretro.com/doc/love.joystick.html).


## 🚀 Running the Game

### With [Love2D](https://love2d.org):

```sh
make run/love
```

### With [Lutro](http://lutro.libretro.com):

```sh
make run/lutro
```

### First time? Download the Lutro core:

```sh
make get/lutro-core
```

## 📋 TODO

* [X] Shared codebase between love2d/lutro
* [X] Keyboard/Joystick support
* [X] Love2d build
* [X] Lutro build
* [X] WebAssembly (WASM) export
* [X] Default resolution 320x240
* [X] Use font spritesheed instead of ttf
* [X] Use ogg instead of mp3
* [ ] Flip player sprite based on direction
* [ ] Add basic AI movement
* [ ] Make hitbox size configurable
* [ ] Implement player selector scene
* [ ] Implement player sequence of attacks + hud


## 📚 References

* [Debugging Love2D with ZeroBrane Studio](https://notebook.kulchenko.com/zerobrane/love2d-debugging)
* [Street Fighter Clone in Python (Pygame)](https://www.youtube.com/watch?v=s5bd9KMSSW4)
* [Lutro Documentation](https://lutro.libretro.com/doc/usefullibs.html)
* [Love2D Wiki](https://love2d.org/wiki/Main_Page)
