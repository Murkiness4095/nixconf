-- VSCode/Zed-like Neovim configuration (Nix-provided plugins, no lazy.nvim)

-- Options
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.showtabline = 2

-- Theme
vim.cmd.colorscheme("tokyonight")

-- File tree
require("nvim-tree").setup({
  view = { width = 30, side = "left" },
  renderer = { group_empty = true, icons = { show = { git = true } } },
  filters = { dotfiles = false },
  actions = { open_file = { quit_on_open = false } },
})
vim.keymap.set("n", "<C-b>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file tree" })

-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<C-S-p>", builtin.commands, { desc = "Command palette" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })

-- Statusline
require("lualine").setup()

-- Treesitter
pcall(function()
  require("nvim-treesitter.configs").setup({
    highlight = { enable = true },
    indent = { enable = true },
  })
end)

-- LSP
vim.lsp.enable({ "nil_ls", "lua_ls", "pyright", "rust_analyzer", "gopls", "ts_ls" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

-- Completion
local cmp = require("cmp")
cmp.setup({
  snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" }, { name = "luasnip" }, { name = "buffer" }, { name = "path" },
  }),
})

-- Format on save
require("conform").setup({
  formatters_by_ft = {
    nix = { "nixfmt" },
    lua = { "stylua" },
    python = { "black" },
    rust = { "rustfmt" },
    go = { "gofmt" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    json = { "prettier" },
  },
  format_on_save = { timeout_ms = 500, lsp_fallback = true },
})

-- Git signs / which-key
require("gitsigns").setup()
require("which-key").setup()

-- Nix snippets
local ls = require("luasnip")
local snip = ls.snippet
local txt = ls.text_node
local ins = ls.insert_node
ls.add_snippets("nix", {
  snip({ trig = "nixmod", dscr = "Nix module" }, {
    txt("{ "), ins(1, "pkgs"), txt(", ... }:"), txt({ "", "{" }), txt({ "", "  " }), ins(0), txt({ "", "}" }),
  }),
  snip({ trig = "nixosmod", dscr = "flake-parts: NixOS module" }, {
    txt("{"), txt({ "", "  flake.nixosModules." }), ins(1, "name"), txt(" = {"), txt({ "", "    " }), ins(0), txt({ "", "  };" }), txt({ "", "}" }),
  }),
  snip({ trig = "nixos", dscr = "flake-parts: NixOS configuration" }, {
    txt("{"), txt({ "", "  flake.nixosConfigurations." }), ins(1, "name"), txt(" = inputs.nixpkgs.lib.nixosSystem {"), txt({ "", "    system = \"" }), ins(2, "x86_64-linux"), txt("\";"), txt({ "", "    modules = [" }), txt({ "", "      " }), ins(0), txt({ "", "    ];" }), txt({ "", "  };" }), txt({ "", "}" }),
  }),
  snip({ trig = "homemod", dscr = "flake-parts: Home Manager module" }, {
    txt("{"), txt({ "", "  flake.homeModules." }), ins(1, "name"), txt(" = {"), txt({ "", "    " }), ins(0), txt({ "", "  };" }), txt({ "", "}" }),
  }),
  snip({ trig = "darwinmod", dscr = "flake-parts: nix-darwin module" }, {
    txt("{"), txt({ "", "  flake.darwinModules." }), ins(1, "name"), txt(" = {"), txt({ "", "    " }), ins(0), txt({ "", "  };" }), txt({ "", "}" }),
  }),
  snip({ trig = "package", dscr = "flake-parts: package" }, {
    txt("{"), txt({ "", "  perSystem = { pkgs, ... }: {" }), txt({ "", "    packages." }), ins(1, "name"), txt(" = "), ins(0), txt(";"), txt({ "", "  };" }), txt({ "", "}" }),
  }),
  snip({ trig = "app", dscr = "flake-parts: app" }, {
    txt("{"), txt({ "", "  perSystem = { pkgs, ... }: {" }), txt({ "", "    apps." }), ins(1, "name"), txt(" = {"), txt({ "", "      type = \"app\";" }), txt({ "", "      program = \"${pkgs.lib.getExe " }), ins(2), txt("}\";"), txt({ "", "    };" }), txt({ "", "  };" }), txt({ "", "}" }),
  }),
  snip({ trig = "devshell", dscr = "flake-parts: devShell" }, {
    txt("{"), txt({ "", "  perSystem = { pkgs, ... }: {" }), txt({ "", "    devShells." }), ins(1, "name"), txt(" = pkgs.mkShell {"), txt({ "", "      packages = with pkgs; [" }), txt({ "", "        " }), ins(0), txt({ "", "      ];" }), txt({ "", "    };" }), txt({ "", "  };" }), txt({ "", "}" }),
  }),
  snip({ trig = "persystem", dscr = "flake-parts: perSystem" }, {
    txt("{"), txt({ "", "  perSystem = { pkgs, system, ... }: {" }), txt({ "", "    " }), ins(0), txt({ "", "  };" }), txt({ "", "}" }),
  }),
  snip({ trig = "fpmodule", dscr = "flake-parts: module" }, {
    txt("{"), txt({ "", "  imports = [" }), txt({ "", "    " }), ins(1), txt({ "", "  ];" }), txt({ "", "" }), txt({ "", "  " }), ins(0), txt({ "", "}" }),
  }),
})

-- Keymaps
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save" })
vim.keymap.set("n", "<C-w>", "<cmd>bd<CR>", { desc = "Close buffer" })
vim.keymap.set("n", "<C-q>", "<cmd>qa<CR>", { desc = "Quit" })
vim.keymap.set("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("v", "<C-/>", "gc", { remap = true, desc = "Toggle comment" })

-- Yank highlight
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank() end,
})

