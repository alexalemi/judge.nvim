local utils = require('judge.utils')
local ui = require('judge.ui')

local M = {}

function M.setup(opts)
  utils.setup(opts)
  
  if utils.config.keybindings then
    for action, key in pairs(utils.config.keybindings) do
      if key and key ~= '' then
        local func_name = action == 'toggle_results' and 'toggle_results' or action
        vim.keymap.set('n', key, function()
          M[func_name]()
        end, { desc = 'Judge: ' .. action:gsub('_', ' ') })
      end
    end
  end
end

function M.run_judge_command(args, opts)
  opts = opts or {}
  
  if not utils.is_janet_file() and not opts.force then
    utils.warn('Current file is not a Janet file')
    return
  end
  
  local cmd = utils.build_judge_command(args)
  local cwd = utils.find_project_root()
  
  local output = {}
  local job_id = vim.fn.jobstart(cmd, {
    cwd = cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_exit = function(_, exit_code)
      local output_str = table.concat(output, '\n')
      
      if exit_code == 0 then
        utils.notify('Judge tests passed')
      elseif exit_code == 1 then
        utils.notify('Judge tests failed', vim.log.levels.WARN)
      elseif exit_code == 2 then
        utils.error('Judge compilation or top-level error')
      else
        utils.error('Judge command failed with exit code ' .. exit_code)
      end
      
      if opts.callback then
        opts.callback(output_str, exit_code)
      end
      
      if opts.show_results ~= false then
        local results = utils.parse_judge_output(output_str)
        ui.display_results(results)
        if opts.show_inline then
          ui.show_inline_results(results)
        end
      end
    end
  })
  
  if job_id <= 0 then
    utils.error('Failed to start Judge command')
    return
  end
  
  utils.notify('Running Judge...')
  return job_id
end

function M.run_file()
  local file = utils.get_current_file()
  if not file or file == '' then
    utils.error('No file to run')
    return
  end
  
  M.run_judge_command({ file }, { show_inline = true })
end

function M.run_all()
  local project_root = utils.find_project_root()
  M.run_judge_command({ project_root }, { force = true })
end

function M.run_line()
  local file = utils.get_current_file()
  if not file or file == '' then
    utils.error('No file to run')
    return
  end
  
  local line, col = utils.get_current_line_col()
  local target = string.format('%s:%d:%d', file, line, col)
  
  M.run_judge_command({ target }, { show_inline = true })
end

function M.accept()
  local file = utils.get_current_file()
  local args = { '--accept' }
  
  if file and file ~= '' and utils.is_janet_file() then
    table.insert(args, file)
  end
  
  M.run_judge_command(args, {
    callback = function(output, exit_code)
      if exit_code == 0 then
        utils.notify('Judge results accepted')
        vim.cmd('edit!') -- Reload the current buffer
      end
    end,
    show_results = false
  })
end

function M.interactive()
  local file = utils.get_current_file()
  local args = { '--interactive' }
  
  if file and file ~= '' and utils.is_janet_file() then
    table.insert(args, file)
  end
  
  local cmd = utils.build_judge_command(args)
  local cwd = utils.find_project_root()
  
  vim.fn.termopen(cmd, { cwd = cwd })
end

function M.toggle_results()
  ui.toggle_results_window()
end

function M.get_test_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  
  local test_patterns = {
    '%f[%w]test%f[%W]',
    '%f[%w]test%-error%f[%W]',
    '%f[%w]test%-stdout%f[%W]',
    '%f[%w]test%-macro%f[%W]',
    '%f[%w]trust%f[%W]',
    '%f[%w]deftest%f[%W]'
  }
  
  for _, pattern in ipairs(test_patterns) do
    local start_pos = 1
    repeat
      local s, e = line:find(pattern, start_pos)
      if s and col >= s - 1 and col <= e then
        return { start_pos = s, end_pos = e, type = line:sub(s, e) }
      end
      start_pos = e and e + 1 or nil
    until not start_pos
  end
  
  return nil
end

return M