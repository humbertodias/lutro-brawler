# 🥊 Lutro Brawler

A **Street Fighter**-style 2D fighting game built with **Lua**, compatible with both [Love2D](https://love2d.org) and [Lutro](http://lutro.libretro.com).

![Gameplay Screenshot](https://github.com/user-attachments/assets/d5fee812-c1bf-459a-9e25-034702be62af)

> Featuring pixel art from [Fantasy Warrior](https://luizmelo.itch.io/fantasy-warrior) and [Evil Wizard 2](https://luizmelo.itch.io/evil-wizard-2) by [LuizMelo](https://luizmelo.itch.io).

---

## 🎮 Controls

### Player 1 (Keyboard)

| Action   | Key(s)  |
| -------- | ------- |
| Move     | W A S D |
| Attack 1 | R       |
| Attack 2 | T       |

### Player 2 (Keyboard)

| Action   | Key(s)            |
| -------- | ----------------- |
| Move     | Arrow Keys (↑↓←→) |
| Attack 1 | Numpad 1          |
| Attack 2 | Numpad 2          |

### Gamepad Support

When a gamepad is connected, it overrides keyboard controls.

| Gamepad Input | Mapped Action |
| ------------- | ------------- |
| A             | Jump          |
| X             | Attack 1      |
| Y             | Attack 2      |
| D-Pad ←/→     | Move          |

> Supports standard controllers via Love2D's [Gamepad API](https://love2d.org/wiki/Joystick:isGamepad) and Lutro's [Joystick](https://lutro.libretro.com/doc/love.joystick.html).

---

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

---

## 📋 TODO

* [ ] Flip player sprite based on direction
* [ ] Add basic AI movement
* [ ] WebAssembly (WASM) export

---

## 📚 References

* [Debugging Love2D with ZeroBrane Studio](https://notebook.kulchenko.com/zerobrane/love2d-debugging)
* [Street Fighter Clone in Python (Pygame)](https://www.youtube.com/watch?v=s5bd9KMSSW4)
* [Lutro Documentation](https://lutro.libretro.com/doc/usefullibs.html)
* [Love2D Wiki](https://love2d.org/wiki/Main_Page)
