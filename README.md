# judge.nvim

A Neovim plugin for [Judge](https://github.com/ianthehenry/judge), a library for writing inline snapshot tests in Janet.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Neovim](https://img.shields.io/badge/neovim-0.7%2B-green.svg)

## What is Judge?

Judge is a testing library for Janet that lets you write inline snapshot tests. Instead of writing traditional assertions, you write expressions to observe, and Judge fills in the expected results automatically. This makes it incredibly easy to write and maintain tests.

**Example:**
```janet
(test (+ 1 2))  ; You write this
(test (+ 1 2) 3)  ; Judge fills in the result
```

## Features

- 🚀 Run Judge tests directly from Neovim
- 📊 Display test results in floating windows
- 🎯 Run tests at cursor position
- 🔄 Interactive mode for accepting/rejecting test results
- 🎨 Syntax highlighting for test results
- ⚡ Inline test status indicators
- 🔧 Configurable keybindings and UI

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'alexalemi/judge.nvim',
  ft = 'janet',
  dependencies = {
    -- Optional: for better Janet syntax highlighting
    'bakpakin/janet.vim'
  },
  config = function()
    require('judge').setup()
  end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'alexalemi/judge.nvim',
  ft = 'janet',
  requires = {
    -- Optional: for better Janet syntax highlighting
    'bakpakin/janet.vim'
  },
  config = function()
    require('judge').setup()
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'bakpakin/janet.vim'  " Optional: for better Janet syntax highlighting
Plug 'alexalemi/judge.nvim'
```

## Prerequisites

Before using this plugin, you need to have Judge installed. You can install it using Janet's package manager:

```bash
# Install Judge globally
jpm install judge

# Or add to your project's dependencies in project.janet
(declare-project
  :dependencies [
    {:url "https://github.com/ianthehenry/judge.git"
     :tag "v2.9.0"}
  ])
```

## Setup

```lua
require('judge').setup({
  -- Judge executable path (default: 'judge')
  judge_cmd = 'judge',
  
  -- Default flags to pass to judge command
  default_flags = {},
  
  -- Keybindings
  keybindings = {
    run_file = '<leader>jf',        -- Run tests in current file
    run_all = '<leader>ja',         -- Run all tests in project
    run_line = '<leader>jl',        -- Run test at cursor
    accept = '<leader>jA',          -- Accept all results
    interactive = '<leader>ji',     -- Interactive mode
    toggle_results = '<leader>jr'   -- Toggle results window
  },
  
  -- UI configuration
  ui = {
    results_window = {
      width = 0.8,    -- 80% of screen width
      height = 0.6,   -- 60% of screen height
      border = 'rounded'
    },
    highlights = {
      passed = 'DiagnosticOk',
      failed = 'DiagnosticError',
      diff_added = 'DiffAdd',
      diff_removed = 'DiffDelete'
    }
  }
})
```

## Commands

| Command | Description |
|---------|-------------|
| `:JudgeRunFile` | Run Judge tests in the current file |
| `:JudgeRunAll` | Run all Judge tests in the project |
| `:JudgeRunLine` | Run the Judge test at the cursor position |
| `:JudgeAccept` | Accept all Judge test results (overwrites source files) |
| `:JudgeInteractive` | Run Judge in interactive mode |
| `:JudgeToggleResults` | Toggle the results window |

## Usage

### Running Tests

1. **Run tests in current file**: Use `:JudgeRunFile` or the configured keybinding
2. **Run all tests**: Use `:JudgeRunAll` to run tests in the entire project
3. **Run test at cursor**: Place your cursor on a test and use `:JudgeRunLine`

### Viewing Results

The plugin displays test results in a floating window showing:
- Overall pass/fail counts
- Per-file results
- Suggested corrections with diff highlighting
- Red/green indicators for failed/passed tests

### Interactive Mode

Use `:JudgeInteractive` to run Judge in interactive mode, where you can:
- Review each test result
- Accept or reject individual corrections
- Make decisions about which changes to apply

### Accepting Results

Use `:JudgeAccept` to automatically accept all test results. This will:
- Overwrite your source files with the corrected versions
- Reload the current buffer to show changes

## Judge Test Examples

Judge supports several types of tests:

```janet
(use judge)

# Basic test
(test (+ 1 2) 3)

# Test error conditions
(test-error (in [1 2 3] 5) "expected integer key for tuple in range [0, 3), got 5")

# Test stdout
(test-stdout (print "hello") `
  hello
`)

# Trust (cached) expressions
(trust (expensive-computation))

# Named test groups
(deftest "arithmetic tests"
  (test (+ 1 1) 2)
  (test (* 2 3) 6))
```

## Keybinding Reference

Default keybindings (with `<leader>j` prefix):

- `<leader>jf` - Run file tests
- `<leader>ja` - Run all tests
- `<leader>jl` - Run line test
- `<leader>jA` - Accept results
- `<leader>ji` - Interactive mode
- `<leader>jr` - Toggle results

## Results Window Navigation

In the results window:
- `q` or `<Esc>` - Close window
- `r` - Refresh results (re-run current file)

## Requirements

- Neovim 0.7+
- Judge executable in PATH or configured path
- Janet files with `.janet` extension

## Tips

1. **Project Structure**: Judge works best when run from your project root where `project.janet` is located
2. **File Types**: The plugin automatically detects Janet files and enables features accordingly
3. **Inline Results**: When running single-file tests, you'll see pass/fail indicators inline
4. **Diff Highlighting**: Test corrections are highlighted with add/remove colors for easy review
5. **Workflow**: Use `JudgeRunFile` to run tests, review results, then `JudgeAccept` to apply changes
6. **Testing Strategy**: Start with `(test expression)` and let Judge fill in the expected values

## Troubleshooting

### Judge command not found

If you get an error that the `judge` command is not found:

1. Make sure Judge is installed: `jpm install judge`
2. Add the local bin directory to your PATH: `export PATH="./jpm_tree/bin:$PATH"`
3. Or configure the full path in your setup:

```lua
require('judge').setup({
  judge_cmd = '/path/to/jpm_tree/bin/judge'
})
```

### Tests not running

- Ensure you're in a Janet file (`.janet` extension)
- Check that your current working directory has a `project.janet` file
- Verify Judge is properly installed and accessible

### Results window not showing

- Check if the results window is behind other windows
- Try `:JudgeToggleResults` to toggle the window
- Ensure your terminal/GUI supports floating windows

## Advanced Usage

### Custom Test Types

Judge supports custom test types with setup and teardown:

```janet
(deftest-type database
  :setup (fn [] (create-test-database))
  :reset (fn [db] (clear-database db))
  :teardown (fn [db] (destroy-database db)))

(deftest: database "user tests" [db]
  (test (create-user db "alice") {:id 1 :name "alice"}))
```

### Using with CI/CD

You can run Judge in your CI pipeline:

```bash
# Run all tests and fail if any fail
judge

# Run tests and accept all results (useful for updating snapshots)
judge --accept
```

## Architecture

The plugin consists of several modules:

- `plugin/judge.lua` - Command registration and plugin initialization
- `lua/judge/init.lua` - Core functionality and command implementations
- `lua/judge/ui.lua` - User interface components and result display
- `lua/judge/utils.lua` - Utility functions and configuration
- `syntax/janet.vim` - Enhanced syntax highlighting for Judge test forms
- `ftdetect/janet.vim` - File type detection for Janet files

## Contributing

Contributions are welcome! Here's how you can help:

1. **Bug Reports**: Open an issue with a detailed description and reproduction steps
2. **Feature Requests**: Suggest new features or improvements
3. **Code Contributions**: Submit pull requests with bug fixes or new features
4. **Documentation**: Help improve the documentation and examples

### Development Setup

1. Clone the repository
2. Create a test Janet project with Judge tests
3. Symlink the plugin to your Neovim config for testing
4. Make your changes and test thoroughly

## Related Projects

- [Judge](https://github.com/ianthehenry/judge) - The underlying testing library
- [janet.vim](https://github.com/bakpakin/janet.vim) - Janet syntax highlighting for Vim/Neovim
- [conjure.nvim](https://github.com/Olical/conjure) - Interactive evaluation for Janet and other Lisps

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- Thanks to [Ian Henry](https://github.com/ianthehenry) for creating Judge
- Thanks to [Calvin Rose](https://github.com/bakpakin) for creating Janet
- Thanks to [Claude](https://claude.ai) for writing the neovim plugin.
