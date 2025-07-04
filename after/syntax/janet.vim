" Safe syntax highlighting enhancements for Judge test forms in Janet files
" This only adds simple keyword highlighting

" Only run if this is a Janet file
if &filetype != 'janet'
  finish
endif

" Don't load multiple times
if exists("b:judge_syntax_loaded")
  finish
endif
let b:judge_syntax_loaded = 1

" Only add simple keyword highlighting - no complex regions
if exists("*synIDattr")
  " Judge test keywords - simple and safe
  syn keyword janetJudgeTest test test-error test-stdout test-macro trust deftest deftest-type contained
  syn keyword janetJudgeTestType deftest: contained
  
  " Simple matches for test results indicators
  syn match janetJudgeTestPassed /✓/ contained
  syn match janetJudgeTestFailed /✗/ contained
  
  " Link to safe highlight groups
  hi def link janetJudgeTest Statement
  hi def link janetJudgeTestType Statement
  hi def link janetJudgeTestPassed Number
  hi def link janetJudgeTestFailed Error
endif