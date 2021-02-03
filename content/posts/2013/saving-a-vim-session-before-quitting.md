---
title: Saving a vim session before quitting
date: 2013-02-21T21:00:00+01:00
tags:
- vim
category:
description:
---


When you working on a project, you often have a lot of files open in your [vim](http://vim.org). I use split and tab a lot to open all I need to work on a feature.

I leave my [vim](http://vim.org) open as much as possible to avoid the pain of reopening them all everyday. Obviously, this isn't enough as sometime you don't have other choice than closing it (restarting your computer for example).

I started using the mksession command:

`!mksession` (or without the ! if you don't want to override a previous session file).

This command let you save your vim session and then reopen it by launching vim like this:

``vim -S /path/session/file``

I was fed up of doing this -S stuff every time, so I changed for something a little bit more automatic.
I mapped to `SQ` a command that create a vim session in the current directory so I just use SQ for quitting and I know that there will be a session file generated thanks to this command.

After that, I just added an «autoloading» configuration to load a session file in the current directory if any exist.

This is the stuff I added in my vimrc:

``` bash

    """ SESSION
    function! RestoreSession()
      if argc() == 0 "vim called without arguments
        let FILESESSION=expand("./session.vim")
        if filereadable(FILESESSION)
          execute 'source ./session.vim'
        endif
      end
    endfunction

    nmap SQ <ESC>:mksession! ./session.vim<CR>:wqa<CR>
    autocmd VimEnter * call RestoreSession()
```

Now, I just need to open vim from the root directory of the project and think about leaving using SQ to generate the session file. The next time, I just need to go to root directory of the project and open vim without argument and the session will be loaded.

/!\ If you open a file directly (by using `vim ./path/to/file`), the session won't be open.

It makes sens for me to do this in the project root directory as I already have my ctags file there, as explain in [this blog post](/2013/02/20/using-vim-and-ctags-for-php-development.html).

As long as I open vim from the root directory of each project, my ctags and my session will be loaded :)

Isn't that beautiful ? :)
