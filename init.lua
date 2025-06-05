--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.cmd("language en_US")
vim.o.splitright = true
vim.o.splitbelow = true
-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)
--
-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
    -- Defer LSP heavy operations
    vim.schedule(function()
        -- NOTE: Remember that lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself
        -- many times.
        --
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.

        -- nmap('<leader>f', function(_)
        --   vim.lsp.buf.format()
        -- end, '[F]ormat current file')

        -- require("lsp-format").on_attach(_, bufnr)
    end)
end

require('lazy').setup({
    defaults = {
        lazy = true
    },
    -- NOTE: First, some plugins that don't require any configuration

    -- Git related plugins
    { 'tpope/vim-fugitive', event = "VeryLazy" },
    { 'tpope/vim-rhubarb',  event = "VeryLazy" },

    -- Detect tabstop and shiftwidth automatically
    { 'tpope/vim-sleuth',   event = "VeryLazy" },

    -- NOTE: This is where your plugins related to LSP can be installed.
    --  The configuration is done below. Search for lspconfig to find it below.
    {
        -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for Neovim
            -- Mason must be loaded before its dependents so we need to set it up here.
            -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
            { 'mason-org/mason.nvim', opts = {} },
            'mason-org/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',

            -- Useful status updates for LSP.
            { 'j-hui/fidget.nvim',    opts = {} },

            -- Allows extra capabilities provided by blink.cmp
            'saghen/blink.cmp',
        },
        config = function()
            -- Brief aside: **What is LSP?**
            --
            -- LSP is an initialism you've probably heard, but might not understand what it is.
            --
            -- LSP stands for Language Server Protocol. It's a protocol that helps editors
            -- and language tooling communicate in a standardized fashion.
            --
            -- In general, you have a "server" which is some tool built to understand a particular
            -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
            -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
            -- processes that communicate with some "client" - in this case, Neovim!
            --
            -- LSP provides Neovim with features like:
            --  - Go to definition
            --  - Find references
            --  - Autocompletion
            --  - Symbol Search
            --  - and more!
            --
            -- Thus, Language Servers are external tools that must be installed separately from
            -- Neovim. This is where `mason` and related plugins come into play.
            --
            -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
            -- and elegantly composed help section, `:help lsp-vs-treesitter`

            --  This function gets run when an LSP attaches to a particular buffer.
            --    That is to say, every time a new file is opened that is associated with
            --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
            --    function will be executed to configure the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)
                    -- NOTE: Remember that Lua is a real programming language, and as such it is possible
                    -- to define small helper and utility functions so you don't have to repeat yourself.
                    --
                    -- In this case, we create a function that lets us more easily define mappings specific
                    -- for LSP related items. It sets the mode, buffer and description for us each time.
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end

                    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

                    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                    map('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
                    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
                    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
                    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols,
                        '[W]orkspace [S]ymbols')

                    -- See `:help K` for why this keymap
                    map('K', vim.lsp.buf.hover, 'Hover Documentation')
                    map('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

                    -- Lesser used LSP functionality
                    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                    map('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
                    map('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
                    map('<leader>wl', function()
                        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    end, '[W]orkspace [L]ist Folders')
                    -- -- Creatymape a command `:Format` local to the LSP buffer
                    -- vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
                    --     vim.lsp.buf.format()
                    -- end, { desc = 'Format current buffer with LSP' })

                    -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
                    ---@param client vim.lsp.Client
                    ---@param method vim.lsp.protocol.Method
                    ---@param bufnr? integer some lsp support methods only in specific files
                    ---@return boolean
                    local function client_supports_method(client, method, bufnr)
                        if vim.fn.has 'nvim-0.11' == 1 then
                            return client:supports_method(method, bufnr)
                        else
                            return client.supports_method(method, { bufnr = bufnr })
                        end
                    end

                    -- The following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    --    See `:help CursorHold` for information about when this is executed
                    --
                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
                        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight',
                            { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                            end,
                        })
                    end

                    -- The following code creates a keymap to toggle inlay hints in your
                    -- code, if the language server you are using supports them
                    --
                    -- This may be unwanted, since they displace some of your code
                    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, '[T]oggle Inlay [H]ints')
                    end
                end,
            })

            -- Diagnostic Config
            -- See :help vim.diagnostic.Opts
            vim.diagnostic.config {
                severity_sort = true,
                float = { border = 'rounded', source = 'if_many' },
                underline = { severity = vim.diagnostic.severity.ERROR },
                signs = vim.g.have_nerd_font and {
                    text = {
                        [vim.diagnostic.severity.ERROR] = '󰅚 ',
                        [vim.diagnostic.severity.WARN] = '󰀪 ',
                        [vim.diagnostic.severity.INFO] = '󰋽 ',
                        [vim.diagnostic.severity.HINT] = '󰌶 ',
                    },
                } or {},
                virtual_text = {
                    source = 'if_many',
                    spacing = 2,
                    format = function(diagnostic)
                        local diagnostic_message = {
                            [vim.diagnostic.severity.ERROR] = diagnostic.message,
                            [vim.diagnostic.severity.WARN] = diagnostic.message,
                            [vim.diagnostic.severity.INFO] = diagnostic.message,
                            [vim.diagnostic.severity.HINT] = diagnostic.message,
                        }
                        return diagnostic_message[diagnostic.severity]
                    end,
                },
            }

            -- LSP servers and clients are able to communicate to each other what features they support.
            --  By default, Neovim doesn't support everything that is in the LSP specification.
            --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
            --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
            local capabilities = require('blink.cmp').get_lsp_capabilities()

            -- Enable the following language servers
            --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
            --
            --  Add any additional override configuration in the following tables. Available keys are:
            --  - cmd (table): Override the default command used to start the server
            --  - filetypes (table): Override the default list of associated filetypes for the server
            --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
            --  - settings (table): Override the default settings passed when initializing the server.
            --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
            local servers = {
                -- clangd = {},
                -- gopls = {},
                -- pyright = {},
                -- rust_analyzer = {},
                -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
                --
                -- Some languages (like typescript) have entire language plugins that can be useful:
                --    https://github.com/pmizio/typescript-tools.nvim
                --
                -- But for many setups, the LSP (`ts_ls`) will work just fine
                -- ts_ls = {},
                --

                lua_ls = {
                    -- cmd = { ... },
                    -- filetypes = { ... },
                    -- capabilities = {},
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = 'Replace',
                            },
                            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                            -- diagnostics = { disable = { 'missing-fields' } },
                        },
                    },
                },
            }

            -- Ensure the servers and tools above are installed
            --
            -- To check the current status of installed tools and/or manually install
            -- other tools, you can run
            --    :Mason
            --
            -- You can press `g?` for help in this menu.
            --
            -- `mason` had to be setup earlier: to configure its options see the
            -- `dependencies` table for `nvim-lspconfig` above.
            --
            -- You can add other tools here that you want Mason to install
            -- for you, so that they are available from within Neovim.
            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                'stylua', -- Used to format Lua code
            })
            require('mason-tool-installer').setup { ensure_installed = ensure_installed }

            require('mason-lspconfig').setup {
                ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
                automatic_installation = false,
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        -- This handles overriding only values explicitly passed
                        -- by the server configuration above. Useful when disabling
                        -- certain features of an LSP (for example, turning off formatting for ts_ls)
                        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                        require('lspconfig')[server_name].setup(server)
                    end,
                },
            }
        end,

    },

    {
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        lazy = true,
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            { 'L3MON4D3/LuaSnip',         event = "InsertEnter" },
            { 'saadparwaiz1/cmp_luasnip', event = "InsertEnter" },

            -- Adds LSP completion capabilities
            'hrsh7th/cmp-nvim-lsp',

            -- Adds a number of user-friendly snippets
            { 'rafamadriz/friendly-snippets', event = "InsertEnter" },

            -- Completion for the cmdline
            { 'hrsh7th/cmp-cmdline',          event = "CmdlineEnter" }
        },
        -- [[ Configure nvim-cmp ]]
        -- See `:help cmp`
        config = function()
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'
            require('luasnip.loaders.from_vscode').lazy_load()
            luasnip.config.setup {}

            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert {
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete {},
                    ['<CR>'] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                    },
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                },
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                },
            }

            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    {
                        name = 'cmdline',
                        option = {
                            ignore_cmds = { 'Man', '!' }
                        }
                    }
                })
            })
        end,
    },

    -- Useful plugin to show you pending keybinds.
    { 'folke/which-key.nvim',          opts = {} },
    {
        -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
            -- See `:help gitsigns.txt`
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
            on_attach = function(bufnr)
                -- don't override the built-in and fugitive keymaps
                local gs = package.loaded.gitsigns
                vim.keymap.set({ 'n', 'v' }, ']c', function()
                    if vim.wo.diff then return ']c' end
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
                vim.keymap.set({ 'n', 'v' }, '[c', function()
                    if vim.wo.diff then return '[c' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })
            end,
        },
    },

    {
        -- Theme inspired by Atom
        'navarasu/onedark.nvim',
        priority = 1000,
        config = function()
            vim.g.onedark_config = { style = 'darker' }
            vim.cmd.colorscheme 'onedark'
        end,
    },

    {
        -- Set lualine as statusline
        'nvim-lualine/lualine.nvim',
        -- See `:help lualine.txt`
        opts = {
            options = {
                icons_enabled = false,
                theme = 'onedark',
                component_separators = '|',
                section_separators = ''
            },
            sections = {
                lualine_c = { 'filename', 'g:metals_status', function()
                    return vim.fn["db_ui#statusline"]({
                        show = { "db_name" },
                        prefix = "󰆼 ",
                    })
                end, 'g:metals_bsp_status' }
            }
        },
        event = "VeryLazy",
    },

    {
        -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help indent_blankline.txt`
        main = "ibl",
        opts = {},
        -- fucks with lsp highlighting
        enabled = false,
    },

    -- "gc" to comment visual regions/lines
    { 'numToStr/Comment.nvim',         opts = {} },

    -- autoformat on save
    -- fucks with autosave. Can only have one, so format will be done manually until the plugin allows to exclude formatiing from und
    { 'lukas-reineke/lsp-format.nvim', opts = { sync = true }, enabled = false },

    -- Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- Fuzzy Finder Algorithm which requires local dependencies to be built.
            -- Only load if `make` is available. Make sure you have the system
            -- requirements installed.
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
        },
    },

    {
        -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        lazy = vim.fn.argc(-1) == 0,
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        build = ':TSUpdate',
        opts = {
            -- Add languages to be installed here that you want installed for treesitter
            ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc',
                'vim',
                'scala', 'hurl', 'http', 'json', 'dockerfile', 'terraform', 'html', 'css' },

            -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
            auto_install = false,

            highlight = { enable = true },
            indent = { enable = true },
            incremental_selection = {
                enable = false,
                keymaps = {
                    init_selection = '<c-space>',
                    node_incremental = '<c-space>',
                    scope_incremental = '<c-s>',
                    node_decremental = '<M-space>',
                },
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ['aa'] = '@parameter.outer',
                        ['ia'] = '@parameter.inner',
                        ['af'] = '@function.outer',
                        ['if'] = '@function.inner',
                        ['ac'] = '@class.outer',
                        ['ic'] = '@class.inner',
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        [']m'] = '@function.outer',
                        [']]'] = '@class.outer',
                    },
                    goto_next_end = {
                        [']M'] = '@function.outer',
                        [']['] = '@class.outer',
                    },
                    goto_previous_start = {
                        ['[m'] = '@function.outer',
                        ['[['] = '@class.outer',
                    },
                    goto_previous_end = {
                        ['[M'] = '@function.outer',
                        ['[]'] = '@class.outer',
                    },
                },
                swap = {
                    -- enable = true,
                    -- swap_next = {
                    --   ['<leader>a'] = '@parameter.inner',
                    -- },
                    -- swap_previous = {
                    --   ['<leader>A'] = '@parameter.inner',
                    -- },
                },
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },

    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        cmd = "Neotree",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        },
        keys = {
            {
                "<leader>n",
                function()
                    require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd(), })
                end,
                desc = "Explorer [n]eotree (cwd)",
            },
        },
        opts = {
            sources = { "filesystem", "buffers", "git_status", "document_symbols" },
            open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "Outline" },
            filesystem = {
                bind_to_cwd = false,
                follow_current_file = { enabled = true },
                use_libuv_file_watcher = true,
                commands = {
                    avante_add_files = function(state)
                        local node = state.tree:get_node()
                        local filepath = node:get_id()
                        local relative_path = require('avante.utils').relative_path(filepath)

                        local sidebar = require('avante').get()

                        local open = sidebar:is_open()
                        -- ensure avante sidebar is open
                        if not open then
                            require('avante.api').ask()
                            sidebar = require('avante').get()
                        end

                        sidebar.file_selector:add_selected_file(relative_path)

                        -- remove neo tree buffer
                        if not open then
                            sidebar.file_selector:remove_selected_file('neo-tree filesystem [1]')
                        end
                    end,
                },
                hijack_netrw_behavior = "open_current"
            },
            window = {
                position = "right",
                mappings = {
                    ["<space>"] = "none",
                    ['oa'] = 'avante_add_files',
                },
            },
            -- default_component_configs = {
            --   indent = {
            --     with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
            --     expander_collapsed = "",
            --     expander_expanded = "",
            --     expander_highlight = "NeoTreeExpander",
            --   },
            -- },
        },
    },
    {
        'renerocksai/telekasten.nvim',
        dependencies = { 'nvim-telescope/telescope.nvim' },
        cmd = { "Telekasten" },
        keys = {
            { "<leader>nt", "<cmd>Telekasten goto_today<CR>" },
            { "<leader>nn", "<cmd>Telekasten new_note<CR>" },
            { "<leader>nf", "<cmd>Telekasten find_notes<CR>" },
            { "<leader>ng", "<cmd>Telekasten search_notes<CR>" },
            { "<leader>nd", "<cmd>Telekasten toggle_todo<CR>" },
        },
        opts = {
            home = vim.fn.expand('~/zettelkasten'),
            template_new_daily = vim.fn.expand('~/zettelkasten/templates/daily.md'),
            template_new_note = vim.fn.expand('~/zettelkasten/templates/generic.md'),
            auto_set_filetype = false
        }
    },

    {
        'ThePrimeagen/harpoon',
        opts = { global_settings = { mark_branch = true } },
        dependencies = {
            'nvim-lua/plenary.nvim'
        },
        keys = {
            {
                "<leader>a",
                function()
                    require("harpoon.mark").add_file()
                end,
                desc = "[a]dd to Harpoon",
            },
            {
                "<leader><C-e>",
                function()
                    require("harpoon.ui").toggle_quick_menu()
                end,
                desc = "Harpoon UI",
            },
            {
                "ƒ",
                function()
                    require("harpoon.ui").nav_file(1)
                end,
                desc = "1st harpoon file",
            },
            {
                "∂",
                function()
                    require("harpoon.ui").nav_file(2)
                end,
                desc = "2st harpoon file",
            },
            {
                "ß",
                function()
                    require("harpoon.ui").nav_file(3)
                end,
                desc = "3st harpoon file",
            },
            {
                "å",
                function()
                    require("harpoon.ui").nav_file(4)
                end,
                desc = "4st harpoon file",
            },
        }
    },
    -- http client, think postman but good
    {
        'mistweaverco/kulala.nvim',
        opts = { show_icons = nil, default_view = "headers_body", winbar = true, default_winbar_panes = { "body", "headers", "headers_body", "script_output", "stats" }, },
        keys = {
            {
                "<leader>hx",
                function()
                    require('kulala').run()
                end,
                desc = "[h]ttp request e[x]ecute",
            },
            {
                "<leader>hp",
                function()
                    require('kulala').copy()
                end,
                desc = "[h]ttp [p]review",
            },
            {
                "<leader>hi",
                function()
                    require('kulala').from_curl()
                end,
                desc = "[h]ttp request [i]mport",
            },
            {
                "<leader>hh",
                function()
                    require('kulala').toggle_view()
                end,
                desc = "[h]ttp request [h]eaders",
            },
        },
    },
    {
        'gbprod/substitute.nvim',
        opts = { highlight_substituted_text = { timer = 150 } }
    },
    { 'akinsho/toggleterm.nvim', version = "*",                           opts = { auto_scroll = false, size = 15, persist_size = false } },

    {
        'Pocco81/auto-save.nvim',
        opts = { execution_message = { message = function() return ("") end } }
    },
    -- debug
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'scalameta/nvim-metals'
        },
        config = function()
            -- setup dap for metals
            require('metals').setup_dap()
            local dap = require("dap")
            dap.configurations.scala = {
                {
                    type = "scala",
                    request = "launch",
                    name = "RunOrTest",
                    metals = {
                        runType = "runOrTestFile",
                        --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
                    },
                },
                {
                    type = "scala",
                    request = "launch",
                    name = "Test Target",
                    metals = {
                        runType = "testTarget",
                    },
                },
            }
        end,
        keys = {
            {
                "<leader>dc",
                function()
                    require('dap').continue()
                end,
                desc = "[d]ebug [c]ontinue",
            }, {
            "<leader>dr",
            function()
                require('dap').repl.toggle()
            end,
            desc = "[d]ebug [r]epl",
        }, {
            "<leader>dK",
            function()
                require('dap.ui.widgets').hover()
            end,
            desc = "[d]ebug widgets hover",
        }, {
            "<leader>dt",
            function()
                require('dap').toggle_breakpoint()
            end,
            desc = "[d]ebug [t]oggle breakpoint",
        }, {
            "<leader>dso",
            function()
                require('dap').step_over()
            end,
            desc = "[d]ebug [s]tep [o]over",
        }, {
            "<leader>dsi",
            function()
                require('dap').step_into()
            end,
            desc = "[d]ebug [s]tep [i]nto",
        }, {
            "<leader>dl",
            function()
                require('dap').run_last()
            end,
            desc = "[d]ebug run [l]ast",
        }, {
            "<leader>dc",
            function()
                require('dap').terminate()
            end,
            desc = "[d]ebug [c]lose",
        },
        },
    },
    -- -- autopairing
    -- { 'cohama/lexima.vim' },
    -- autoformat
    {
        'stevearc/conform.nvim',
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                -- Customize or remove this keymap to your liking
                "<leader>f",
                function()
                    require("conform").format({ async = true, lsp_fallback = true })
                end,
                mode = "",
                desc = "Format buffer",
            },
        },
        -- Everything in opts will be passed to setup()
        opts = {
            -- Define your formatters
            formatters_by_ft = {
                python = { "black" },
                javascript = { { "prettierd", "prettier" } },
                rust = { { "rustfmt" } },
                sql = { { "pg_format" } },
            },
            notify_on_error = true,
            -- -- Set up format-on-save
            -- format_on_save = { timeout_ms = 500, lsp_fallback = true },
            -- Customize formatters
            formatters = {
                shfmt = {
                    prepend_args = { "-i", "2" },
                },
                pg_format = {
                    prepend_args = { "-f", "1", "-u", "1", "-U", "1", "--no-space-function" },
                }
            },
        },
        init = function()
            -- If you want the formatexpr, here is the place to set it
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
    },
    { 'tpope/vim-surround',      event = { "BufNewFile", "BufReadPost" }, },
    { 'tpope/vim-repeat',        event = { "BufNewFile", "BufReadPost" }, },
    {
        'kristijanhusak/vim-dadbod-ui',
        dependencies = {
            { 'tpope/vim-dadbod',                     lazy = true },
            { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
        },
        cmd = {
            'DBUI',
            'DBUIToggle',
            'DBUIAddConnection',
            'DBUIFindBuffer',
        },
        init = function()
            -- Your DBUI configuration
            vim.g.db_ui_use_nerd_fonts = true
            vim.g.db_ui_execute_on_save = false
            vim.g.db_ui_save_location = "~/Library/DBeaverData/workspace6/General/Scripts"
            vim.g.db_ui_tmp_query_location = "~/Library/DBeaverData/workspace6/General/Scripts/msc_local"
            -- vim.g.db_ui_force_echo_notifications = true
            vim.g.db_ui_use_nvim_notify = true
            vim.g.db_ui_win_position = "right"
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { 'sql', 'mysql', 'plsql' },
                callback = function(opts)
                    ---@diagnostic disable-next-line: missing-fields
                    require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
                    -- didn't figure out how to run the query under the cursor.
                    -- the following mapping is from here https://github.com/tpope/vim-dadbod/issues/33#issuecomment-912167053
                    -- allowing for vip<enter> to run the query
                    -- Would prefer something shorter, but it works
                    vim.keymap.set({ "n", "x" }, "<C-M>", "db#op_exec()",
                        { buffer = opts.buf, desc = "[dadbod] Run selected query", expr = true })
                end,
            })
        end,
    },
    {
        'kevinhwang91/nvim-ufo',
        lazy = true,
        event = { "BufNewFile", "BufReadPost" },
        dependencies = { 'kevinhwang91/promise-async' },
        opts = {
            provider_selector = function(bufnr, filetype, buftype)
                return { 'treesitter', 'indent' }
            end
        }
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    {
        'scalameta/nvim-metals',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'mfussenegger/nvim-dap',
        },
        event = { "FileType scala", "FileType sbt", "FileType java" },
        config = function()
            -- metals

            local metals_config = require("metals").bare_config()
            metals_config.settings = {
                showInferredType = true,
                showImplicitArguments = false,
                excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
                enableSemanticHighlighting = true,
            }
            metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()
            metals_config.on_attach = on_attach
            local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
            metals_config.init_options.statusBarProvider = "on"
            vim.api.nvim_create_autocmd("FileType", {
                -- NOTE: You may or may not want java included here. You will need it if you
                -- want basic Java support but it may also conflict if you are using
                -- something like nvim-jdtls which also works on a java filetype autocmd.
                pattern = { "scala", "sbt", "java" },
                callback = function()
                    require("metals").initialize_or_attach(metals_config)
                end,
                group = nvim_metals_group,
            })
        end
    },

    {
        "OXY2DEV/markview.nvim",
        dependencies = {
            -- You may not need this if you don't lazy load
            -- Or if the parsers are in your $RUNTIMEPATH
            "nvim-treesitter/nvim-treesitter",

            "nvim-tree/nvim-web-devicons"
        },
        enabled = false
    },
    {
        "stevearc/dressing.nvim",
        event = { "InsertEnter", "CmdlineEnter" },
    },
    {
        "yetone/avante.nvim",
        keys = {
            { "<leader>aa", "<cmd>AvanteToggle<CR>" },
        },
        -- version = true, -- set this if you want to always pull the latest change
        opts = {
            hints = { enabled = false },
            claude = {
                model = "claude-3-7-sonnet-latest",
            },
            openai = {
                endpoint = "https://api.openai.com/v1",
                model = "gpt-4o",
                timeout = 30000,               -- Timeout in milliseconds, increase this for reasoning models
                temperature = 0,
                max_completion_tokens = 16384, -- Increase this to include reasoning tokens (for reasoning models)
                reasoning_effort = "medium",   -- low|medium|high, only used for reasoning models
            },
            disabled_tools = {
                -- "list_files",
                -- "search_files",
                -- "read_file",
                -- "create_file",
                -- "rename_file",
                "delete_file",
                -- "create_dir",
                -- "rename_dir",
                "delete_dir",
                "bash",
                -- "rag_search",
                "python",
                -- "git_diff",
                "git_commit",
                -- "search_keyword",
                -- "read_file_toplevel_symbols",
                -- "web_search",
                -- "fetch"
            },
            behaviour = {
                auto_suggestions = false,
            },
            system_prompt = function()
                local hub = require("mcphub").get_hub_instance()
                return hub:get_active_servers_prompt()
            end,
            -- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
            custom_tools = function()
                return {
                    require("mcphub.extensions.avante").mcp_tool(),
                }
            end,
        },
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- The below dependencies are optional,
            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            "ravitemer/mcphub.nvim",
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- required for Windows users
                        use_absolute_path = true,
                    },
                },
            },
            {
                -- Make sure to set this up properly if you have lazy=true
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    },
    {
        "ravitemer/mcphub.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
        },
        -- comment the following line to ensure hub will be ready at the earliest
        cmd = "MCPHub",                          -- lazy load by default
        build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
        -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
        -- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
        config = function()
            require("mcphub").setup({
                -- Extensions configuration
                extensions = {
                    avante = {
                        auto_approve_mcp_tool_calls = true, -- Auto approves mcp tool calls.
                    },
                    codecompanion = {
                        -- Show the mcp tool result in the chat buffer
                        -- NOTE:if the result is markdown with headers, content after the headers wont be sent by codecompanion
                        show_result_in_chat = false,
                        make_vars = true, -- make chat #variables from MCP server resources
                    },
                },
            })
        end,
    }
    -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
    --       These are some example plugins that I've included in the kickstart repository.
    --       Uncomment any of the lines below to enable them.
    -- require 'kickstart.plugins.autoformat',
    -- require 'kickstart.plugins.debug',

    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
    --    up-to-date with whatever is in the kickstart repo.
    --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    --
    --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
    -- { import = 'custom.plugins' },
}, {})

vim.filetype.add({
    extension = {
        mjml = "html",
    },
})
vim.filetype.add({
    extension = {
        ['http'] = 'http',
    },
})
-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = true

-- Enable mouse mode
vim.o.mouse = 'a'
-- Show whitespaces
vim.wo.list = true

-- Highlight current line
vim.wo.cursorline = true
-- Indentation size
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.shiftwidth = 4

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true
-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- keep some context while scrolling
vim.o.scrolloff = 8
-- [[ Basic Keymaps ]]

-- folds setup
vim.o.foldcolumn = '0' -- '0' is not bad
vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- dont close markdown preview
vim.g.mkdp_auto_close = 0

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
    defaults = {
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!.git/"
        },
        mappings = {
            i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
            },
        },
    },
    pickers = {
        buffers = { sort_mru = true },
    },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- require("neo-tree")
-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>se', function() require('telescope.builtin').find_files({ hidden = true }) end,
    { desc = '[S]earch [E]verywhere' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

--gitsigns hotkeys
vim.keymap.set('n', '<leader>gh', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[g]it [h]unk' })
vim.keymap.set('n', '<leader>gr', require('gitsigns').reset_hunk, { buffer = bufnr, desc = '[g]it hunk [r]eset' })
vim.keymap.set('n', '<leader>gb', require('gitsigns').toggle_current_line_blame,
    { buffer = bufnr, desc = '[g]it [b]lame toggle' })
-- substitute hotkeys

vim.keymap.set('n', 's', require('substitute').operator, { desc = 'substiture' })
vim.keymap.set('n', 'ss', require('substitute').line, { desc = 'substiture line' })
vim.keymap.set('n', 'S', require('substitute').eol, { desc = 'substiture until end of line' })
vim.keymap.set('x', 's', require('substitute').visual, { desc = 'substiture visual' })
--toggleterm hotkeys
vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm direction=horizontal<CR>", { desc = 'Toggle terminal' })
vim.keymap.set("t", '<esc>', '<C-\\><C-n>')
--dadbox hotkeys
vim.keymap.set("n", "<leader>db", "<cmd>DBUIToggle<CR>", { desc = 'Toggle DBUI' })
--fugitive hotkeys
vim.keymap.set("n", "<leader>gg", "<cmd>G status<CR>", { desc = "Git status" })
vim.keymap.set("n", "<leader>ga", ":Git add ", { desc = "Git add" })
vim.keymap.set("n", "<leader>gc", "<cmd>G commit<CR>", { desc = "Git commit" })
vim.keymap.set("n", "<leader>gp", "<cmd>G push<CR>", { desc = "Git push" })
vim.keymap.set("n", "<leader>gf", "<cmd>G pull<CR>", { desc = "Git pull" })
vim.keymap.set("n", "<leader>gt", ":Git checkout ", { desc = "Git checkout" })
--markdown preview
vim.keymap.set("n", "<leader>mp", "<Plug>MarkdownPreviewToggle", { desc = "Markdown preview" })
-- diff keymaps
vim.keymap.set("n", "<leader>df", "<cmd>diffthis<CR>", { desc = "Add current buffer to diff" })
vim.keymap.set("n", "<leader>dy", "<cmd>diffthis<CR><cmd>vnew<CR>p<cmd>diffthis<CR>",
    { desc = "Diff current buffer with yank" })

vim.keymap.set('n', '<leader>cl', vim.lsp.codelens.run, { desc = '[c]ode [l]ens run' })
-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
-- Metals keymaps
vim.keymap.set("n", "<leader>msi", function()
    require("metals").toggle_setting "showImplicitArguments"
end, { desc = "Metals: Show implicit args" })

--avante esc fix
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'Avante',
    callback = function()
        vim.keymap.set({ 'n', 'o' }, '<ESC>', '<Nop>', { buffer = true })
    end
})

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
-- local servers = {
--     -- clangd = {},
--     -- gopls = {},
--     pyright = {},
--     rust_analyzer = {},
--     html = { filetypes = { 'html', 'twig', 'hbs', 'mjml' } },
--     cssls = {},
--     lua_ls = {
--         Lua = {
--             workspace = { checkThirdParty = false },
--             telemetry = { enable = false },
--         },
--     },
-- }

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
-- local mason_lspconfig = require('mason-lspconfig')
-- mason_lspconfig.setup {
--     ensure_installed = vim.tbl_keys(servers),
--     automatic_installation = false,
--     handlers = {
--         function(server_name)
--             local server = servers[server_name] or {}
--             -- This handles overriding only values explicitly passed
--             -- by the server configuration above. Useful when disabling
--             -- certain features of an LSP (for example, turning off formatting for ts_ls)
--             server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
--             require('lspconfig')[server_name].setup(server)
--         end,
--     },
-- }

-- mason_lspconfig.setup_handlers {
--     function(server_name)
--         require('lspconfig')[server_name].setup {
--             capabilities = capabilities,
--             on_attach = on_attach,
--             settings = servers[server_name],
--             filetypes = (servers[server_name] or {}).filetypes,
--         }
--     end
-- }
