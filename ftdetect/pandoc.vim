autocmd BufNewFile,BufRead,BufFilePost *.pandoc,*.pdk,*.pd,*.pdc set filetype=pandoc

if get(g:, 'pandoc_nvim_use_markdown', 1) == 1
    autocmd BufNewFile,BufRead,BufFilePost *.markdown,*.mdown,*.mkd,*.mkdn,*.mdwn,*.md
                \ let b:did_ftplugin=1 | setlocal filetype=pandoc
endif
