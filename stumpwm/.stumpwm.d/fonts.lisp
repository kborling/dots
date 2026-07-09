;; -*- lisp -*-
;; TrueType font setup for StumpWM  —  loaded by ~/.stumpwmrc
;;
;; StumpWM still has NO built-in TrueType support in 2026; antialiased fonts
;; require the `ttf-fonts` contrib module, which depends on `clx-truetype`.
;; clx-truetype was removed from Quicklisp (upstream disappeared), so it's
;; vendored from the official fork into ~/quicklisp/local-projects/clx-truetype
;; (github.com/stumpwm/clx-truetype).
;;
;; This lives in its own file, loaded with (ignore-errors (load ...)), because
;; clx-truetype's package is referenced at READ time — if the library is ever
;; missing, only THIS file fails; the rest of the config still loads.
(in-package :stumpwm)

(ql:quickload :clx-truetype :silent t)
(load-module "ttf-fonts")

;; Scan ONLY the dirs we actually use. Do NOT append the default dirs — the
;; defaults pull in /usr/share/fonts recursively (~400 files incl. all of Noto),
;; and cache-fonts parses every one synchronously, which froze the WM. JetBrains
;; Mono lives in /usr/share/fonts/TTF/; user fonts in ~/.local/share/fonts/.
(setq clx-truetype::*font-dirs*
      (list (namestring (merge-pathnames ".local/share/fonts/"
                                         (user-homedir-pathname)))
            "/usr/share/fonts/TTF/"))

;; Building the metrics cache scans every system font (slow), so only do it
;; once. Delete ~/.fonts/font-cache.sexp (or run `(xft:cache-fonts)`) after
;; installing new fonts.
(let ((cache (merge-pathnames ".fonts/font-cache.sexp" (user-homedir-pathname))))
  (unless (probe-file cache)
    (clx-truetype:cache-fonts)))

(set-font (make-instance 'xft:font
                         :family "Comic Code"
                         :subfamily "Regular"
                         :size 11))
