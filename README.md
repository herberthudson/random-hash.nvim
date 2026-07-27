# random-hash.nvim

Generate **cryptographically secure random hashes** (CSPRNG) directly in Neovim.

- **Hex**: 64 characters (32 bytes from `/dev/urandom`)
- **Base64**: 64 characters (48 bytes from `/dev/urandom`)
- Inserts the hash right where your cursor is
- Commands + configurable keymaps

## Requirements

- Neovim ≥ 0.8 (`vim.keymap.set` / `nvim_create_user_command`)
- Linux, macOS, or any Unix with `/dev/urandom`

## Installation

### lazy.nvim

```lua
{
  "herberthudson/random-hash.nvim",  -- adjust to your source
  opts = {},               -- calls setup() with defaults
}
```

### packer.nvim

```lua
use {
  "herberthudson/random-hash.nvim",
  config = function()
    require("random-hash").setup({})
  end,
}
```

## Usage

### Commands

| Command             | Action                                          |
| ------------------- | ----------------------------------------------- |
| `:RandomHashHex`    | Insert a 64-character **hex** hash at cursor    |
| `:RandomHashBase64` | Insert a 64-character **base64** hash at cursor |

### Default keymaps

| Key          | Action             |
| ------------ | ------------------ |
| `<Leader>rh` | Insert hex hash    |
| `<Leader>rb` | Insert base64 hash |

### From Lua

```lua
local rh = require("random-hash")

local h = rh.hex()           -- 64-char hex string
local b = rh.base64()        -- 64-char base64 string

-- Custom length
local h128 = rh.hex_bytes(64)       -- 128 hex chars
local b128 = rh.base64_bytes(96)    -- 128 base64 chars

rh.insert_hex()              -- Insert at cursor
rh.insert_base64()           -- Insert at cursor
```

## Configuration

Call `setup()` in your Neovim config (lazy.nvim does this automatically when you pass `opts`):

```lua
require("random-hash").setup({
  prefix = "<Leader>r",          -- prefix for keymaps
  keymaps = {
    hex    = "h",                 -- <Leader>rh
    base64 = "b",                 -- <Leader>rb
  },
})
```

## Security

The CSPRNG source is `/dev/urandom` — the OS kernel's cryptographically secure
pseudo-random generator. It is suitable for:

- API tokens / secrets
- Session identifiers
- Salts for password hashing
- Any use case requiring unpredictable random values

## License

MIT
