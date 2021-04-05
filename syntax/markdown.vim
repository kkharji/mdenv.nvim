scriptencoding utf-8
" vim: set fdm=marker foldlevel=0:
" modified version of vim-pandoc/vim-pandoc-syntax Md syntax file.
"
" Version: 5.1
" ------------------------------------------------------------------

" Configuration: {{{1
" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax") | finish | endif

syntax clear
syntax spell toplevel

let s:cpo_save = &cpo
set cpo&vim

" Load user configuration
let s:v = v:lua.require('mdenv.config').values.syntax

" Modify local settings to reflect mdenv configurations.
let &l:conceallevel = s:v.conceal.level
let &l:concealcursor = s:v.conceal.cursor

" If markup is false, add it to conceal.blacklist
if !s:v.conceal.markup | call add(s:v.conceal.blacklist, 'markup') | endif

" }}}1

" Functions: {{{1
" TODO: move to autoload or something. don't expose globally.
" EnableEmbedsforCodeblocksWithLang {{{2
function! EnableEmbedsforCodeblocksWithLang(entry)
  " prevent embedded language syntaxes from changing 'foldmethod'
  if has('folding')
    let s:foldmethod = &l:foldmethod
    let s:foldtext = &l:foldtext
  endif

  try
    let s:langname = matchstr(a:entry, '^[^=]*')
    let s:langsyntaxfile = matchstr(a:entry, '[^=]*$')
    unlet! b:current_syntax
    exe 'syn include @'.toupper(s:langname).' syntax/'.s:langsyntaxfile.'.vim'
    exe 'syn region MdDelimitedCodeBlock_' . s:langname . ' start=/\(\_^\([ ]\{4,}\|\t\)\=\(`\{3,}`*\|\~\{3,}\~*\)\s*\%({[^.]*\.\)\=' . s:langname . '\>.*\n\)\@<=\_^/' .
          \' end=/\_$\n\(\([ ]\{4,}\|\t\)\=\(`\{3,}`*\|\~\{3,}\~*\)\_$\n\_$\)\@=/ contained containedin=MdDelimitedCodeBlock' .
          \' contains=@' . toupper(s:langname)
    exe 'syn region MdDelimitedCodeBlockinBlockQuote_' . s:langname . ' start=/>\s\(`\{3,}`*\|\~\{3,}\~*\)\s*\%({[^.]*\.\)\=' . s:langname . '\>/' .
          \ ' end=/\(`\{3,}`*\|\~\{3,}\~*\)/ contained containedin=MdDelimitedCodeBlock' .
          \' contains=@' . toupper(s:langname) .
          \',MdDelimitedCodeBlockStart,MdDelimitedCodeBlockEnd,MdDelimitedCodeblockLang,MdBlockQuoteinDelimitedCodeBlock'
    " TODO: dim codeblock background
    " exe 'hi MdDelimitedCodeBlock_'.s:langname . ' guibg=yallow ctermbg=yellow'
    " exe 'hi MdDelimitedCodeBlockinBlockQuote_'.s:langname . ' guibg=yellow ctermbg=yellow'
  catch /E484/
    echo "No syntax file found for '" . s:langsyntaxfile . "'"
  endtry

  if exists('s:foldmethod') && s:foldmethod !=# &l:foldmethod
    let &l:foldmethod = s:foldmethod
  endif
  if exists('s:foldtext') && s:foldtext !=# &l:foldtext
    let &l:foldtext = s:foldtext
  endif
endfunction
" }}}2

" DisableEmbedsforCodeblocksWithLang {{{2
function! DisableEmbedsforCodeblocksWithLang(langname)
  try
    exe 'syn clear MdDelimitedCodeBlock_'.a:langname
    exe 'syn clear MdDelimitedCodeBlockinBlockQuote_'.a:langname
  catch /E28/
    echo "No existing highlight definitions found for '" . a:langname . "'"
  endtry
endfunction
" }}}2

" WithConceal {{{2
" NOTE: would be better for performance if this function only adds to a list
" that gets executed in the end of the file.
function! s:WithConceal(rule_group, rule, conceal_rule)
  let l:rule_tail = ''
  if s:v.conceal.enable
    if index(s:v.conceal.blacklist, a:rule_group) == -1
      let l:rule_tail = ' ' . a:conceal_rule
    endif
  endif
  execute a:rule . l:rule_tail
endfunction
" }}}2
" }}}1

" Commands: {{{1
command! -buffer -nargs=1 -complete=syntax MHighlight call EnableEmbedsforCodeblocksWithLang(<f-args>)
command! -buffer -nargs=1 -complete=syntax MUnhighlight call DisableEmbedsforCodeblocksWithLang(<f-args>)
" }}}1

" ------------------------------------------------------------------

" NOTE: Conceal set background that doesn't play well with cursorlines.
hi Conceal guibg=NONE

" Embeds: {{{1

" Prevent embedded language syntaxes from changing 'foldmethod'
if has('folding')
  let s:foldmethod = &l:foldmethod
endif

