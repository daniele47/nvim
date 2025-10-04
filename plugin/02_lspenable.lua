-- enable all lsp
local lsps_enable = {
    "bashls", "clangd", "cssls", "html", "lua_ls", "pylsp", "ts_ls",
}
for _, lsp_enable in ipairs(lsps_enable) do
    vim.lsp.enable(lsp_enable)
end
