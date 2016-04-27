```
THRASHER - A HEAVY-METAL MUSIC PLAYER FOR VIM

                                                                 ,'
                                                              .c0:
                                                            .dNX'
                                             ..           ,kMM0.
                                            'KX'       .cKMMMd.
                                           :WMMWl.   .oNMMMWc
                                         .xMMMMMM0.,kWMMMMN,
                                        .KMMMMMMMMMMMMMMM0.
                                       ;NMMMMMMMMMMMMMMMx.
                                     .oMMMMMMXMMMMMMMMWl
                                    .0MMMMWk' cWMMMMMN,
                                   ,NMMMXl.    ,NMMMK.
                                  oMMMO;.       .0Mk.
                                .OMWd.           .;
                               'XKc.
                              ck,
                             ..
```

[U+1F5F2](http://unicode-table.com/en/1F5F2/)

## What the heck?

Currently this project is in an experimental state,
but it is beginning to be actually usable (for me at least).
At the moment, Thrasher only works with iTunes on Mac OS X.
The idea is, of course, to support controlling other players as well.

If you're brave (curious) enough to give this project a try,
I'd love to hear back from you. *Let me know what you think.*

Thanks. You rock!

## Using

**Basic usage**

To bring up Thrasher's interface, type `<leader>m`.

Personally, I have mapped `<leader>` to `,`, which makes this key combination
very easy to type (on an English keyboard).  You can easily
[change the default](#configuration) though.

The interface may take a moment to appear for the first time,
because it is caching track information in the background.
Following invocations should then be instantaneous.

You can then start typing to search for tracks matching your input.

Thrasher allows searching by `artist`, `album` or `track` name, and also
lets you look for tracks with `any` of these properties matching your query.
To switch between search modes, press `ctrl-v` (`<c-v>`).

You can scroll through the list of found tracks, using `<c-j>` to go down and
`<c-k>` to move up.

Hit `<enter>` to play the selected song!

**Advanced**

Inputting

- `<c-e>` jumps to the very end of your input
- `<c-a>` places the prompt cursor at the start
- `<c-w>` deletes the word in front of the cursor
- `<c-u>` deletes your entire search input

Player control

- `<c-g>` toggles between play and pause
- `<c-f>` skips forward to the next track
- `<c-b>` lets you return to the previous track

To open the vim documentation, run `:help thrasher`.

## Installing

**[Pathogen](https://github.com/tpope/vim-pathogen)**

`git clone https://github.com/pmeinhardt/thrasher.git ~/.vim/bundle`

Remember to run `:helptags` to generate the help tags.

**[Vundle](https://github.com/VundleVim/Vundle.vim)**

`Plugin 'pmeinhardt/thrasher'`

**[Plug](https://github.com/junegunn/vim-plug)**

`Plug 'pmeinhardt/thrasher'`

## Configuration

You can change the default key mapping for invoking Thrasher,
simply by adding `let g:thrashermap = "…"` to your `.vimrc` file.

Make sure to add these options before executing `pathogen#infect()`,
calling `vundle#end()` or `plug#end()` – i.e. before loading the plugin.

## Contributing

There are many ways in which you could contribute: Through code, by creating
pull-requests, but mainly by just providing me with feedback and
your thoughts on what to improve.

## Thanks

This project boldly steals some user interface ideas from the very useful
[ctrlp](https://github.com/ctrlpvim/ctrlp.vim),
a vim plugin which has been making my vim a lot more fun.