-- ================================================================
-- Terminals (single panel, multiple tabs, closeable)
-- ================================================================
local term_win = nil

local function terminal_buffers()
  local out = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      table.insert(out, buf)
    end
  end
  return out
end

local function find_term_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal" then
      term_win = win
      return win
    end
  end
  return nil
end

local function ensure_term_win()
  if term_win and vim.api.nvim_win_is_valid(term_win) then return term_win end
  local w = find_term_win()
  if w then return w end
  if vim.bo.filetype == "NvimTree" then vim.cmd("wincmd p") end
  vim.cmd("belowright split")
  vim.cmd("resize 15")
  term_win = vim.api.nvim_get_current_win()
  return term_win
end

function _G.NewTerminal()
  local win = ensure_term_win()
  vim.api.nvim_set_current_win(win)
  vim.cmd("terminal")
  vim.cmd("startinsert")
end

function _G.ToggleTerminal()
  local win = find_term_win()
  if win then
    vim.api.nvim_win_close(win, true)
    term_win = nil
  else
    _G.NewTerminal()
  end
end

function _G.SwitchTerminal(id)
  local win = ensure_term_win()
  vim.api.nvim_set_current_win(win)
  vim.api.nvim_win_set_buf(win, id)
end

function _G.CloseTerminal(id)
  local win = find_term_win()
  vim.cmd("bdelete! " .. id)
  if win and vim.api.nvim_win_is_valid(win) then
    if #terminal_buffers() == 0 then
      vim.api.nvim_win_close(win, true)
      term_win = nil
    end
  end
end

vim.keymap.set({ "n", "t" }, "<C-`>", "<cmd>lua ToggleTerminal()<CR>", { desc = "Toggle terminal" })
vim.keymap.set({ "n", "t" }, "<C-~>", "<cmd>lua ToggleTerminal()<CR>", { desc = "Toggle terminal" })
vim.keymap.set({ "n", "t" }, "<C-S-`>", "<cmd>lua ToggleTerminal()<CR>", { desc = "Toggle terminal" })
vim.keymap.set({ "n", "t" }, "<C-S-~>", "<cmd>lua ToggleTerminal()<CR>", { desc = "Toggle terminal" })
vim.keymap.set({ "n", "t" }, "<C-_>", "<cmd>lua ToggleTerminal()<CR>", { desc = "Toggle terminal" })
vim.keymap.set({ "n", "t" }, "<C-S-_>", "<cmd>lua ToggleTerminal()<CR>", { desc = "Toggle terminal" })
vim.keymap.set({ "n", "t" }, "<F12>", "<cmd>lua ToggleTerminal()<CR>", { desc = "Toggle terminal" })