" HTML: {{{2
" embedded HTML highlighting
if s:v.include.html

  syn include @HTML syntax/html.vim
  syn match MdHTML /<\/\?\a\_.\{-}>/ contains=@HTML

  " Support HTML multi line comments
  syn region MdHTMLComment start=/<!--\s\=/ end=/\s\=-->/ keepend contains=MdHTMLCommentStart,MdHTMLCommentEnd

  " Conceal comments
  call s:WithConceal('comment_start', 'syn match MdHTMLCommentStart /<!--/ contained', 'conceal cchar='.s:v.conceal.chars['comment_start'])
  call s:WithConceal('comment_end', 'syn match MdHTMLCommentEnd /-->/ contained', 'conceal cchar='.s:v.conceal.chars['comment_end'])
endif
" }}}2

" LaTeX: {{{2
" embedded LaTex highlighting

if s:v.include.tex

  " Unset current_syntax so the 2nd include will work
  unlet b:current_syntax

  syn include @LATEX syntax/tex.vim
  syn region MdLaTeXInlineMath start=/\v\\@<!\$\S@=/ end=/\v\\@<!\$\d@!/ keepend contains=@LATEX
  syn region MdLaTeXInlineMath start=/\\\@<!\\(/ end=/\\\@<!\\)/ keepend contains=@LATEX

  syn match MdEscapedDollar /\\\$/ conceal cchar=$
  syn match MdProtectedFromInlineLaTeX /\\\@<!\${.*}\(\(\s\|[[:punct:]]\)\([^$]*\|.*\(\\\$.*\)\{2}\)\n\n\|$\)\@=/ display

  " contains=@LATEX
  syn region MdLaTeXMathBlock start=/\$\$/ end=/\$\$/ keepend contains=@LATEX
  syn region MdLaTeXMathBlock start=/\\\@<!\\\[/ end=/\\\@<!\\\]/ keepend contains=@LATEX
  syn match MdLaTeXCommand /\\[[:alpha:]]\+\(\({.\{-}}\)\=\(\[.\{-}\]\)\=\)*/ contains=@LATEX
  syn region MdLaTeXRegion start=/\\begin{\z(.\{-}\)}/ end=/\\end{\z1}/ keepend contains=@LATEX

  " we rehighlight sectioning commands, because otherwise tex.vim captures all text until EOF or a new sectioning command
  syn region MdLaTexSection start=/\\\(part\|chapter\|\(sub\)\{,2}section\|\(sub\)\=paragraph\)\*\=\(\[.*\]\)\={/ end=/\}/ keepend
  syn match MdLaTexSectionCmd /\\\(part\|chapter\|\(sub\)\{,2}section\|\(sub\)\=paragraph\)/ contained containedin=MdLaTexSection
  syn match MdLaTeXDelimiter /[[\]{}]/ contained containedin=MdLaTexSection
endif
" }}}2

if exists('s:foldmethod') && s:foldmethod !=# &l:foldmethod
  let &l:foldmethod = s:foldmethod
endif

" }}}1

" Titleblock: {{{1
syn region MdTitleBlock start=/\%^%/ end=/\n\n/ contains=MdReferenceLabel,MdReferenceURL,MdNewLine

call s:WithConceal('titleblock', 'syn match MdTitleBlockMark /%\ / contained containedin=MdTitleBlock,MdTitleBlockTitle', 'conceal')

syn match MdTitleBlockTitle /\%^%.*\n/ contained containedin=MdTitleBlock
" }}}1

" Blockquotes: {{{1
" TODO: conceal
syn match MdBlockQuote /^\s\{,3}>.*\n\(.*\n\@1<!\n\)*/ contains=@Spell,MdEmphasis,MdStrong,MdPCite,MdSuperscript,MdSubscript,MdStrikeout,MdUListItem,MdNoFormatted,MdAmpersandEscape,MdLaTeXInlineMath,MdEscapedDollar,MdLaTeXCommand,MdLaTeXMathBlock,MdLaTeXRegion skipnl
syn match MdBlockQuoteMark /\_^\s\{,3}>/ contained containedin=MdEmphasis,MdStrong,MdPCite,MdSuperscript,MdSubscript,MdStrikeout,MdUListItem,MdNoFormatted
" call s:WithConceal('quote', 'syn match MdBlockQuoteMark /\_^\s\{,3}>/ contained containedin=MdEmphasis,MdStrong,MdPCite,MdSuperscript,MdSubscript,MdStrikeout,MdUListItem,MdNoFormatted', 'conceal cchar='.s:v.conceal.chars['quote'])
" }}}1

" CodeBlocks: {{{1

"if g:Md#syntax#protect#codeblocks == 1
syn match MdCodeblock /\([ ]\{4}\|\t\).*$/
"endif
syn region MdCodeBlockInsideIndent   start=/\(\(\d\|\a\|*\).*\n\)\@<!\(^\(\s\{8,}\|\t\+\)\).*\n/ end=/.\(\n^\s*\n\)\@=/ contained
" }}}1

" BaseLink: {{{1
syn region MdReferenceLabel matchgroup=MdOperator start=/!\{,1}\\\@<!\^\@<!\[/ skip=/\(\\\@<!\]\]\@=\|`.*\\\@<!].*`\)/ end=/\\\@<!\]/ keepend display

if s:v.conceal.url
  syn region MdReferenceURL matchgroup=MdOperator start=/\]\@1<=(/ end=/)/ keepend conceal
else
  syn region MdReferenceURL matchgroup=MdOperator start=/\]\@1<=(/ end=/)/ keepend
endif

