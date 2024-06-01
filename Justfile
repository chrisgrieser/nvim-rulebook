# needs `lua` dir as working directory so module names are consistent with
# nvim's own usage

@update_readme:
    cd ./lua && nvim -l ./rulebook/update-readme.lua && echo "README updated."
