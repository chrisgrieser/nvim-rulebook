vim.api.nvim_create_user_command("Rulebook", function(ctx) require("rulebook")[ctx.args]() end, {
	nargs = 1,
	complete = function(query)
		local allOps = {}
		vim.list_extend(allOps, vim.tbl_keys(require("rulebook.diagnostic-actions")))
		vim.list_extend(allOps, vim.tbl_keys(require("rulebook.formatter-actions")))
		return vim.tbl_filter(function(op) return op:lower():find(query, nil, true) end, allOps)
	end,
})
