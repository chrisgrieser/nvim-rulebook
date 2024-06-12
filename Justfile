# needs `lua` dir as working directory so module names are consistent with
# nvim's own usage

@update-readme:
    cd ./lua && nvim -l ./rulebook/_update-readme.lua && echo "README updated."
