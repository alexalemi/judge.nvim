" Syntax highlighting for Janet files with Judge test enhancements
" This extends the default Janet syntax to highlight Judge test forms

if exists("b:current_syntax")
  finish
endif

" Load base Janet syntax if available
runtime! syntax/janet.vim

" Judge test keywords
syn keyword janetJudgeTest test test-error test-stdout test-macro trust deftest deftest-type defmacro* defmacro*-
syn keyword janetJudgeTestType deftest:

" Judge test forms - highlight the entire test expression
syn region janetJudgeTestForm start="(\s*test\>" end=")" contains=ALL fold
syn region janetJudgeTestErrorForm start="(\s*test-error\>" end=")" contains=ALL fold
syn region janetJudgeTestStdoutForm start="(\s*test-stdout\>" end=")" contains=ALL fold
syn region janetJudgeTestMacroForm start="(\s*test-macro\>" end=")" contains=ALL fold
syn region janetJudgeTrustForm start="(\s*trust\>" end=")" contains=ALL fold
syn region janetJudgeDefTestForm start="(\s*deftest\>" end=")" contains=ALL fold

" Highlight Judge test results (when viewing .tested files)
syn match janetJudgeTestResult /\v\s+\zs[0-9]+\ze\s*$/
syn match janetJudgeTestPassed /\v\s+✓/
syn match janetJudgeTestFailed /\v\s+✗/

" Define highlight groups
hi def link janetJudgeTest Function
hi def link janetJudgeTestType Type
hi def link janetJudgeTestForm Special
hi def link janetJudgeTestErrorForm Special
hi def link janetJudgeTestStdoutForm Special
hi def link janetJudgeTestMacroForm Special
hi def link janetJudgeTrustForm Special
hi def link janetJudgeDefTestForm Special
hi def link janetJudgeTestResult Number
hi def link janetJudgeTestPassed DiagnosticOk
hi def link janetJudgeTestFailed DiagnosticError

let b:current_syntax = "janet"