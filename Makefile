.PHONY: update_readme

update_readme:
	cd ./lua && nvim -l ./rulebook/update-readme.lua && echo "README updated."

