;;; ficus-mode.el --- Major mode for Ficus files  -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Dmitry Solomennnikov
;;
;; Author: Dmitry Solomennikov
;; Keywords: languages Ficus
;; Version: 0.1
;; URL: https://github.com/dmitrys99/ficus-mode

;; Major mode for editing Ficus language files, usually ending with `.fx`.
;; It is based on c-mode plus some features and pre-specified fontification.
;;
;; Inspired by https://github.com/jcaw/hlsl-mode

;; Code:

(require 'cc-mode)
(require 'align)

(require 'mmm-mode)

(setq mmm-global-mode 'maybe)

(defgroup ficus nil
  "Ficus language major mode"
  :group 'languages)

(defvar ficus-keyword-face 'ficus-keyword-face)
(defface ficus-keyword-face
  '((t (:inherit font-lock-keyword-face)))
  "Ficus: keyword face"
  :group 'ficus)

(defvar ficus-attribute-keyword-face 'ficus-attribute-keyword-face)
(defface ficus-attribute-keyword-face
  '((t (:inherit font-lock-preprocessor-face)))
  "Ficus: attribute keyword face"
  :group 'ficus)

(defvar ficus-keyword-literal-face 'ficus-keyword-literal-face)
(defface ficus-keyword-literal-face
  '((t (:inherit font-lock-constant-face)))
  "Ficus keyword literals face"
  :group 'ficus)

(defvar ficus-builtin-function-face 'ficus-builtin-function-face)
(defface ficus-builtin-function-face
  '((t (:inherit font-lock-builtin-face)))
  "Ficus builtin function face"
  :group 'ficus)

(defvar ficus-language-type-face 'ficus-language-type-face)
(defface ficus-language-type-face
  '((t (:inherit font-lock-type-face)))
  "Ficus language type face"
  :group 'ficus)

(defvar ficus-keyword-list
  '("as" "break" "catch" "class" "continue" "do" "else" "exception"
    "finally" "fold" "for" "from" "fun" "if" "import" 
    "interface" "match" "operator" "ref" "return" "throw"
    "try" "type" "val" "var" "when" "while" "void"))

(defvar ficus-keyword-literal-list
  '("nan" "nanf" "inf" "inff" "true" "false" "null" "_"))

(defvar ficus-attribute-keyword-list
  '("@ccode" "@data" "@inline" "@nothrow"
    "@pragma" "@parallel" "@private"
    "@pure" "@sync" "@text" "@unzip"))

(defvar ficus-builtin-function-list
  '("println" "print" "assert" "ignore" "always_use" "value" "value_or" "isnone" "issome"
    "__is_scalar__" "scalar_type" "elemsize" "__min__" "__max__" "length" "join"
    "join_embrace" "link2" "ord" "chr" "odd" "even" "repr" "parse_format" "format_" 
    "size" "__negate__" "abs" "hash" "print_string" 
    "sat_int8" "sat_uint8" "sat_int16" "sat_uint16" "__eq_variants__" "__fun_string__"
    "dot" "cross" "__negate__" "normL1" "normInf" "normL2" "normL2sqr" "all"
    "exist"))

(defvar ficus-language-type-list
  '("int8" "uint8" "int16" "uint16" "int32" "uint32" "int" "uint64" "int64"
    "half" "float" "double" "bool" "string" "char" "list" "vector" "cptr" "exn"))

(eval-and-compile
  (defun ficus-ppre (re)
    ;; FIXME: This doesn't sanitise the inputs, so a bad member could corrupt the whole expression
    (format "\\<\\(%s\\)\\>" (string-join re "\\|"))))

(defvar ficus-font-lock-keywords-1
  (append
   (list

    (cons (eval-when-compile
            (ficus-ppre ficus-keyword-list))
          ficus-keyword-face)

    (cons (eval-when-compile
            (ficus-ppre ficus-keyword-literal-list))
          ficus-keyword-literal-face)

    (cons (eval-when-compile
            (ficus-ppre ficus-builtin-function-list))
          ficus-builtin-function-face)

    (cons (eval-when-compile
            (ficus-ppre ficus-language-type-list))
          ficus-language-type-face)

    (cons (eval-when-compile
            (ficus-ppre ficus-attribute-keyword-list))
          ficus-attribute-keyword-face)))
  "Highlighting expressions for Ficus mode.")

(defvar ficus-mode-syntax-table
  (let ((ficus-mode-syntax-table (make-syntax-table)))
    (modify-syntax-entry ?/ ". 124b" ficus-mode-syntax-table)
    (modify-syntax-entry ?* ". 23" ficus-mode-syntax-table)
    (modify-syntax-entry ?\n "> b" ficus-mode-syntax-table)
    (modify-syntax-entry ?_ "w" ficus-mode-syntax-table)
    (modify-syntax-entry ?@ "w" ficus-mode-syntax-table)
    (modify-syntax-entry ?' "w" ficus-mode-syntax-table)
    ficus-mode-syntax-table)
  "Syntax table for `ficus-mode'.")

(defvar ficus-font-lock-keywords ficus-font-lock-keywords-1
  "Default highlighting expressions for Ficus mode.")

;;;###autoload
(progn
  (add-to-list 'auto-mode-alist '("\\.fx\\'" . ficus-mode)))

(defvar ficus-other-file-alist
  ;; TODO: Add common pairings, e.g. vert & corresponding frag files, perhaps
  ;;   also geom
  '()
  "Alist of extensions to find given the current file's extension.")


;;;###autoload
(define-derived-mode ficus-mode prog-mode "Ficus"
  "Major mode for editing Ficus files."
  (c-initialize-cc-mode t)
  (setq abbrev-mode t)
  (c-init-language-vars-for 'c-mode)
  (c-common-init 'c-mode)
  (cc-imenu-init cc-imenu-c++-generic-expression)
  (set (make-local-variable 'font-lock-defaults) '(ficus-font-lock-keywords))
  (set (make-local-variable 'ff-other-file-alist) 'ficus-other-file-alist)
  (set (make-local-variable 'comment-start) "// ")
  (set (make-local-variable 'comment-end) "")
  (set (make-local-variable 'comment-padding) "")
  ;; TODO: Indentation rules for annotated for loops, e.g:
  ;;     [unroll] for (...) {
  ;;     --->|
  ;;     }
  ;;   Currently it just indents flat as though no scope was declared
  (add-to-list 'align-c++-modes 'ficus-mode)
  (c-run-mode-hooks 'c-mode-common-hook)
  (run-mode-hooks 'ficus-mode-hook)
  ;; TODO: Guard `c-make-noise-macro-regexps' based on Emacs version, then lower
  ;;   dependency.
  :after-hook (progn (when (fboundp 'c-make-noise-macro-regexps)
                       ;; Depends on Emacs 26.1, guarding this allows us to
                       ;; support down to Emacs 24.4
                       (c-make-noise-macro-regexps))
                     (c-make-macro-with-semi-re)
                     (c-update-modeline)))

(mmm-add-classes
 '((ficus-cpp
    :submode c-or-c++-mode
    :front "^@ccode {[\n\r]+"
    :back "^}$")))

(mmm-add-mode-ext-class 'ficus-mode nil 'ficus-cpp) 

(provide 'ficus-mode)
;;; ficus-mode.el ends here
