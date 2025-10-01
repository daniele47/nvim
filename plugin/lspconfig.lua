-- gd keymap
vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Create keymaps for buffers with lsp attached",
    callback = function(event)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = event.buf })
    end,
})

-- style changes
vim.diagnostic.config({
    float = { border = "single" },
})

-- enable snippets
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = false })
    end,
})

-- enable all lsp
local lsps_enable = { "bashls", "clangd", "lua_ls" }
for _, lsp_enable in ipairs(lsps_enable) do
    vim.lsp.enable(lsp_enable)
end
