#!/bin/bash

set -e

LSPS=(
    bashls
    clangd
    cssls
    html
    lua_ls
    pylsp
    ts_ls
)

SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
LSP_DIR="$SCRIPT_DIR/lsp"
LSP_ENABLE_FILE="$SCRIPT_DIR/plugin/02_lspenable.lua"
TMPDIR="$(mktemp -d)"

echo 'downloading lspconfig git repo...'
git clone --depth=1 https://github.com/neovim/nvim-lspconfig/ "$TMPDIR" &>/dev/null
rm -rf "$LSP_DIR"
mkdir -p "$LSP_DIR"
for LSP in "${LSPS[@]}"; do
    echo "copying $LSP.lua into place..."
    mv "$TMPDIR/lsp/$LSP.lua" "$LSP_DIR/"
done
rm -rf "$TMPDIR"

echo 'updating lspenable file...'
echo '-- enable all lsp
local lsps_enable = {' > "$LSP_ENABLE_FILE"
FIRST=true
for LSP in "${LSPS[@]}"; do
    if [[ "$FIRST" == true ]]; then
        echo -n "    " >> "$LSP_ENABLE_FILE"
        FIRST=false 
    else
        echo -n " " >> "$LSP_ENABLE_FILE"
    fi
    echo -n "\"$LSP\"," >> "$LSP_ENABLE_FILE"
done
echo '
}
for _, lsp_enable in ipairs(lsps_enable) do
    vim.lsp.enable(lsp_enable)
end' >> "$SCRIPT_DIR/plugin/02_lspenable.lua"

