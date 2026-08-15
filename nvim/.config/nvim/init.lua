require("options")
require("keymaps")
require("plugins")

local ok, theme = pcall(require, "theme")
if ok then
  pcall(theme.setup)
else
  vim.notify("theme.lua: " .. tostring(theme), vim.log.levels.WARN)
end