-- ================================================================
-- Menus (top tabline, full width)
-- ================================================================
local function pick(items, prompt, cb) vim.ui.select(items, { prompt = prompt }, cb) end

local menus = {
  File = {
    { "New File", function() vim.cmd("enew") end },
    { "Open File...", function() require("telescope.builtin").find_files() end },
    { "Open Folder...", function() require("telescope.builtin").find_files({ cwd = vim.fn.getcwd() }) end },
    { "Save", function() vim.cmd("w") end },
    { "Save As...", function() vim.cmd("saveas") end },
    { "Save All", function() vim.cmd("wa") end },
    { "Close Editor", function() vim.cmd("bd") end },
    { "Close Window", function() vim.cmd("qa") end },
  },
  Edit = {
    { "Undo", function() vim.cmd("undo") end },
    { "Redo", function() vim.cmd("redo") end },
    { "Cut", function() vim.cmd("normal! \"+d") end },
    { "Copy", function() vim.cmd("normal! \"+y") end },
    { "Paste", function() vim.cmd("normal! \"+p") end },
    { "Find...", function() require("telescope.builtin").live_grep() end },
    { "Replace...", function() vim.cmd("s/") end },
  },
  Selection = {
    { "Select All", function() vim.cmd("normal! ggVG") end },
    { "Select Line", function() vim.cmd("normal! V") end },
  },
  View = {
    { "Toggle File Tree", function() require("nvim-tree.api").tree.toggle() end },
    { "Collapse Project", function() require("nvim-tree.api").tree.collapse_all() end },
    { "New Terminal", function() _G.NewTerminal() end },
    { "Toggle Terminal", function() _G.ToggleTerminal() end },
    { "Command Palette", function() require("telescope.builtin").commands() end },
    { "Toggle Line Numbers", function() vim.opt.number = not vim.opt.number:get() end },
  },
  Go = {
    { "Go to File...", function() require("telescope.builtin").find_files() end },
    { "Go to Symbol...", function() require("telescope.builtin").lsp_document_symbols() end },
    { "Go to Definition", function() vim.lsp.buf.definition() end },
    { "Go to References", function() vim.lsp.buf.references() end },
  },
  Run = {
    { "Run", function() vim.cmd("!./run.sh") end },
    { "Build", function() vim.cmd("make") end },
    { "New Terminal", function() _G.NewTerminal() end },
  },
  Window = {
    { "Split Right", function() vim.cmd("vsplit") end },
    { "Split Down", function() vim.cmd("split") end },
    { "Close Window", function() vim.cmd("qa") end },
  },
  Help = {
    { "Which Key", function() vim.cmd("WhichKey") end },
    { "Neovim Help", function() vim.cmd("help") end },
    { "About", function() vim.notify("Neovim VSCode/Zed-like config") end },
  },
}

local menu_order = { "File", "Edit", "Selection", "View", "Go", "Run", "Window", "Help" }

function _G.MenuOpen(name)
  local items = {}
  for _, item in ipairs(menus[name] or {}) do table.insert(items, item[1]) end
  pick(items, name, function(choice)
    if not choice then return end
    for _, item in ipairs(menus[name]) do
      if item[1] == choice then item[2]() return end
    end
  end)
end
for _, name in ipairs(menu_order) do
  local n = name
  _G["Menu_" .. n] = function() _G.MenuOpen(n) end
end

