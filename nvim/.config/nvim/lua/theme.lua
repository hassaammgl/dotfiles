-- Theme switcher.
--
-- The active colorscheme is `vim.g.theme` (set in init.lua). Supported values:
--   onedark_dark (default) | onedark | onedark_vivid | onelight | vaporwave
--   catppuccin-mocha          (kept from the previous setup, still installed)
--
-- Everything that used to hardcode Catppuccin colors (lualine, alpha, floats,
-- neo-tree background) now asks this module instead, so switching with
-- `:Theme <name>` restyles the whole UI at runtime.

local M = {}

M.default = "onedark_dark"

--- Colorschemes provided by onedarkpro.nvim
M.onedark = { "onedark", "onedark_dark", "onedark_vivid", "onelight", "vaporwave" }

--- Full lualine options, kept so :Theme can re-apply the theme at runtime.
---@type table?
local lualine_opts

local applied = false

---@param name string
---@return boolean
local function is_onedark(name)
  return vim.tbl_contains(M.onedark, name)
end

--- Normalized accent palette of the active theme.
---@return table<string, string?>
local function accents()
  local name = vim.g.theme or M.default

  if is_onedark(name) then
    local ok, colors = pcall(function()
      return require("onedarkpro.helpers").get_colors()
    end)
    if ok and colors then
      return {
        bg = colors.bg,
        float_bg = colors.float_bg or colors.bg,
        surface = colors.cursorline or colors.selection,
        fg = colors.fg,
        accent = colors.purple,
        accent2 = colors.orange or colors.yellow,
        muted = colors.comment or colors.gray,
      }
    end
  end

  local ok, palettes = pcall(require, "catppuccin.palettes")
  if ok then
    local p = palettes.get_palette("mocha")
    return {
      bg = p.base,
      float_bg = p.mantle,
      surface = p.surface0,
      fg = p.text,
      accent = p.mauve,
      accent2 = p.peach,
      muted = p.overlay0,
    }
  end

  return {}
end

--- Lualine theme for the active colorscheme.
---@return string|table
function M.lualine()
  local name = vim.g.theme or M.default

  if is_onedark(name) then
    -- onedarkpro.nvim ships lualine themes named after each variant
    if pcall(require, "lualine.themes." .. name) then
      return name
    end
    return "auto"
  end

  -- catppuccin: hand-built table, same colors as the previous config
  local ok, palettes = pcall(require, "catppuccin.palettes")
  if not ok then
    return "auto"
  end
  local c = palettes.get_palette("mocha")

  ---@param accent string
  local function mode(accent)
    return {
      a = { fg = c.base, bg = accent, gui = "bold" },
      b = { fg = c.text, bg = c.surface0 },
      c = { fg = c.text, bg = c.mantle },
    }
  end

  return {
    normal = mode(c.blue),
    insert = mode(c.green),
    visual = mode(c.mauve),
    replace = mode(c.red),
    command = mode(c.peach),
    inactive = {
      a = { fg = c.overlay0, bg = c.mantle },
      b = { fg = c.overlay0, bg = c.mantle },
      c = { fg = c.overlay0, bg = c.mantle },
    },
  }
end

--- Highlight groups shared by alpha, floats and the explorer.
function M.highlights()
  local c = accents()
  if not c.fg then
    return
  end

  local function hl(group, spec)
    vim.api.nvim_set_hl(0, group, spec)
  end

  hl("AlphaHeader", { fg = c.accent, bold = true })
  hl("AlphaButtons", { fg = c.fg })
  hl("AlphaShortcut", { fg = c.accent2 })
  hl("AlphaFooter", { fg = c.muted, italic = true })

  hl("FloatBorder", { fg = c.accent2, bg = c.float_bg })
  hl("NormalFloat", { bg = c.float_bg })
  hl("NeoTreeNormal", { bg = c.float_bg })
  hl("NeoTreeNormalNC", { bg = c.float_bg })

  -- onedarkpro sets its own cursorline (options.cursorline = true); only the
  -- catppuccin path needs the manual override the old config had.
  if not is_onedark(vim.g.theme or M.default) and c.surface then
    hl("CursorLine", { bg = c.surface })
  end
end

---@param opts table full lualine options (called from plugins/ui.lua)
function M.register_lualine(opts)
  lualine_opts = opts
end

--- Apply a colorscheme and restyle everything that depends on it.
---@param name? string
function M.apply(name)
  name = name or vim.g.theme or M.default
  vim.g.theme = name

  local ok, err = pcall(vim.cmd.colorscheme, name)
  if not ok then
    vim.notify(("theme: cannot load '%s': %s"):format(name, err), vim.log.levels.ERROR)
    return
  end

  M.highlights()

  -- During startup lualine has not been set up yet (it reads M.lualine()
  -- itself); only re-apply it for runtime switches.
  if applied and lualine_opts and package.loaded["lualine"] then
    lualine_opts.options.theme = M.lualine()
    pcall(function()
      require("lualine").setup(lualine_opts)
    end)
  end
  applied = true
end

function M.setup()
  M.apply(vim.g.theme or M.default)

  vim.api.nvim_create_user_command("Theme", function(args)
    local name = args.args ~= "" and args.args or M.default
    if name == "catppuccin" then
      name = "catppuccin-mocha"
    end
    M.apply(name)
    vim.notify("theme: " .. name .. " (lualine/bufferline updated)")
  end, {
    nargs = "?",
    desc = "Switch colorscheme (onedark_dark, onedark, catppuccin-mocha, ...)",
    complete = function()
      return vim.list_extend(vim.deepcopy(M.onedark), { "catppuccin-mocha" })
    end,
  })
end

return M
