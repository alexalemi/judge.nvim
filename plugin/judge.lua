if vim.g.loaded_judge then
  return
end
vim.g.loaded_judge = 1

-- Lazy load the judge module only when commands are actually used
local function get_judge()
  return require('judge')
end

vim.api.nvim_create_user_command('JudgeRunFile', function()
  get_judge().run_file()
end, { desc = 'Run Judge tests in current file' })

vim.api.nvim_create_user_command('JudgeRunAll', function()
  get_judge().run_all()
end, { desc = 'Run all Judge tests in project' })

vim.api.nvim_create_user_command('JudgeRunLine', function()
  get_judge().run_line()
end, { desc = 'Run Judge test at cursor position' })

vim.api.nvim_create_user_command('JudgeAccept', function()
  get_judge().accept()
end, { desc = 'Accept all Judge test results' })

vim.api.nvim_create_user_command('JudgeInteractive', function()
  get_judge().interactive()
end, { desc = 'Run Judge in interactive mode' })

vim.api.nvim_create_user_command('JudgeToggleResults', function()
  get_judge().toggle_results()
end, { desc = 'Toggle Judge results display' })