function _G.MenuBar()
  local parts = {}
  for i, name in ipairs(menu_order) do
    table.insert(parts, "%" .. i .. "@v:lua.Menu_" .. name .. "@ " .. name .. " %T")
  end
  return table.concat(parts)
end
vim.o.tabline = "%!v:lua.MenuBar()"

-- ================================================================
-- Winbar: buffer tabs (editor) / terminal tabs (terminal)
-- ================================================================
function _G.WinBar()
  local win = tonumber(vim.g.statusline_winid) or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then return "" end
  local buf = vim.api.nvim_win_get_buf(win)
  local ft = vim.bo[buf].filetype
  local bt = vim.bo[buf].buftype
  if ft == "NvimTree" then return "" end

  local parts = {}
  if bt == "terminal" then
    for _, tb in ipairs(terminal_buffers()) do
      local id = tb
      _G["TermSwitch_" .. tostring(id)] = function() _G.SwitchTerminal(id) end
      _G["TermClose_" .. tostring(id)] = function() _G.CloseTerminal(id) end
      local name = "term " .. id
      local cur = (id == buf) and "%#TabLineSel#" or "%#TabLine#"
      table.insert(parts, cur .. " %1@v:lua.TermSwitch_" .. id .. "@ " .. name .. " %T")
      table.insert(parts, cur .. "%2@v:lua.TermClose_" .. id .. "@ ✕ %T ")
    end
    table.insert(parts, "%#TabLine#  %3@v:lua.NewTerminal@ + %T ")
    return table.concat(parts) .. "%#TabLineFill# "
  end

  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted and vim.bo[b].buftype == "" then
      local id = b
      _G["BufSwitch_" .. tostring(id)] = function() vim.api.nvim_set_current_buf(id) end
      _G["BufClose_" .. tostring(id)] = function() vim.cmd("bdelete! " .. id) end
      local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(id), ":t")
      if name == "" then name = "[No Name]" end
      local cur = (id == buf) and "%#TabLineSel#" or "%#TabLine#"
      table.insert(parts, cur .. " %1@v:lua.BufSwitch_" .. id .. "@ " .. name .. " %T")
      table.insert(parts, cur .. "%2@v:lua.BufClose_" .. id .. "@ ✕ %T ")
    end
  end
  return table.concat(parts) .. "%#TabLineFill# "
end

vim.o.winbar = "%!v:lua.WinBar()"

-- ================================================================
-- File tree: right-click menu + collapse on open
-- ================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = "NvimTree",
  callback = function()
    vim.keymap.set("n", "<RightMouse>", function()
      local api = require("nvim-tree.api")
      local items = { "New File", "New Folder", "Rename", "Delete", "Copy", "Cut", "Paste", "Refresh" }
      pick(items, "File Tree", function(choice)
        if not choice then return end
        local ok, err = pcall(function()
          if choice == "New File" then api.fs.create()
          elseif choice == "New Folder" then
            vim.ui.input({ prompt = "Folder name: " }, function(input)
              if input and input ~= "" then api.fs.create(nil, input .. "/") end
            end)
          elseif choice == "Rename" then api.fs.rename()
          elseif choice == "Delete" then api.fs.remove()
          elseif choice == "Copy" then api.fs.copy.node()
          elseif choice == "Cut" then api.fs.cut()
          elseif choice == "Paste" then api.fs.paste()
          elseif choice == "Refresh" then api.tree.reload()
          end
        end)
        if not ok then vim.notify("File tree action failed: " .. tostring(err), vim.log.levels.WARN) end
      end)
    end, { buffer = true, desc = "File tree context menu" })
    vim.keymap.set("n", "<leader>W", function() require("nvim-tree.api").tree.collapse_all() end, { buffer = true, desc = "Collapse all" })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("nvim-tree.api").tree.open()
    pcall(function() require("nvim-tree.api").tree.collapse_all() end)
  end,
})

print("Neovim VSCode/Zed-like config loaded (Nix-managed plugins).")