local base = require("plugins.configs.lspconfig")
local on_attach = base.on_attach
local capabilities = base.capabilities

local lspconfig = require("lspconfig")

lspconfig.clangd.setup {
  on_attach = function(client, bufnr) 
    client.server_capabilities.signatureHelpProvider = false
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
}

-- Configure Pyright
lspconfig.pyright.setup {}

-- Debugging configuration
require('dap-python').setup('/usr/bin/python') -- Use the system Python
require('dap').configurations.python = {
  {
    type = 'python';
    request = 'launch';
    name = "Launch file";
    program = "${file}";
    pythonPath = function()
      return '/usr/bin/python3' -- Use the system Python
    end;
  },
}

-- C# (OmniSharp)
lspconfig.omnisharp.setup {
  cmd = { "dotnet", "/usr/local/bin/omnisharp/OmniSharp.dll" },
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = function(fname)
    return lspconfig.util.root_pattern("*.csproj", "*.sln")(fname) or lspconfig.util.path.dirname(fname)
  end,
}

-- Debugging configuration for C#
require('dap').adapters.coreclr = {
  type = 'executable',
  command = '/usr/local/bin/netcoredbg/netcoredbg',
  args = { '--interpreter=vscode' }
}

require('dap').configurations.cs = {
  {
    type = 'coreclr',
    name = 'launch - netcoredbg',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/net6.0/<project>.dll', 'file')
    end,
  },
}

-- Bash
lspconfig.bashls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = function(fname)
    return lspconfig.util.find_git_ancestor(fname) or lspconfig.util.path.dirname(fname)
  end,
}
