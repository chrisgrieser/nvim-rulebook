## Checklist for adding rule docs / ignore comment data
- [ ] Run `make update_readme` to update the list of supported sources in the README.
- [ ] Use `%s` as a placeholder for the rule ID.
- [ ] The source name (`diagnostic.source`) matches the name of the key in `rule-data.lua` (case-sensitive).

## Checklist for other changes
- [ ] Adhere the `stylua.toml`.
- [ ] Use camelCase variable names.
- [ ] If functionaltiy is added or modified, also made changes to the readme.
- [ ] Use conventional commits keywords.
