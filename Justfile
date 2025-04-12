set quiet := true

masonPath := "$HOME/.local/share/nvim/mason/bin/"

#───────────────────────────────────────────────────────────────────────────────

# needs `lua` dir as working directory so module names are consistent with nvim's own usage
update-readme:
    cd ./lua && nvim -l ./rulebook/_update-readme.lua && echo "README updated."

stylua:
    #!/usr/bin/env zsh
    {{ masonPath }}/stylua --check --output-format=summary . && return 0
    {{ masonPath }}/stylua .
    echo "\nFiles formatted."

lua_ls_check:
    {{ masonPath }}/lua-language-server --check .
