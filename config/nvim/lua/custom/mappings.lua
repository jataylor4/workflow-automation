local M = {}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = {
      "<cmd> DapToggleBreakpoint <CR>",
      "Add breakpoint at line",
    },
    ["<leader>dr"] = {
      "<cmd> DapContinue <CR>",
      "Start or continue the debugger",
    },
    ["<F5>"] = {
      "<cmd> DapContinue <CR>",
      "Start or continue the debugger",
    },
    ["<F9>"] = {
      "<cmd> DapToggleBreakpoint <CR>",
      "Toggle breakpoint at line",
    },
    ["<F10>"] = {
      "<cmd> DapStepOver <CR>",
      "Step over",
    },
    ["<F11>"] = {
      "<cmd> DapStepInto <CR>",
      "Step into",
    },
    ["<F12>"] = {
      "<cmd> DapStepOut <CR>",
      "Step out",
    },
    ["<leader>B"] = {
      "<cmd> lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
      "Set conditional breakpoint",
    },
    ["<leader>lp"] = {
      "<cmd> lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
      "Set log point",
    },
    ["<leader>dy"] = {
      "<cmd> lua require'dap'.repl.open()<CR>",
      "Open REPL",
    },
    ["<leader>dl"] = {
      "<cmd> lua require'dap'.run_last()<CR>",
      "Run last",
    },
  }
}

M.copilot = {
  i = {
    ["<C-l>"] = {
      function()
        vim.fn.feedkeys(vim.fn['copilot#Accept'](), '')
      end,
      "Copilot Accept",
      {replace_keycodes = true, nowait=true, silent=true, expr=true, noremap=true}
    }
  }
}

return M

