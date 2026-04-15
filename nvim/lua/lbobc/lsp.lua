require("mason").setup({
    registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
    },
})
require('mason-lspconfig').setup({
  ensure_installed = { 'html', 'tsserver','roslyn' ,'deno','prettier', 'prettierd' }
})
-- Configure the LSP server with keymaps and settings
vim.lsp.config("roslyn", {
  on_attach = function(client, bufnr)
    -- Create a helper function for easier key mapping
    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end
      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    -- Navigate to the definition of the symbol under the cursor
    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    
    -- Find all references to the symbol under the cursor
    nmap('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
    
    -- You can add other useful LSP keymaps here:
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  end,
  settings = {
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
    },
    ["csharp|symbol_search"] = {
      dotnet_search_reference_assemblies = true,
    },
    ["csharp|background_analysis"] = {
      -- Analyze the entire solution for more accurate results
      dotnet_analyzer_diagnostics_scope = 'fullSolution',
      dotnet_compiler_diagnostics_scope = 'fullSolution',
    },
    ["csharp|completion"] = {
      dotnet_show_name_completion_suggestions = true,
      dotnet_show_completion_items_from_unimported_namespaces = true,
    },
    ["csharp|symbol_search"] = {
      dotnet_search_reference_assemblies = true, -- Searches external references
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true, -- Can show reference counts
    },
  },
})
vim.lsp.enable("roslyn")

-- autocomplete settings
local cmp = require('cmp')

cmp.setup({
  snippet = {
    -- REQUIRED if using snippets
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Confirm selection
    ['<S-j>'] = cmp.mapping.select_next_item(), -- Navigate next
    ['<S-k>'] = cmp.mapping.select_prev_item(), -- Navigate previous
  }),
    completion = {
    keyword_pattern = [[\k\+/?]],  -- include `/` in keyword detection
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' }, -- This sources from your LSP clients, including Roslyn
    { name = 'luasnip' }, -- Uncomment if using snippets
  }, {
    { name = 'buffer' }, -- Also suggests words from the current file
  })
})
