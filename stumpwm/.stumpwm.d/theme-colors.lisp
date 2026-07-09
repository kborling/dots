;; -*- lisp -*-
;; StumpWM theme colors — recolor the mode-line, borders, and palette to match
;; the active desktop theme. Called by ~/.local/bin/theme via:
;;   stumpish kdb/apply-theme <fleury|uwu|acme>
(in-package :stumpwm)

;; If a prior stumpish command lookup interned KDB/APPLY-THEME into a package
;; that uses :stumpwm, defcommand's export would name-conflict. Drop it first.
(let ((s (find-symbol "KDB/APPLY-THEME" :stumpwm-user)))
  (when (and s (not (eq (symbol-package s) (find-package :stumpwm))))
    (unintern s :stumpwm-user)))

(defcommand kdb/apply-theme (name) ((:string name))
  "Recolor StumpWM (mode-line, borders, palette) for NAME: fleury|uwu|acme."
  (destructuring-bind
      (bg fg ml-bg ml-fg accent sep hl-bg hl-fg win-bg border focus unfocus pal)
      (cond
        ((string= name "uwu")
         (list "#131A1C" "#C5C8C9" "#1B2224" "#C5C8C9" "#6CBAD1" "#4A5254"
               "#2F3638" "#6CBAD1" "#232A2C" "#232A2C" "#6CBAD1" "#1B2224"
               (list "#131A1C" "#F65B5B" "#6BB05D" "#E59E67"
                     "#53A7BF" "#B185DB" "#51A39F" "#C5C8C9")))
        ((string= name "acme")
         (list "#FFFFEA" "#000000" "#E8EB98" "#000000" "#1054AF" "#988D6D"
               "#C8DFC8" "#000000" "#EFEFD8" "#B8B09A" "#1054AF" "#CCCCB7"
               (list "#000000" "#880000" "#005500" "#888838"
                     "#1054AF" "#555599" "#007777" "#444444")))
        (t ;; fleury
         (list "#020202" "#b99468" "#1a120b" "#e7aa4d" "#fcaa05" "#63523d"
               "#3a2c17" "#fcaa05" "#212121" "#212121" "#b99468" "#121212"
               (list "#020202" "#dc7575" "#2ab34f" "#b99468"
                     "#2895c7" "#c9598a" "#8ffff2" "#686868"))))
    (setf *colors* pal)
    (update-color-map (current-screen))
    (setf *mode-line-background-color* ml-bg
          *mode-line-foreground-color* ml-fg
          *mode-line-border-color* ml-bg
          *mode-line-highlight-template*
          (format nil "^(:bg \"~a\")^(:fg \"~a\") ~~A ^n" hl-bg hl-fg)
          *screen-mode-line-format*
          (list (format nil "^(:fg \"~a\") %n ^n" accent)
                (format nil "^(:fg \"~a\")│^n " sep)
                "%W" "^>" "%B"
                (format nil "  ^(:fg \"~a\")│^n " sep)
                (format nil "^(:fg \"~a\")%d ^n" ml-fg)))
    (set-bg-color bg) (set-fg-color fg)
    (set-win-bg-color win-bg) (set-border-color border)
    (set-focus-color focus) (set-unfocus-color unfocus)
    ;; recreate the mode-line so the new bg/fg actually take effect
    (ignore-errors (enable-mode-line (current-screen) (current-head) nil))
    (enable-mode-line (current-screen) (current-head) t)
    (message "^2theme: ~a" name)))
