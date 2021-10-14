### Delete all comments
	
	:g/^\s*#/d

### Invoke netrw (kinda file explorer)

	:Explore - opens netrw in the current window
	:Sexplore - opens netrw in a horizontal split
	:Vexplore - opens netrw in a vertical split

		You can also snigger by typing :Sex to invoke a horizontal split.

### Copy paste

> Visit [this](https://vim.fandom.com/wiki/Copy,_cut_and_paste) dor more info.

1. Position the cursor where you want to begin cutting.
2. Press v to select characters, or uppercase V to select whole lines, or Ctrl-v to select rectangular blocks (use Ctrl-q if Ctrl-v is mapped to paste).
3. Move the cursor to the end of what you want to cut.
4. Press d to cut (or y to copy).
5. Move to where you would like to paste.
6. Press P to paste before the cursor, or p to paste after.

