-- random-hash.nvim
-- Generate cryptographically secure random hashes (CSPRNG) via /dev/urandom
-- Commands: :RandomHashHex, :RandomHashBase64
-- Mappings: <Leader>rh (hex), <Leader>rb (base64)

-- ---------------------------------------------------------------------------
-- CSPRNG source: read from /dev/urandom
-- ---------------------------------------------------------------------------
local urandom_path = "/dev/urandom"

---Reads exactly `nbytes` cryptographically random bytes from /dev/urandom.
---@param nbytes integer
---@return string|nil raw bytes, or nil on failure
local function read_urandom(nbytes)
  local f, err = io.open(urandom_path, "rb")
  if not f then
    vim.notify(
      string.format("random-hash: cannot open %s: %s", urandom_path, err),
      vim.log.levels.ERROR
    )
    return nil
  end
  local data, err2 = f:read(nbytes)
  f:close()
  if not data or #data < nbytes then
    vim.notify(
      string.format("random-hash: read only %d of %d bytes from %s", #(data or ""), nbytes, urandom_path),
      vim.log.levels.ERROR
    )
    return nil
  end
  return data
end

-- ---------------------------------------------------------------------------
-- Hex encoding
-- ---------------------------------------------------------------------------
---@param data string raw bytes
---@return string hex-encoded string (lowercase)
local function to_hex(data)
  local hex = {}
  for i = 1, #data do
    hex[#hex + 1] = string.format("%02x", string.byte(data, i))
  end
  return table.concat(hex)
end

-- ---------------------------------------------------------------------------
-- Base64 encoding  (RFC 4648, no external deps)
-- ---------------------------------------------------------------------------
local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

---@param data string raw bytes
---@return string base64-encoded string
local function to_base64(data)
  local len = #data
  local out = {}
  local i = 1
  while i <= len do
    local a = string.byte(data, i)
    local b = string.byte(data, i + 1)
    local c = string.byte(data, i + 2)
    out[#out + 1] = b64chars:sub(math.floor(a / 4) + 1, math.floor(a / 4) + 1)
    out[#out + 1] = b64chars:sub(math.floor((a % 4) * 16 + math.floor(b / 16)) + 1, math.floor((a % 4) * 16 + math.floor(b / 16)) + 1)
    out[#out + 1] = b64chars:sub(math.floor((b % 16) * 4 + math.floor(c / 64)) + 1, math.floor((b % 16) * 4 + math.floor(c / 64)) + 1)
    out[#out + 1] = b64chars:sub((c % 64) + 1, (c % 64) + 1)
    i = i + 3
  end

  -- RFC 4648 padding
  local pad = (3 - len % 3) % 3
  if pad == 1 then
    out[#out] = "="
  elseif pad == 2 then
    out[#out - 1] = "="
    out[#out] = "="
  end

  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------
local M = {}

---Generate a 64-character hexadecimal hash (32 random bytes → 64 hex chars).
---@return string|nil
function M.hex()
  local data = read_urandom(32)
  if not data then return nil end
  return to_hex(data)
end

---Generate a 64-character base64 hash (48 random bytes → 64 base64 chars).
---@return string|nil
function M.base64()
  local data = read_urandom(48)
  if not data then return nil end
  return to_base64(data)
end

---Generate an arbitrary-length hex string from `n` random bytes.
---@param n_bytes integer number of random bytes (default 32)
---@return string|nil
function M.hex_bytes(n_bytes)
  n_bytes = n_bytes or 32
  local data = read_urandom(n_bytes)
  if not data then return nil end
  return to_hex(data)
end

---Generate an arbitrary-length base64 string from `n` random bytes.
---@param n_bytes integer number of random bytes (default 48)
---@return string|nil
function M.base64_bytes(n_bytes)
  n_bytes = n_bytes or 48
  local data = read_urandom(n_bytes)
  if not data then return nil end
  return to_base64(data)
end

---Insert a 64-char hex hash at the cursor position.
function M.insert_hex()
  local hash = M.hex()
  if hash then
    vim.api.nvim_put({ hash }, "c", true, true)
  end
end

---Insert a 64-char base64 hash at the cursor position.
function M.insert_base64()
  local hash = M.base64()
  if hash then
    vim.api.nvim_put({ hash }, "c", true, true)
  end
end

-- ---------------------------------------------------------------------------
-- Setup: commands + keymaps
-- ---------------------------------------------------------------------------
local defaults = {
  prefix = "<Leader>r",
  keymaps = {
    hex = "h",
    base64 = "b",
  },
}

---@param opts? {prefix?: string, keymaps?: {hex?: string, base64?: string}}
function M.setup(opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})

  -- :RandomHashHex
  vim.api.nvim_create_user_command("RandomHashHex", function()
    M.insert_hex()
  end, { desc = "Insert 64-char CSPRNG hex hash at cursor" })

  -- :RandomHashBase64
  vim.api.nvim_create_user_command("RandomHashBase64", function()
    M.insert_base64()
  end, { desc = "Insert 64-char CSPRNG base64 hash at cursor" })

  -- Normal-mode keymaps
  local hex_map = opts.prefix .. opts.keymaps.hex
  vim.keymap.set("n", hex_map, function()
    M.insert_hex()
  end, { desc = "Insert 64-char hex hash" })

  local b64_map = opts.prefix .. opts.keymaps.base64
  vim.keymap.set("n", b64_map, function()
    M.insert_base64()
  end, { desc = "Insert 64-char base64 hash" })
end

return M
