-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[packadd packer.nvim]]
end

-- stylua: ignore start
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'numToStr/Comment.nvim'
  use 'nvim-treesitter/nvim-treesitter'
  use 'neovim/nvim-lspconfig'
  use 'williamboman/nvim-lsp-installer'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  use 'gruvbox-community/gruvbox'
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-lua/plenary.nvim'
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable "make" == 1 }

  if is_bootstrap then
    require('packer').sync()
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

-- [[ Setting options ]]
-- See `:help vim.o`

vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.hlsearch = false
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.mouse = 'a'
vim.o.breakindent = true
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
vim.o.cursorline = true
vim.o.showmode = false

-- Set colorscheme
vim.o.termguicolors = true
vim.cmd [[colorscheme gruvbox]]
vim.cmd [[highlight Normal guibg=none ctermbg=none]]
vim.cmd [[highlight SignColumn guibg=none ctermbg=none]]

-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Enable Comment.nvim
require('Comment').setup()

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    previewer = false,
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
    file_ignore_patterns = {
      ".git", ".cache", ".local/share", ".local/src"
    }
  },
  pickers = {
    find_files = {
      previewer = false,
      hidden = true
    },
    git_files = {
      hidden = true,
      show_untracked = true
    }
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<C-p>', require "telescope.builtin".git_files)
vim.keymap.set('n', '<C-f>', require('telescope.builtin').find_files)

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'lua' },
  highlight = { enable = true },
  indent = { enable = true },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>d', vim.diagnostic.setloclist)

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  local nmap = function(keys, func)
    vim.keymap.set('n', keys, func, { buffer = bufnr })
  end

  nmap('<leader>rn', vim.lsp.buf.rename)
  nmap('<leader>ca', vim.lsp.buf.code_action)
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols)
  nmap('gd', vim.lsp.buf.definition)
  nmap('gi', vim.lsp.buf.implementation)
  nmap('gr', require('telescope.builtin').lsp_references)
  nmap('K', vim.lsp.buf.hover)
  nmap('<C-k>', vim.lsp.buf.signature_help)
  nmap('gD', vim.lsp.buf.declaration)

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', vim.lsp.buf.format or vim.lsp.buf.formatting, {})
end

-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local servers = { 'sumneko_lua' }
-- Ensure the servers above are installed
require('nvim-lsp-installer').setup {
  ensure_installed = servers,
}

-- enable installed servers
local lsp_installer = require('nvim-lsp-installer')
for _, lsp in ipairs(lsp_installer.get_installed_servers()) do
  require('lspconfig')[lsp.name].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

require('lspconfig').sumneko_lua.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT)
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

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

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
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
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
