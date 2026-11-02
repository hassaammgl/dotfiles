-- Live reload for plugins that are checked out locally with
-- `dev = "~/path"` in their spec (see lua/config/pack.lua).
--
--   :DevReload scaffold     reload that dev plugin
--   :DevReload              reload every dev plugin
--
-- It clears the module cache, drops the plugin's user commands, resets the
-- usual `vim.g.loaded_<name>` / `vim.g.<name>_commands_registered` guards,
-- re-sources its plugin/ file and runs setup(opts) again.
--
-- Limits: code that the plugin wired into autocommands or keymaps *before* the
-- reload keeps pointing at the old closures; options in lua/plugins/*.lua are
-- read at startup. When in doubt use `:restart` (re-execs nvim in ~100ms).

local M = {}

---@param name string module name, e.g. "scaffold"
---@param spec table spec table from lua/plugins/*.lua
local function reload_one(name, spec)
	local dir = vim.fn.expand(spec.dev)

	-- 1. module cache
	local cleared = 0
	local prefix = name .. "."
	for key in pairs(package.loaded) do
		if key == name or key:sub(1, #prefix) == prefix then
			package.loaded[key] = nil
			cleared = cleared + 1
		end
	end

	-- 2. user commands the plugin registered (they are created without force)
	local cap = name:gsub("^%l", string.upper)
	local removed = 0
	for cmd in pairs(vim.api.nvim_get_commands({})) do
		if cmd:sub(1, #cap) == cap then
			pcall(vim.api.nvim_del_user_command, cmd)
			removed = removed + 1
		end
	end

	-- 3. the plugin's own keymaps, so setup() does not refuse to re-create them
	for _, lhs in pairs((spec.opts or {}).keymaps or {}) do
		if type(lhs) == "string" then
			pcall(vim.keymap.del, "n", lhs)
		end
	end

	-- 4. plugin guards
	vim.g["loaded_" .. name] = nil
	vim.g[name .. "_commands_registered"] = nil

	-- 5. re-source plugin/<name>.lua from the dev checkout
	local plugin_file = vim.fs.joinpath(dir, "plugin", name .. ".lua")
	if vim.uv.fs_stat(plugin_file) then
		local ok, err = pcall(dofile, plugin_file)
		if not ok then
			vim.notify(("dev: %s failed:\n%s"):format(plugin_file, err), vim.log.levels.ERROR)
			return
		end
	end

	-- 6. run setup() again with the spec options
	local ok, mod = pcall(require, name)
	if not ok then
		vim.notify(("dev: require('%s') failed:\n%s"):format(name, mod), vim.log.levels.ERROR)
		return
	end
	if type(mod.setup) == "function" and spec.opts then
		local ok2, err2 = pcall(mod.setup, spec.opts)
		if not ok2 then
			vim.notify(("dev: %s.setup() failed:\n%s"):format(name, err2), vim.log.levels.ERROR)
			return
		end
	end

	vim.notify(("dev: reloaded %s (%d modules, %d commands)"):format(name, cleared, removed), vim.log.levels.INFO)
end

function M.setup()
	vim.api.nvim_create_user_command("DevReload", function(args)
		local wanted = args.args ~= "" and args.args or nil
		local matched = 0
		for _, spec in ipairs(require("config.pack").specs or {}) do
			if type(spec.dev) == "string" then
				local name = spec.main or (spec.name:gsub("%.nvim$", ""))
				if not wanted or wanted == name or wanted == spec.name then
					reload_one(name, spec)
					matched = matched + 1
				end
			end
		end
		if matched == 0 then
			vim.notify("dev: no dev plugin matched" .. (wanted and (" '" .. wanted .. "'") or ""), vim.log.levels.WARN)
		end
	end, { nargs = "?", desc = "Reload a locally checked-out plugin (dev mode)" })
end

M.setup()

return M
