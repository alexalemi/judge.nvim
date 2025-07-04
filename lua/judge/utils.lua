local M = {}

M.config = {
  judge_cmd = 'judge',
  default_flags = {},
  keybindings = {
    run_file = '<leader>jf',
    run_all = '<leader>ja',
    run_line = '<leader>jl',
    accept = '<leader>ja',
    interactive = '<leader>ji',
    toggle_results = '<leader>jr'
  },
  ui = {
    results_window = {
      width = 0.8,
      height = 0.6,
      border = 'rounded'
    },
    highlights = {
      passed = 'DiagnosticOk',
      failed = 'DiagnosticError',
      diff_added = 'DiffAdd',
      diff_removed = 'DiffDelete'
    }
  }
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

function M.get_current_file()
  return vim.fn.expand('%:p')
end

function M.get_current_line_col()
  local pos = vim.api.nvim_win_get_cursor(0)
  return pos[1], pos[2] + 1
end

function M.is_janet_file()
  local filetype = vim.bo.filetype
  return filetype == 'janet' or vim.fn.expand('%:e') == 'janet'
end

function M.find_project_root()
  local current_dir = vim.fn.getcwd()
  local project_janet = vim.fn.findfile('project.janet', current_dir .. ';')
  if project_janet ~= '' then
    return vim.fn.fnamemodify(project_janet, ':h')
  end
  return current_dir
end

function M.build_judge_command(args)
  local cmd = { M.config.judge_cmd }
  vim.list_extend(cmd, M.config.default_flags)
  if args then
    vim.list_extend(cmd, args)
  end
  return cmd
end

function M.parse_judge_output(output)
  local results = {
    passed = 0,
    failed = 0,
    files = {},
    corrections = {}
  }
  
  local current_file = nil
  local in_correction = false
  local correction_lines = {}
  
  for line in output:gmatch('[^\r\n]+') do
    if line:match('^# ') then
      current_file = line:match('^# (.+)')
      results.files[current_file] = { passed = 0, failed = 0, corrections = {} }
    elseif line:match('^%d+ passed %d+ failed$') then
      local passed, failed = line:match('^(%d+) passed (%d+) failed$')
      results.passed = results.passed + tonumber(passed)
      results.failed = results.failed + tonumber(failed)
      if current_file then
        results.files[current_file].passed = tonumber(passed)
        results.files[current_file].failed = tonumber(failed)
      end
    elseif line:match('^%-') then
      in_correction = true
      correction_lines = { line }
    elseif line:match('^%+') then
      if in_correction then
        table.insert(correction_lines, line)
      end
    elseif in_correction and line == '' then
      if current_file then
        table.insert(results.files[current_file].corrections, table.concat(correction_lines, '\n'))
      end
      table.insert(results.corrections, table.concat(correction_lines, '\n'))
      in_correction = false
      correction_lines = {}
    end
  end
  
  if in_correction and #correction_lines > 0 then
    if current_file then
      table.insert(results.files[current_file].corrections, table.concat(correction_lines, '\n'))
    end
    table.insert(results.corrections, table.concat(correction_lines, '\n'))
  end
  
  return results
end

function M.notify(msg, level)
  vim.notify('Judge: ' .. msg, level or vim.log.levels.INFO)
end

function M.error(msg)
  M.notify(msg, vim.log.levels.ERROR)
end

function M.warn(msg)
  M.notify(msg, vim.log.levels.WARN)
end

return M