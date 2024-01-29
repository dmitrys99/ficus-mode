# ficus-mode
Major mode for Ficus files.

## Features
This major mode highlights Ficus language keywords, attirbute keywords, types and builtin functions.

## Installation
Copy `ficus-mode.el` to Emacs init folder (usually `~/.emacs.d/`) then add lines to `init.el`:

```
(autoload 'ficus-mode "~/.emacs.d/ficus-mode.el" "Ficus major mode." t)
(add-to-list 'auto-mode-alist '("\\.fx\\'" . ficus-mode))
```

Ficus can use C-code directly using `@ccode {...}` attribute keyword. To highlight nested C-code MMM mode is used,
so one should install `mmm-mode` first (available in Melpa).

