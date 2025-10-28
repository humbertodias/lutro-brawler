# malvado
A game programming library with  "DIV Game Studio"-style processes for Lua/Love2D

You can find the *malvado* documentation on the [Website](https://jepemo.github.io/malvado/)

- [Features](#features)
- [Getting Started](#getting-started)
  - [Installation](#installation)
  - [Run Examples](#examples)
  - [Hello World Example](#hello-world-example)

## Features



## Getting Started

### Installation
* Install [Love2d](https://love2d.org/)
* Install **Malvado**:
```bash
luarocks install malvado
```
For the documentation generation, if you download from github, you need [LDoc](https://github.com/stevedonovan/LDoc) and [Penlight](https://github.com/stevedonovan/Penlight) .

### Run Examples
```
love examples/helloworld
# or
love examples/demo
# or
love examples/space_asteroids
# or
love examples/bench
```

### Hello World Example

```lua
require 'malvado'

-- Define (not run) one process
HelloWorld = process(function(self)
  -- Set background to grey
  clear_screen(250, 250, 250)

  -- Define global font (size, color (r, g, b))
  local font = font(60, 0, 0, 0)

  -- Write the "Hello world" text in the process position
  write(font, self.x, self.y, self.text)

  -- Runs until escape key is pressed
  while not key("escape") do
    -- Render the process
    frame()
  end
end)

-- Start (main)
malvado.start(function()
  -- Set the title text of the window
  set_title("Hello world")

  -- Launch the background process
  -- The application runs until there is no running process.
  HelloWorld { x=240, y=280, text="Hello World" }
end)
```
