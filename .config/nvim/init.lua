local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[packadd packer.nvim]]
end

local packer = require('packer')
packer.startup(function(use)
  use 'olivercederborg/poimandres.nvim'
  use 'folke/tokyonight.nvim'
  use 'JoosepAlviste/nvim-ts-context-commentstring'
  use 'wbthomason/packer.nvim'
  use 'numToStr/Comment.nvim'
  use 'nvim-treesitter/nvim-treesitter'
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'sbdchd/neoformat'
  use 'luukvbaal/nnn.nvim'
  use 'norcalli/nvim-colorizer.lua'
  use 'windwp/nvim-ts-autotag'
  use 'windwp/nvim-autopairs'
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable "make" == 1 }
  if is_bootstrap then
    packer.sync()
  end
end)
if is_bootstrap then
  print '=================================='
  print '    Plugins are being installed'
  print '    Wait until Packer completes,'
  print '       then restart nvim'
  print '=================================='
  return
end

vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.hlsearch = false
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.mouse = 'a'
vim.o.autoindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'
vim.o.completeopt = 'menuone,noselect'
vim.o.wrap = false
vim.o.backup = false
vim.o.swapfile = false
vim.o.scrolloff = 999
vim.o.sidescrolloff = 999
vim.o.showmode = false
vim.o.clipboard = "unnamedplus"
vim.o.termguicolors = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
require 'colorizer'.setup()
require('Comment').setup {
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
}
require("nnn").setup()
require("nvim-autopairs").setup {}
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'lua' },
  highlight = { enable = true },
  -- indent = { enable = true },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  }
}
require('nvim-ts-autotag').setup()
local telescope = require('telescope')
local telescope_builtin = require('telescope.builtin')
pcall(telescope.load_extension, 'fzf')
telescope.setup {
  -- defaults = {
  --   mappings = {
  --     i = {
  --       ['<C-u>'] = false,
  --       ['<C-d>'] = false,
  --     },
  --   },
  --   file_ignore_patterns = {
  --     ".git", ".cache", ".local/share", ".local/src"
  --   }
  -- },
  -- pickers = {
  --   find_files = {
  --     hidden = true
  --   },
  --   git_files = {
  --     hidden = true,
  --     show_untracked = true
  --   }
  -- },
}
require("tokyonight").setup({
  transparent = true,
  terminal_colors = true,
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    functions = {},
    variables = {},
    sidebars = "transparent",
    floats = "transparent",
  },
  hide_inactive_statusline = true,
})

vim.cmd [[colorscheme tokyonight]]

vim.keymap.set('n', '<leader>p', ":NnnPicker<cr>")
vim.keymap.set('n', '<leader>n', ":NnnExplorer<cr>")
vim.keymap.set('n', '<leader><space>', telescope_builtin.buffers)
vim.keymap.set('n', '<C-p>', telescope_builtin.git_files)
vim.keymap.set('n', '<C-f>', telescope_builtin.find_files)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>d', vim.diagnostic.setloclist)
local on_attach = function(_, bufnr)
  local nmap = function(keys, func)
    vim.keymap.set('n', keys, func, { buffer = bufnr })
  end
  nmap('<leader>rn', vim.lsp.buf.rename)
  nmap('<leader>aa', vim.lsp.buf.code_action)
  nmap('<leader>ds', telescope_builtin.lsp_document_symbols)
  nmap('gd', vim.lsp.buf.definition)
  nmap('gi', vim.lsp.buf.implementation)
  nmap('gr', telescope_builtin.lsp_references)
  nmap('K', vim.lsp.buf.hover)
  nmap('gD', vim.lsp.buf.declaration)
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', vim.lsp.buf.format or vim.lsp.buf.formatting, {})
end


require("mason").setup()
require("mason-lspconfig").setup()
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
require("mason-lspconfig").setup_handlers {
  function(server_name)
    require("lspconfig")[server_name].setup {
      on_attach = on_attach,
      capabilities = capabilities,
    }
  end,
  ["sumneko_lua"] = function()
    lspconfig.sumneko_lua.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
          },
          diagnostics = {
            globals = { 'vim' },
          },
          workspace = { library = vim.api.nvim_get_runtime_file('', true) },
          telemetry = { enable = false, },
        },
      },
    }
  end,
  ["clangd"] = function()
    lspconfig.clangd.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      cmd = {
        "clangd", "--header-insertion=never"
      },
    }
  end
}


local cmp = require 'cmp'
local luasnip = require 'luasnip'
if cmp then
  cmp.setup {
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-u>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm {
        select = true,
      },
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<C-Tab>'] = cmp.mapping(function(fallback)
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        elseif cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { 'i', 's' }),
    },
    sources = cmp.config.sources({
      { name = 'path' },
      { name = 'nvim_lsp' },
      { name = 'luasnip' }
    }, {
      { name = 'buffer' },
    }),
  }
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })
end

-- competitive programming
vim.keymap.set('n', '<leader>c', ":w<cr> :!g++ -DLOCAL -Wall % <cr>")
vim.keymap.set('n', '<leader>r', ":vsp term://./a.out <cr>i")
