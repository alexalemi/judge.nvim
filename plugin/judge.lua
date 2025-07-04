if vim.g.loaded_judge then
  return
end
vim.g.loaded_judge = 1

local judge = require('judge')

vim.api.nvim_create_user_command('JudgeRunFile', function()
  judge.run_file()
end, { desc = 'Run Judge tests in current file' })

vim.api.nvim_create_user_command('JudgeRunAll', function()
  judge.run_all()
end, { desc = 'Run all Judge tests in project' })

vim.api.nvim_create_user_command('JudgeRunLine', function()
  judge.run_line()
end, { desc = 'Run Judge test at cursor position' })

vim.api.nvim_create_user_command('JudgeAccept', function()
  judge.accept()
end, { desc = 'Accept all Judge test results' })

vim.api.nvim_create_user_command('JudgeInteractive', function()
  judge.interactive()
end, { desc = 'Run Judge in interactive mode' })

vim.api.nvim_create_user_command('JudgeToggleResults', function()
  judge.toggle_results()
end, { desc = 'Toggle Judge results display' })