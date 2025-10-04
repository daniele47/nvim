-- format keymap
vim.keymap.set('n', 'grf', vim.lsp.buf.format)

-- gd keymap
vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Create keymaps for buffers with lsp attached",
    callback = function(event)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = event.buf })
    end,
})

-- style changes
vim.diagnostic.config({
    virtual_text = true,
    sorted = true,
    float = { border = "single" },
})
-- configure lsp floating windows
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or "single"
    opts.max_width = opts.max_width or 100
    opts.max_height = opts.max_height or 15
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- enable snippets
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = false })
    end,
})
vim.keymap.set({ "i", "s" }, "<C-l>", function()
    if vim.snippet.active() and vim.fn.pumvisible() == 0 then
        return vim.snippet.jump(1)
    end
end)
vim.keymap.set({ "i", "s" }, "<C-h>", function()
    if vim.snippet.active() and vim.fn.pumvisible() == 0 then
        return vim.snippet.jump(-1)
    end
end)

-- list all active lsp in current buffer
function _G.statusline_lsp_list()
    local lsp_names = vim.iter(vim.lsp.get_clients({ bufnr = 0 }))
        :map(function(elem) return elem.name end)
        :join(", ")
    return (#lsp_names == 0 and "" or " ") .. lsp_names
end

-- change statusline
vim.opt.statusline = vim.iter({
    " ",
    "%t",
    "%m%r%y",
    "%=",
    "%<%{v:lua._G.statusline_lsp_list()}",
    "%=",
    "%{&ff}",
    "%l:%v",
    "%P",
    " ",
}):join(" ")
-- autocmd to refresh statusline when necessary
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function() vim.cmd("redrawstatus") end,
})
vim.api.nvim_create_autocmd("LspDetach", {
    callback = function() vim.defer_fn(function() vim.cmd("redrawstatus") end, 500) end,
})
