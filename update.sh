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
TMPDIR="$(mktemp -d)"

echo 'downloading lspconfig git repo...'
git clone https://github.com/neovim/nvim-lspconfig/ "$TMPDIR" &>/dev/null
rm -rf "$SCRIPT_DIR/lsp"
mkdir -p "$SCRIPT_DIR/lsp"
for LSP in "${LSPS[@]}"; do
    echo "copying $LSP.lua into place..."
    mv "$TMPDIR/lsp/$LSP.lua" "$SCRIPT_DIR/lsp/"
done
rm -rf "$TMPDIR"

echo 'updating lspenable file...'
echo '-- enable all lsp
local lsps_enable = {' > "$SCRIPT_DIR/plugin/02_lspenable.lua"
FIRST=true
for LSP in "${LSPS[@]}"; do
    if [[ "$FIRST" == true ]]; then
        echo -n "    " >> "$SCRIPT_DIR/plugin/02_lspenable.lua"
        FIRST=false 
    else
        echo -n " " >> "$SCRIPT_DIR/plugin/02_lspenable.lua"
    fi
    echo -n "\"$LSP\"," >> "$SCRIPT_DIR/plugin/02_lspenable.lua"
done
echo '
}
for _, lsp_enable in ipairs(lsps_enable) do
    vim.lsp.enable(lsp_enable)
end' >> "$SCRIPT_DIR/plugin/02_lspenable.lua"

