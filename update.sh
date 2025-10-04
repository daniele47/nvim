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
rm "$LSP_ENABLE_FILE"
for LSP in "${LSPS[@]}"; do
    echo "vim.lsp.enable(\"$LSP\")" >> "$LSP_ENABLE_FILE"
done

