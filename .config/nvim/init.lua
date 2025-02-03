-- install lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- set leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local set = vim.opt
-- set line number
set.number = true
set.relativenumber = true
-- set tab options
set.tabstop = 2
set.softtabstop = 2
set.shiftwidth = 2
set.expandtab = true
-- disable line wrap
set.wrap = false
-- enable sign column
set.signcolumn = "yes"
-- set default side to for split
set.splitright = true
set.splitbelow = true
-- set scrolloff
vim.opt.scrolloff = 999
vim.opt.sidescrolloff = 999

-- competitive programming shortcuts
vim.api.nvim_set_keymap('n', '<Leader>cc',
  ':w<CR>:!g++ -std=c++17 -DLOCAL -Wshadow -Wall -g -fsanitize=address -fsanitize=undefined -D_GLIBCXX_DEBUG %<CR>',
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>rr', ':vsplit | terminal ./a.out<CR>i', { noremap = true, silent = true })
-- copy file text to clipboard
vim.api.nvim_set_keymap('n', '<leader>a', [[:normal! ggVG"+y<CR>]], { noremap = true, silent = true })
-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- key bindings to copy paste from system clipboard
vim.keymap.set("n", "<leader>p", [["+p]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- setup lazy and plugins
require("lazy").setup({
  spec = {
    {
      -- setup color scheme
      'projekt0n/github-nvim-theme',
      name = 'github-theme',
      lazy = false,
      priority = 1000,
      config = function()
        require('github-theme').setup({
        })

        vim.cmd('colorscheme github_dark_default')
      end,
    },
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
    {
      'saghen/blink.cmp',
      -- optional: provides snippets for the snippet source
      dependencies = 'rafamadriz/friendly-snippets',

      -- use a release tag to download pre-built binaries
      version = '*',
      -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
      -- build = 'cargo build --release',
      -- If you use nix, you can build from source using latest nightly rust with:
      -- build = 'nix run .#build-plugin',

      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        -- 'default' for mappings similar to built-in completion
        -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
        -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
        -- See the full "keymap" documentation for information on defining your own keymap.
        keymap = { preset = 'default' },

        appearance = {

          -- Sets the fallback highlight groups to nvim-cmp's highlight groups
          -- Useful for when your theme doesn't support blink.cmp
          -- Will be removed in a future release
          use_nvim_cmp_as_default = true,
          -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
          -- Adjusts spacing to ensure icons are aligned
          nerd_font_variant = 'mono'
        },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
          default = { "lazydev", 'lsp', 'path', 'snippets', 'buffer' },
          providers = {
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              -- make lazydev completions top priority (see `:h blink.cmp`)
              score_offset = 100,
            },
          },
        },
      },
      opts_extend = { "sources.default" }
    },
    -- LSP servers and clients communicate which features they support through "capabilities".
    --  By default, Neovim supports a subset of the LSP specification.
    --  With blink.cmp, Neovim has *more* capabilities which are communicated to the LSP servers.
    --  Explanation from TJ: https://youtu.be/m8C0Cq9Uv9o?t=1275
    --
    -- This can vary by config, but in general for nvim-lspconfig:

    {
      'neovim/nvim-lspconfig',
      dependencies = { 'saghen/blink.cmp' },

      -- example using `opts` for defining servers
      opts = {
        servers = {
          lua_ls = {},
          clangd = {
            cmd = {
              "clangd",
              "--header-insertion=never"
            }
          }
        }
      },
      config = function(_, opts)
        local lspconfig = require('lspconfig')
        for server, config in pairs(opts.servers) do
          -- passing config.capabilities to blink.cmp merges with the capabilities in your
          -- `opts[server].capabilities, if you've defined it
          config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
          lspconfig[server].setup(config)
        end
      end
    },
    {
      'stevearc/conform.nvim',
      opts = {
        formatters_by_ft = {
          -- javascript = { "prettierd", "prettier", stop_after_first = true },
        },
        format_on_save = {
          -- These options will be passed to conform.format()
          timeout_ms = 500,
          lsp_format = "fallback",
        },
      },
    },
    {
      'windwp/nvim-autopairs',
      event = "InsertEnter",
      config = true
    }
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true },
})