" let's not consider "a [label] a" as a label, remove formatting - Note: breaks implicit links
syn match MdNoLabel /\]\@1<!\(\s\{,3}\|^\)\[[^\[\]]\{-}\]\(\s\+\|$\)[\[(]\@!/ contains=MdPCite
syn match MdLinkTip /\s*".\{-}"/ contained containedin=MdReferenceURL contains=MdAmpersandEscape display
" }}}1

" DefinitionsLinks: {{{1
syn region MdReferenceDefinition start="!\=\[\%(\_[^]]*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@=" keepend
syn match MdReferenceDefinitionLabel /\[\zs.\{-}\ze\]:/ contained containedin=MdReferenceDefinition display
syn match MdReferenceDefinitionAddress /:\s*\zs.*/ contained containedin=MdReferenceDefinition
syn match MdReferenceDefinitionTip /\s*".\{-}"/ contained containedin=MdReferenceDefinition,MdReferenceDefinitionAddress contains=MdAmpersandEscape
" }}}1

" AutomaticLinks: {{{1
syn match MdAutomaticLink /<\(https\{0,1}.\{-}\|[A-Za-z0-9!#$%&'*+\-/=?^_`{|}~.]\{-}@[A-Za-z0-9\-]\{-}\.\w\{-}\)>/ contains=NONE
" }}}1

" }}}1

" CitationsLinks: {{{1
" parenthetical citations
syn match MdPCite "\^\@<!\[[^\[\]]\{-}-\{0,1}@[[:alnum:]_][[:digit:][:lower:][:upper:]_:.#$%&\-+?<>~/]*.\{-}\]" contains=MdEmphasis,MdStrong,MdLatex,MdCiteKey,@Spell,MdAmpersandEscape display
" in-text citations with location
syn match MdICite "@[[:alnum:]_][[:digit:][:lower:][:upper:]_:.#$%&\-+?<>~/]*\s\[.\{-1,}\]" contains=MdCiteKey,@Spell display
" cite keys
syn match MdCiteKey /\(-\=@[[:alnum:]_][[:digit:][:lower:][:upper:]_:.#$%&\-+?<>~/]*\)/ containedin=MdPCite,MdICite contains=@NoSpell display
syn match MdCiteAnchor /[-@]/ contained containedin=MdCiteKey display
syn match MdCiteLocator /[\[\]]/ contained containedin=MdPCite,MdICite
" }}}1

" Emphasis: {{{1
call s:WithConceal('markup', 'syn region MdEmphasis matchgroup=MdOperator start=/\\\@1<!\(\_^\|\s\|[[:punct:]]\)\@<=\*\S\@=/ skip=/\(\*\*\|__\)/ end=/\*\([[:punct:]]\|\s\|\_$\)\@=/ contains=@Spell,MdNoFormattedInEmphasis,MdLatexInlineMath,MdAmpersandEscape', 'concealends')
call s:WithConceal('markup', 'syn region MdEmphasis matchgroup=MdOperator start=/\\\@1<!\(\_^\|\s\|[[:punct:]]\)\@<=_\S\@=/ skip=/\(\*\*\|__\)/ end=/\S\@1<=_\([[:punct:]]\|\s\|\_$\)\@=/ contains=@Spell,MdNoFormattedInEmphasis,MdLatexInlineMath,MdAmpersandEscape', 'concealends')
" }}}1

" Strong: {{{1
call s:WithConceal('markup', 'syn region MdStrong matchgroup=MdOperator start=/\(\\\@<!\*\)\{2}/ end=/\(\\\@<!\*\)\{2}/ contains=@Spell,MdNoFormattedInStrong,MdLatexInlineMath,MdAmpersandEscape', 'concealends')
call s:WithConceal('markup', 'syn region MdStrong matchgroup=MdOperator start=/__/ end=/__/ contains=@Spell,MdNoFormattedInStrong,MdLatexInlineMath,MdAmpersandEscape', 'concealends')
" }}}1

" Strong Emphasis: {{{1
call s:WithConceal('markup', 'syn region MdStrongEmphasis matchgroup=MdOperator start=/\*\{3}\(\S[^*]*\(\*\S\|\n[^*]*\*\S\)\)\@=/ end=/\S\@<=\*\{3}/ contains=@Spell,MdAmpersandEscape', 'concealends')
call s:WithConceal('markup', 'syn region MdStrongEmphasis matchgroup=MdOperator start=/\(___\)\S\@=/ end=/\S\@<=___/ contains=@Spell,MdAmpersandEscape', 'concealends')
" }}}1

" Mixed: {{{1
call s:WithConceal('markup', 'syn region MdStrongInEmphasis matchgroup=MdOperator start=/\*\*/ end=/\*\*/ contained containedin=MdEmphasis contains=@Spell,MdAmpersandEscape', 'concealends')
call s:WithConceal('markup', 'syn region MdStrongInEmphasis matchgroup=MdOperator start=/__/ end=/__/ contained containedin=MdEmphasis contains=@Spell,MdAmpersandEscape', 'concealends')
call s:WithConceal('markup', 'syn region MdEmphasisInStrong matchgroup=MdOperator start=/\\\@1<!\(\_^\|\s\|[[:punct:]]\)\@<=\*\S\@=/ skip=/\(\*\*\|__\)/ end=/\S\@<=\*\([[:punct:]]\|\s\|\_$\)\@=/ contained containedin=MdStrong contains=@Spell,MdAmpersandEscape', 'concealends')
call s:WithConceal('markup', 'syn region MdEmphasisInStrong matchgroup=MdOperator start=/\\\@<!\(\_^\|\s\|[[:punct:]]\)\@<=_\S\@=/ skip=/\(\*\*\|__\)/ end=/\S\@<=_\([[:punct:]]\|\s\|\_$\)\@=/ contained containedin=MdStrong contains=@Spell,MdAmpersandEscape', 'concealends')
" }}}1

" Inline Code: {{{1
" Using single back ticks
call s:WithConceal('inlinecode', 'syn region MdNoFormatted matchgroup=MdOperator start=/\\\@<!`/ end=/\\\@<!`/ nextgroup=MdNoFormattedAttrs', 'concealends')
call s:WithConceal('inlinecode', 'syn region MdNoFormattedInEmphasis matchgroup=MdOperator start=/\\\@<!`/ end=/\\\@<!`/ nextgroup=MdNoFormattedAttrs contained', 'concealends')
call s:WithConceal('inlinecode', 'syn region MdNoFormattedInStrong matchgroup=MdOperator start=/\\\@<!`/ end=/\\\@<!`/ nextgroup=MdNoFormattedAttrs contained', 'concealends')
" Using double back ticks
call s:WithConceal('inlinecode', 'syn region MdNoFormatted matchgroup=MdOperator start=/\\\@<!``/ end=/\\\@<!``/ nextgroup=MdNoFormattedAttrs', 'concealends')
call s:WithConceal('inlinecode', 'syn region MdNoFormattedInEmphasis matchgroup=MdOperator start=/\\\@<!``/ end=/\\\@<!``/ nextgroup=MdNoFormattedAttrs contained', 'concealends')
call s:WithConceal('inlinecode', 'syn region MdNoFormattedInStrong matchgroup=MdOperator start=/\\\@<!``/ end=/\\\@<!``/ nextgroup=MdNoFormattedAttrs contained', 'concealends')
syn match MdNoFormattedAttrs /{.\{-}}/ contained
" }}}1

" Subscripts: {{{1
syn region MdSubscript start=/\~\(\([[:graph:]]\(\\ \)\=\)\{-}\~\)\@=/ end=/\~/ keepend
call s:WithConceal('subscript', 'syn match MdSubscriptMark /\~/ contained containedin=MdSubscript', 'conceal cchar='.s:v.conceal.chars['sub'])
" }}}1

" Superscript: {{{1
syn region MdSuperscript start=/\^\(\([[:graph:]]\(\\ \)\=\)\{-}\^\)\@=/ skip=/\\ / end=/\^/ keepend
call s:WithConceal('superscript', 'syn match MdSuperscriptMark /\^/ contained containedin=MdSuperscript', 'conceal cchar='.s:v.conceal.chars['super'])
" }}}1

" Strikeout: {{{1
syn region MdStrikeout start=/\~\~/ end=/\~\~/ contains=@Spell,MdAmpersandEscape keepend
" }}}1

" }}}1

" Headers: {{{1
syn match MdAtxHeader /\(\%^\|<.\+>.*\n\|^\s*\n\)\@<=#\{1,6}.*\n/ contains=MdEmphasis,MdStrong,MdNoFormatted,MdLaTeXInlineMath,MdEscapedDollar,@Spell,MdAmpersandEscape,MdReferenceLabel,MdReferenceURL display
syn match MdAtxHeaderMark /\(^#\{1,6}\|\\\@<!#\+\(\s*.*$\)\@=\)/ contained containedin=MdAtxHeader
call s:WithConceal('atx', 'syn match MdAtxStart /#/ contained containedin=MdAtxHeaderMark', 'conceal cchar='.s:v.conceal.chars['atx'])
syn match MdSetexHeader /^.\+\n[=]\+$/ contains=MdEmphasis,MdStrong,MdNoFormatted,MdLaTeXInlineMath,MdEscapedDollar,@Spell,MdAmpersandEscape
syn match MdSetexHeader /^.\+\n[-]\+$/ contains=MdEmphasis,MdStrong,MdNoFormatted,MdLaTeXInlineMath,MdEscapedDollar,@Spell,MdAmpersandEscape
syn match MdHeaderAttr /{.*}/ contained containedin=MdAtxHeader,MdSetexHeader
syn match MdHeaderID /#[-_:.[:lower:][:upper:]]*/ contained containedin=MdHeaderAttr
" }}}1

" Line Blocks: {{{1
syn region MdLineBlock start=/^|/ end=/\(^|\(.*\n|\@!\)\@=.*\)\@<=\n/ transparent
syn match MdLineBlockDelimiter /^|/ contained containedin=MdLineBlock
" }}}1

" Simple: {{{1
syn region MdSimpleTable start=/\%#=2\(^.*[[:graph:]].*\n\)\@<!\(^.*[[:graph:]].*\n\)\(-\{2,}\s*\)\+\n\n\@!/ end=/\n\n/ containedin=ALLBUT,MdDelimitedCodeBlock,MdYAMLHeader keepend
syn match MdSimpleTableDelims /\-/ contained containedin=MdSimpleTable
syn match MdSimpleTableHeader /\%#=2\(^.*[[:graph:]].*\n\)\@<!\(^.*[[:graph:]].*\n\)/ contained containedin=MdSimpleTable

syn region MdTable start=/\%#=2^\(-\{2,}\s*\)\+\n\n\@!/ end=/\%#=2^\(-\{2,}\s*\)\+\n\n/ containedin=ALLBUT,MdDelimitedCodeBlock,MdYAMLHeader keepend
syn match MdTableDelims /\-/ contained containedin=MdTable
syn region MdTableMultilineHeader start=/\%#=2\(^-\{2,}\n\)\@<=./ end=/\%#=2\n-\@=/ contained containedin=MdTable
" }}}1

" Grid: {{{1
syn region MdGridTable start=/\%#=2\n\@1<=+-/ end=/+\n\n/ containedin=ALLBUT,MdDelimitedCodeBlock,MdYAMLHeader keepend
syn match MdGridTableDelims /[\|=]/ contained containedin=MdGridTable
syn match MdGridTableDelims /\%#=2\([\-+][\-+=]\@=\|[\-+=]\@1<=[\-+]\)/ contained containedin=MdGridTable
syn match MdGridTableHeader /\%#=2\(^.*\n\)\(+=.*\)\@=/ contained containedin=MdGridTable
" }}}1

" Pipe: {{{1
" with beginning and end pipes
syn region MdPipeTable start=/\%#=2\([+|]\n\)\@<!\n\@1<=|\(.*|\)\@=/ end=/|.*\n\(\n\|{\)/ containedin=ALLBUT,MdDelimitedCodeBlock,MdYAMLHeader keepend
" without beginning and end pipes
syn region MdPipeTable start=/\%#=2^.*\n-.\{-}|/ end=/|.*\n\n/ keepend
syn match MdPipeTableDelims /[\|\-:+]/ contained containedin=MdPipeTable
syn match MdPipeTableHeader /\(^.*\n\)\(|-\)\@=/ contained containedin=MdPipeTable
syn match MdPipeTableHeader /\(^.*\n\)\(-\)\@=/ contained containedin=MdPipeTable
" }}}1

syn match MdTableHeaderWord /\<.\{-}\>/ contained containedin=MdGridTableHeader,MdPipeTableHeader contains=@Spell
" }}}1

" Delimited Code Blocks: {{{1
" this is here because we can override strikeouts and subscripts
syn region MdDelimitedCodeBlock start=/^\(>\s\)\?\z(\([ ]\{4,}\|\t\)\=\~\{3,}\~*\)/ end=/^\z1\~*/ skipnl contains=MdDelimitedCodeBlockStart,MdDelimitedCodeBlockEnd keepend
syn region MdDelimitedCodeBlock start=/^\(>\s\)\?\z(\([ ]\{4,}\|\t\)\=`\{3,}`*\)/ end=/^\z1`*/ skipnl contains=MdDelimitedCodeBlockStart,MdDelimitedCodeBlockEnd keepend
call s:WithConceal('codeblock_start', 'syn match MdDelimitedCodeBlockStart /\(\(\_^\n\_^\|\%^\)\(>\s\)\?\([ ]\{4,}\|\t\)\=\)\@<=\(\~\{3,}\~*\|`\{3,}`*\)/ contained containedin=MdDelimitedCodeBlock nextgroup=MdDelimitedCodeBlockLanguage', 'conceal cchar='.s:v.conceal.chars['codelang'])
syn match MdDelimitedCodeBlockLanguage /\(\s\?\)\@<=.\+\(\_$\)\@=/ contained
call s:WithConceal('codeblock_delim', 'syn match MdDelimitedCodeBlockEnd /\(`\{3,}`*\|\~\{3,}\~*\)\(\_$\n\(>\s\)\?\_$\)\@=/ contained containedin=MdDelimitedCodeBlock', 'conceal cchar='.s:v.conceal.chars['codeend'])
syn match MdBlockQuoteinDelimitedCodeBlock '^>' contained containedin=MdDelimitedCodeBlock
syn match MdCodePre /<pre>.\{-}<\/pre>/ skipnl
syn match MdCodePre /<code>.\{-}<\/code>/ skipnl

" }}}1

" Abbreviations: {{{1
syn region MdAbbreviationDefinition start=/^\*\[.\{-}\]:\s*/ end='$' contains=MdNoFormatted,@Spell,MdAmpersandEscape
call s:WithConceal('abbrev', 'syn match MdAbbreviationSeparator /:/ contained containedin=MdAbbreviationDefinition', 'conceal cchar='.s:v.conceal.chars['abbrev'])
syn match MdAbbreviation /\*\[.\{-}\]/ contained containedin=MdAbbreviationDefinition
call s:WithConceal('abbrev', 'syn match MdAbbreviationHead /\*\[/ contained containedin=MdAbbreviation', 'conceal')
call s:WithConceal('abbrev', 'syn match MdAbbreviationTail /\]/ contained containedin=MdAbbreviation', 'conceal')
" }}}1

" Footnotes: {{{1
" we put these here not to interfere with superscripts.
syn match MdFootnoteID /\[\^[^\]]\+\]/ nextgroup=MdFootnoteDef

"   Inline footnotes
syn region MdFootnoteDef start=/\^\[/ skip=/\[.\{-}]/ end=/\]/ contains=MdReferenceLabel,MdReferenceURL,MdLatex,MdPCite,MdCiteKey,MdStrong,MdEmphasis,MdStrongEmphasis,MdNoFormatted,MdSuperscript,MdSubscript,MdStrikeout,MdEnDash,MdEmDash,MdEllipses,MdBeginQuote,MdEndQuote,@Spell,MdAmpersandEscape skipnl keepend
call s:WithConceal('footnote', 'syn match MdFootnoteDefHead /\^\[/ contained containedin=MdFootnoteDef', 'conceal cchar='.s:v.conceal.chars['footnote'])
call s:WithConceal('footnote', 'syn match MdFootnoteDefTail /\]/ contained containedin=MdFootnoteDef', 'conceal')

" regular footnotes
syn region MdFootnoteBlock start=/\[\^.\{-}\]:\s*\n*/ end=/^\n^\s\@!/ contains=MdReferenceLabel,MdReferenceURL,MdLatex,MdPCite,MdCiteKey,MdStrong,MdEmphasis,MdNoFormatted,MdSuperscript,MdSubscript,MdStrikeout,MdEnDash,MdEmDash,MdNewLine,MdStrongEmphasis,MdEllipses,MdBeginQuote,MdEndQuote,MdLaTeXInlineMath,MdEscapedDollar,MdLaTeXCommand,MdLaTeXMathBlock,MdLaTeXRegion,MdAmpersandEscape,@Spell skipnl
syn match MdFootnoteBlockSeparator /:/ contained containedin=MdFootnoteBlock
syn match MdFootnoteID /\[\^.\{-}\]/ contained containedin=MdFootnoteBlock
call s:WithConceal('footnote', 'syn match MdFootnoteIDHead /\[\^/ contained containedin=MdFootnoteID', 'conceal cchar='.s:v.conceal.chars['footnote'])
call s:WithConceal('footnote', 'syn match MdFootnoteIDTail /\]/ contained containedin=MdFootnoteID', 'conceal')
" }}}1

" List Items: {{{1
" Unordered lists
syn match MdUListItem /^>\=\s*[*+-]\s\+-\@!.*$/ nextgroup=MdUListItem,MdLaTeXMathBlock,MdLaTeXInlineMath,MdEscapedDollar,MdDelimitedCodeBlock,MdListItemContinuation contains=@Spell,MdEmphasis,MdStrong,MdNoFormatted,MdStrikeout,MdSubscript,MdSuperscript,MdStrongEmphasis,MdStrongEmphasis,MdPCite,MdICite,MdCiteKey,MdReferenceLabel,MdLaTeXCommand,MdLaTeXMathBlock,MdLaTeXInlineMath,MdEscapedDollar,MdReferenceURL,MdAutomaticLink,MdFootnoteDef,MdFootnoteBlock,MdFootnoteID,MdAmpersandEscape skipempty display
call s:WithConceal('list', 'syn match MdUListItemBullet /^>\=\s*\zs[*+-]/ contained containedin=MdUListItem', 'conceal cchar='.s:v.conceal.chars['list'])

" Ordered lists
syn match MdListItem /^\s*(\?\(\d\+\|\l\|\#\|@\)[.)].*$/ nextgroup=MdListItem,MdLaTeXMathBlock,MdLaTeXInlineMath,MdEscapedDollar,MdDelimitedCodeBlock,MdListItemContinuation contains=@Spell,MdEmphasis,MdStrong,MdNoFormatted,MdStrikeout,MdSubscript,MdSuperscript,MdStrongEmphasis,MdStrongEmphasis,MdPCite,MdICite,MdCiteKey,MdReferenceLabel,MdLaTeXCommand,MdLaTeXMathBlock,MdLaTeXInlineMath,MdEscapedDollar,MdAutomaticLink,MdFootnoteDef,MdFootnoteBlock,MdFootnoteID,MdAmpersandEscape skipempty display

" support for roman numerals up to 'c'
if s:v.roman_lists
    syn match MdListItem /^\s*(\?x\=l\=\(i\{,3}[vx]\=\)\{,3}c\{,3}[.)].*$/ nextgroup=MdListItem,MdMathBlock,MdLaTeXInlineMath,MdEscapedDollar,MdDelimitedCodeBlock,MdListItemContinuation,MdAutomaticLink skipempty display
endif
syn match MdListItemBullet /^(\?.\{-}[.)]/ contained containedin=MdListItem
syn match MdListItemBulletId /\(\d\+\|\l\|\#\|@.\{-}\|x\=l\=\(i\{,3}[vx]\=\)\{,3}c\{,3}\)/ contained containedin=MdListItemBullet

syn match MdListItemContinuation /^\s\+\([-+*]\s\+\|(\?.\+[).]\)\@<!\([[:upper:][:lower:]_"[]\|\*\S\)\@=.*$/ nextgroup=MdLaTeXMathBlock,MdLaTeXInlineMath,MdEscapedDollar,MdDelimitedCodeBlock,MdListItemContinuation,MdListItem contains=@Spell,MdEmphasis,MdStrong,MdNoFormatted,MdStrikeout,MdSubscript,MdSuperscript,MdStrongEmphasis,MdStrongEmphasis,MdPCite,MdICite,MdCiteKey,MdReferenceLabel,MdReferenceURL,MdLaTeXCommand,MdLaTeXMathBlock,MdLaTeXInlineMath,MdEscapedDollar,MdAutomaticLink,MdFootnoteDef,MdFootnoteBlock,MdFootnoteID,MdAmpersandEscape contained skipempty display
" }}}1

" Definitions: {{{1
if s:v.definition_lists
    syn region MdDefinitionBlock start=/^\%(\_^\s*\([`~]\)\1\{2,}\)\@!.*\n\(^\s*\n\)\=\s\{0,2}\([:~]\)\(\3\{2,}\3*\)\@!/ skip=/\n\n\zs\s/ end=/\n\n/ contains=MdDefinitionBlockMark,MdDefinitionBlockTerm,MdCodeBlockInsideIndent,MdEmphasis,MdStrong,MdStrongEmphasis,MdNoFormatted,MdStrikeout,MdSubscript,MdSuperscript,MdFootnoteID,MdReferenceURL,MdReferenceLabel,MdLaTeXMathBlock,MdLaTeXInlineMath,MdEscapedDollar,MdAutomaticLink,MdEmDash,MdEnDash,MdFootnoteDef,MdFootnoteBlock,MdFootnoteID
    syn match MdDefinitionBlockTerm /^.*\n\(^\s*\n\)\=\(\s*[:~]\)\@=/ contained contains=MdNoFormatted,MdEmphasis,MdStrong,MdLaTeXInlineMath,MdEscapedDollar,MdFootnoteDef,MdFootnoteBlock,MdFootnoteID nextgroup=MdDefinitionBlockMark

    call s:WithConceal('definition', 'syn match MdDefinitionBlockMark /^\s*[:~]/ contained', 'conceal cchar='.s:v.conceal.chars['definition'])
endif
" }}}1

" Emdashes: {{{1
if &encoding ==# 'utf-8'
  call s:WithConceal('emdashes', 'syn match MdEllipses /\([^-]\)\@<=---\([^-]\)\@=/ display', 'conceal cchar=—')
endif
" }}}1

" Endashes: {{{1
if &encoding ==# 'utf-8'
  call s:WithConceal('endashes', 'syn match MdEllipses /\([^-]\)\@<=--\([^-]\)\@=/ display', 'conceal cchar=–')
endif
" }}}1

" Ellipses: {{{1
if &encoding ==# 'utf-8'
    call s:WithConceal('ellipses', 'syn match MdEllipses /\.\.\./ display', 'conceal cchar=…')
endif
" }}}1

" Quotes: {{{1
if &encoding ==# 'utf-8'
    call s:WithConceal('quotes', 'syn match MdBeginQuote /"\</  containedin=MdEmphasis,MdStrong,MdListItem,MdListItemContinuation,MdUListItem display', 'conceal cchar=“')
    call s:WithConceal('quotes', 'syn match MdEndQuote /\(\>[[:punct:]]*\)\@<="[[:blank:][:punct:]\n]\@=/  containedin=MdEmphasis,MdStrong,MdUListItem,MdListItem,MdListItemContinuation display', 'conceal cchar=”')
endif
" }}}1

" Hrule: {{{1
syn match MdHRule /^\s*\([*\-_]\)\s*\%(\1\s*\)\{2,}$/ display
" }}}1

" &-escaped Special Characters: {{{1
syn match MdAmpersandEscape /\v\&(#\d+|#x\x+|[[:alnum:]]+)\;/ contains=NoSpell
" }}}1

" Checkboxs {{{1
" TODO: Highlight checkboxs and conecal with the chars defined
" syn region   MdCheckboxEmpty start='- \[ ' end='\]'
" syn region   MdCheckboxPending start='- \[-\]' end='\]'
" syn region   MdCheckboxComplete start='- \[ ' end='\]'

" call s:WithConceal('checkbox', 'syn region MdCheckboxEmpty start="- \[ " end="]" contained', 'conceal cchar='.s:v.conceal.chars['checkbox_empty'])
" call s:WithConceal('checkbox', 'syn region MdCheckboxPending start="- \[-" end="]" contained', 'conceal cchar='.s:v.conceal.chars['checkbox_pending'])
" call s:WithConceal('checkbox', 'syn region MdCheckboxComplete start="- \[x" end="]" contained', 'conceal cchar='.s:v.conceal.chars['checkbox_done'])
" call s:WithConceal('checkbox', 'syn region MdCheckboxEmpty matchgroup=MdCheckboxEmpty start=/- \[ \]/ end=/\]/', 'conceal cchar='.s:v.conceal.chars['checkbox_empty'])

hi link MdCheckboxEmpty gitcommitUnmergedFile
hi link MdCheckboxPending gitcommitBranch
hi link MdCheckboxComplete gitcommitSelectedFile
" }}}1

" YAML: {{{1
" embedded YAML highlighting
if s:v.include.yaml
  try
    unlet! b:current_syntax
    syn include @YAML syntax/yaml.vim
  catch /E484/
  endtry

  syn region MdYAMLHeader start=/\%(\%^\|\_^\s*\n\)\@<=\_^-\{3}\ze\n.\+/ end=/^\([-.]\)\1\{2}$/ keepend contains=@YAML containedin=TOP
endif
" }}}1

" }}}1

" Styling: {{{1
hi link MdOperator Comment

" override this for consistency
hi MdTitleBlock term=italic gui=italic
hi link MdTitleBlockTitle Directory
hi link MdAtxHeader Title
hi link MdAtxStart Title
hi link MdSetexHeader Title
hi link MdHeaderAttr Comment
hi link MdHeaderID Identifier

hi link MdLaTexSectionCmd texSection
hi link MdLaTeXDelimiter texDelimiter

hi link MdHTMLComment Comment
hi link MdHTMLCommentStart Comment
hi link MdHTMLCommentEnd Comment
hi link MdBlockQuote Comment
hi link MdBlockQuoteMark Comment
hi link MdAmpersandEscape Special

"" if the user sets g:Md#syntax#codeblocks#ignore to contain
"" a codeblock type, don't highlight it so that it remains Normal
"if index(g:Md#syntax#codeblocks#ignore, 'definition') == -1 | endif
" codeblock ignore/normal
"if index(g:Md#syntax#codeblocks#ignore, 'delimited') == -1 | endif
hi link MdCodeBlockInsideIndent String
hi link MdDelimitedCodeBlock String

hi link MdDelimitedCodeBlockStart Special
hi link MdDelimitedCodeBlockEnd Special
hi link MdDelimitedCodeBlockLanguage Special
hi link MdBlockQuoteinDelimitedCodeBlock MdBlockQuote
hi link MdCodePre String

hi link MdLineBlockDelimiter Delimiter

hi link MdListItemBullet Operator
hi link MdUListItemBullet Operator
hi link MdListItemBulletId Identifier

" FIXME: doesn't seem to work
hi link MdReferenceLabel Label
hi link MdReferenceURL Comment
hi link MdLinkTip Identifier
hi link MdImageIcon Operator

hi link MdReferenceDefinition Operator
hi link MdReferenceDefinitionLabel Label
hi link MdReferenceDefinitionAddress Underlined
hi link MdReferenceDefinitionTip Identifier

hi link MdAutomaticLink Underlined

hi link MdDefinitionBlockTerm Identifier
hi link MdDefinitionBlockMark Operator

hi link MdSimpleTableDelims Delimiter
hi link MdSimpleTableHeader MdStrong
hi link MdTableMultilineHeader MdStrong
hi link MdTableDelims Delimiter
hi link MdGridTableDelims Delimiter
hi link MdGridTableHeader Delimiter
hi link MdPipeTableDelims Delimiter
hi link MdPipeTableHeader Delimiter
hi link MdTableHeaderWord MdStrong

hi link MdAbbreviationHead Type
hi link MdAbbreviation Label
hi link MdAbbreviationTail Type
hi link MdAbbreviationSeparator Identifier
hi link MdAbbreviationDefinition Comment

hi link MdFootnoteID Label
hi link MdFootnoteIDHead Type
hi link MdFootnoteIDTail Type
hi link MdFootnoteDef Comment
hi link MdFootnoteDefHead Type
hi link MdFootnoteDefTail Type
hi link MdFootnoteBlock Comment
hi link MdFootnoteBlockSeparator Operator

hi link MdPCite Operator
hi link MdICite Operator
hi link MdCiteKey Label
hi link MdCiteAnchor Operator
hi link MdCiteLocator Operator

if s:v.markup
    hi MdEmphasis gui=italic cterm=italic guifg=NONE ctermfg=NONE
    hi MdStrong gui=bold cterm=bold guifg=NONE ctermfg=NONE
    hi MdStrongEmphasis gui=bold,italic cterm=bold,italic guifg=NONE ctermfg=NONE
    hi MdStrongInEmphasis gui=bold,italic cterm=bold,italic guifg=NONE ctermfg=NONE
    hi MdEmphasisInStrong gui=bold,italic cterm=bold,italic guifg=NONE ctermfg=NONE
    if !exists('s:hi_tail')
        let s:fg = '' " Vint can't figure ou these get set dynamically
        let s:bg = '' " so initialize them manually first
        for s:i in ['fg', 'bg']
            let s:tmp_val = synIDattr(synIDtrans(hlID('String')), s:i)
            let s:tmp_ui =  has('gui_running') || (has('termguicolors') && &termguicolors) ? 'gui' : 'cterm'
            if !empty(s:tmp_val) && s:tmp_val != -1
                exe 'let s:'.s:i . ' = "'.s:tmp_ui.s:i.'='.s:tmp_val.'"'
            else
                exe 'let s:'.s:i . ' = ""'
            endif
        endfor
        let s:hi_tail = ' '.s:fg.' '.s:bg
    endif
    exe 'hi MdNoFormattedInEmphasis gui=italic cterm=italic'.s:hi_tail
    exe 'hi MdNoFormattedInStrong gui=bold cterm=bold'.s:hi_tail
endif

hi link MdNoFormatted String
hi link MdNoFormattedAttrs Comment
hi link MdSubscriptMark Operator
hi link MdSuperscriptMark Operator
hi link MdStrikeoutMark Operator
hi link MdNewLine Error
hi link MdHRule Delimiter

" }}}1

" Fanced {{{1
" FIXME: For some unknown reason for atm, this doesn't work.
 for l in s:v.include.fenced
   call EnableEmbedsforCodeblocksWithLang(l)
 endfor
" TODO: remove after fixing the above
 for l in g:mdenv_fenced
   call EnableEmbedsforCodeblocksWithLang(l)
 endfor
" }}}1

let b:current_syntax = 'markdown'
let &cpo = s:cpo_save
unlet s:cpo_save

syntax sync clear
syntax sync minlines=1000
