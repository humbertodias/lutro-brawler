# Lutro Brawler

A **Street Fighter** clone made in **Lua**, adapted to run on both [Love2D](https://love2d.org) and [Lutro](http://lutro.libretro.com).

![Gameplay Screenshot](https://github.com/user-attachments/assets/d5fee812-c1bf-459a-9e25-034702be62af)

Assets [fantasy-warrior](https://luizmelo.itch.io/fantasy-warrior) | [evil-wizard-2](https://luizmelo.itch.io/evil-wizard-2)


## Controls

### Player 1 (P1)
| Action   | Key(s)  |
|----------|---------|
| Move     | W A S D |
| Action 1 | R       |
| Action 2 | T       |

### Player 2 (P2)
| Action   | Key(s)                      |
|----------|-----------------------------|
| Move     | Arrow Keys (↑ ↓ ← →)        |
| Action 1 | Numpad 1                    |
| Action 2 | Numpad 2                    |

### Joystick Support

When a gamepad is connected, it will override keyboard input:

| Gamepad Button | Mapped Action     |
|----------------|-------------------|
| A              | Jump              |
| X              | Action 1          |
| Y              | Action 2          |
| D-Pad ← →      | Move              |

Supports standard gamepads compatible with Love2D's [Gamepad API](https://love2d.org/wiki/Gamepad).


## Running the Game

**With Love2D:**
```shell
make run/love
```

**With Lutro:**
```shell
make run/lutro
```

If needed, download the **lutro** core:
```shell
make get/lutro-core
```

### TODO
- [ ] Player flip
- [ ] AI movement
- [ ] Wasm build


## References

- [ZeroBrane debugging with Love2D](https://notebook.kulchenko.com/zerobrane/love2d-debugging)
- [Street Fighter Style Fighting Game in Python (Pygame)](https://www.youtube.com/watch?v=s5bd9KMSSW4)
- [Lutro Documentation](https://lutro.libretro.com/doc/usefullibs.html)
- [Love2D Documentation](https://love2d.org/wiki/Main_Page)
