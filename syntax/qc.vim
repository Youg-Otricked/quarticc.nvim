if exists("b:current_syntax")
  finish
endif
syn keyword qcStructure   namespace class struct enum union concept type fn
syn keyword qcStorage     static extern foreign const volatile restrict atomic comptime
syn keyword qcStorage     out inout
syn keyword qcModifier    abstract virtual override final friend friendly
syn keyword qcModifier    public private protected operator roperator modifier
syn keyword qcConditional if else switch match case default qif qelif qelse qswitch
syn keyword qcRepeat      for foreach while do loop
syn keyword qcStatement   return break continue goto jmp try catch throw defer unreachable
syn keyword qcType        int long short double float char bool void auto string typeof
syn keyword qcType        byte nibble qbool addr_t ai64_t ai64u_t i32u_t i16u_t
syn keyword qcProof       proves proved_by with_proof all_of _of at_least
syn keyword qcHook        on_call on_return on_use
syn keyword qcKeyword     sizeof as in
syn keyword qcConstant    true false qtrue qfalse both none nullptr
syn keyword qcBuiltin     __qc_version
syn match qcOperator      "[-+*%&|^~!<>=$?@:]"
syn match qcOperator      "/\%(/\|\*\)\@!"
syn match qcOperator      "#\^"
syn match qcOperator      "\.\.\."
syn match qcNumber        "\<\d[0-9']*\(\.[0-9']*\)\?\([flsyn]\|[au]\(ll\|l\)\?\)\?\>"
syn match qcNumber        "\<0[xX][0-9a-fA-F']\+\([lisyn]\|u\(ll\|l\)\?\)\?\>"
syn match qcNumber        "\<0[oO][0-7']\+\([lisyn]\|u\(ll\|l\)\?\)\?\>"
syn match qcNumber        "\<0[bB][01']\+\([lisyn]\|u\(ll\|l\)\?\)\?\>"
syn match qcEscape        "\\\(['\"abtnvfre\\]\|x\x\x\|[0-7]\{1,3}\)" contained
syn region qcString       start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=qcEscape
syn region qcFString      start=+\<f"+ skip=+\\\\\|\\"+ end=+"+ contains=qcEscape,qcInterp,qcFBrace
syn region qcInterp       matchgroup=qcDelim start="{" end="}" contained contains=TOP,qcInterp
syn match  qcFBrace       "{{\|}}" contained
syn region qcRawString    start=+\<R"\w*(+ end=+)\w*"+
syn match qcChar          "'\([^'\\]\|\\\(x\x\x\|[0-7]\{1,3}\|.\)\)'"
syn match qcInclude "^\s*#\(include\|link\|searchdir\|depends\|if\|ifndef\|ifdef\|else\|define\|undef\)\>"
syn match qcCInterop      "`[A-Za-z0-9_`]*"
syn match qcNamespace     "\<\h\w*\ze::"
syn match qcFunction      "\<\h\w*\ze\s*("
syn match   qcComment     "//.*$"
syn region  qcComment     start="/\*" end="\*/"
hi def link qcStructure   Structure
hi def link qcStorage     StorageClass
hi def link qcModifier    Keyword
hi def link qcKeyword     Keyword
hi def link qcConditional Conditional
hi def link qcRepeat      Repeat
hi def link qcStatement   Statement
hi def link qcType        Type
hi def link qcProof       Special
hi def link qcHook        Label
hi def link qcConstant    Constant
hi def link qcBuiltin     Special
hi def link qcComment     Comment
hi def link qcString      String
hi def link qcFString     String
hi def link qcRawString   String
hi def link qcChar        Character
hi def link qcEscape      SpecialChar
hi def link qcFBrace      SpecialChar
hi def link qcDelim       Delimiter
hi def link qcNumber      Number
hi def link qcInclude     PreProc
hi def link qcCInterop    Macro
hi def link qcNamespace   Identifier
hi def link qcFunction    Function
hi def link qcOperator    Operator
let b:current_syntax = "qc"
