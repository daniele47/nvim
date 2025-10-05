#!/bin/bash

set -e

# list of lsp this script manages
# options:
#   - remote: download lsp configuration from lspconfig repo, and enable it
#   - local: keep the local lsp configuration, and enable it
declare -A LSPS=(
	[bashls]="remote"
	[clangd]="remote"
	[cssls]="remote"
	[html]="remote"
	[jsonls]="remote"
	[lua_ls]="local"
    [ruff]="remote"
	[ts_ls]="remote"
)

### WARNING: FROM HERE ON, DO NOT MODIFY ###
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
LSP_DIR="$SCRIPT_DIR/lsp"
LSP_ENABLE_FILE="$SCRIPT_DIR/plugin/02_lspenable.lua"

# download remote lsp
TMPDIR="$(mktemp -d)"
echo -e "\e[37;1mdownloading lspconfig git repository...\e[m"
git clone --depth 1 https://github.com/neovim/nvim-lspconfig "$TMPDIR" &>/dev/null
mkdir -p "$LSP_DIR"
for lsp in "${!LSPS[@]}"; do
	lsp_basename="$lsp.lua"
	local_lsp_file="$LSP_DIR/$lsp_basename"
	remote_lsp_file="$TMPDIR/lsp/$lsp_basename"
	case "${LSPS["$lsp"]}" in
	local)
		if [[ -f "$local_lsp_file" ]]; then
			echo -e "\e[32;1mlocal config file '$lsp_basename' is present!\e[m"
		else
			rm -rf "$local_lsp_file"
			echo -e "\e[33;1mlocal config file '$lsp_basename' is missing!\e[m"
		fi
		;;
	remote)
		rm -rf "$local_lsp_file"
		mv "$remote_lsp_file" "$local_lsp_file" 
        echo -e "\e[32;1mremote config file '$lsp_basename' has been downloaded!\e[m" 
		;;
	esac
done
rm -rf "$TMPDIR"

# enable all lsp
echo -e "\e[32;1mupdating '$(basename "$LSP_ENABLE_FILE")' file...\e[m"
rm "$LSP_ENABLE_FILE"
for lsp in "${!LSPS[@]}"; do
	echo "vim.lsp.enable(\"$lsp\")" >>"$LSP_ENABLE_FILE"
done
sort -o "$LSP_ENABLE_FILE" "$LSP_ENABLE_FILE"

# cleanup files in lsp directory
find "$LSP_DIR" -mindepth 1 -maxdepth 1 | while read -r line; do
    basename="$(basename "$line")"
    name="${basename%.lua}"
    if [[ -z "${LSPS[$name]}" ]]; then
        echo -e "\e[33;1mextra file '$basename' is being deleted!\e[m"
        rm -rf "$line"
    fi
done
