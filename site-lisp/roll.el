;;; roll.el --- Dice expression evaluator for Emacs -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Your Name

;; Author: Your Name <your.email@example.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1"))
;; Keywords: games, dice, tools
;; URL: https://github.com/yourname/roll

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;;; Commentary:

;; roll - Emacs Dice Expression Evaluator
;;
;; 在 Emacs 中实现骰子运算，支持：
;; - 基础骰子: XdY
;; - 骰子运算: XdYdZ (drop), XdYkZ (keep), XdYrZ (reroll), XdYrkZ (reroll and keep)
;; - 四则运算: +, -, *, /, ()
;; - Math 函数: Math.floor, Math.ceil, Math.round 等
;; - 批量计算
;;
;; 使用示例:
;;   (roll "d6 + 2")          ; 丢一颗六面骰 +2
;;   (roll "4d6d1")           ; 丢4颗六面骰，去掉最低点
;;   (roll "2d6 + d4")        ; 混合骰子
;;   (roll "Math.ceil(3d6/2)") ; 使用 Math 函数
;;
;; 交互式命令:
;;   M-x roll-interactive     ; 输入表达式并显示结果
;;   M-x roll-region          ; 对选中区域进行骰子运算

;;; Code:

(require 'cl-lib)
(require 'subr-x)
(require 'calc)

;; Customization
(defgroup roll nil
  "Dice expression evaluator."
  :group 'games
  :prefix "roll-")

(defcustom roll-max-times 10
  "Maximum number of times to roll in a single command."
  :type 'integer
  :group 'roll)

(defcustom roll-max-expression-length 50
  "Maximum length of expression string."
  :type 'integer
  :group 'roll)

(defcustom roll-max-dice-count 20
  "Maximum number of dice in a single roll."
  :type 'integer
  :group 'roll)

(defcustom roll-max-dice-sides 100
  "Maximum sides of a die."
  :type 'integer
  :group 'roll)

(defcustom roll-max-dice-expr 10
  "Maximum number of dice expressions in a single expression."
  :type 'integer
  :group 'roll)

;;; Regex patterns
(defconst roll-dice-regex
  (rx (group (opt (one-or-more digit)) "d" (one-or-more digit)
             (opt (or "rk" "r" "k" "d") (one-or-more digit))
             (opt (or "rk" "r" "k" "d") (one-or-more digit))))
  "Regex for matching dice expressions like 4d6d1, 2d20k1, etc.")

(defconst roll-basic-dice-regex
  (rx (group (opt (one-or-more digit)) "d" (one-or-more digit)))
  "Regex for matching basic dice expressions like XdY.")

;;; Core dice rolling functions

(defun roll--die (sides)
  "Roll a single die with SIDES."
  (if (<= sides 0)
      (error "Die must have positive sides")
    (1+ (random sides))))

(defun roll--dice (count sides)
  "Roll COUNT dice with SIDES each, return list of results."
  (unless (and (integerp count) (integerp sides))
    (error "Invalid die parameters"))
  (when (or (< count 1) (< sides 1))
    (error "Invalid die parameters"))
  (when (or (> count roll-max-dice-count)
            (> sides roll-max-dice-sides))
    (error "Die count or sides exceeds limits"))
  (cl-loop for i from 1 to count
           collect (roll--die sides)))

;;; Dice expression parsers

(defun roll--parse-dice-expr (expr)
  "Parse a dice expression like '4d6d1' or '2d20k1'.
Returns (count sides operation value)."
  (let ((case-fold-search nil))
    (cond
     ;; XdYdZ (drop lowest Z)
     ((string-match (rx (group (opt (one-or-more digit))) "d"
                        (group (one-or-more digit))
                        "d" (group (one-or-more digit)))
                    expr)
      (list (let ((count-str (match-string 1 expr)))
              (if (or (null count-str) (string-empty-p count-str))
                  1
                (string-to-number count-str)))
            (string-to-number (match-string 2 expr))
            'drop
            (string-to-number (match-string 3 expr))))
     
     ;; XdYkZ (keep highest Z)
     ((string-match (rx (group (opt (one-or-more digit))) "d"
                        (group (one-or-more digit))
                        "k" (group (one-or-more digit)))
                    expr)
      (list (let ((count-str (match-string 1 expr)))
              (if (or (null count-str) (string-empty-p count-str))
                  1
                (string-to-number count-str)))
            (string-to-number (match-string 2 expr))
            'keep
            (string-to-number (match-string 3 expr))))
     
     ;; XdYrkZ (reroll below Z once)
     ((string-match (rx (group (opt (one-or-more digit))) "d"
                        (group (one-or-more digit))
                        "rk" (group (one-or-more digit)))
                    expr)
      (list (let ((count-str (match-string 1 expr)))
              (if (or (null count-str) (string-empty-p count-str))
                  1
                (string-to-number count-str)))
            (string-to-number (match-string 2 expr))
            'reroll-keep
            (string-to-number (match-string 3 expr))))
     
     ;; XdYrZ (reroll below Z)
     ((string-match (rx (group (opt (one-or-more digit))) "d"
                        (group (one-or-more digit))
                        "r" (group (one-or-more digit)))
                    expr)
      (list (let ((count-str (match-string 1 expr)))
              (if (or (null count-str) (string-empty-p count-str))
                  1
                (string-to-number count-str)))
            (string-to-number (match-string 2 expr))
            'reroll
            (string-to-number (match-string 3 expr))))
     
     ;; Basic XdY
     ((string-match (rx (group (opt (one-or-more digit))) "d"
                        (group (one-or-more digit)))
                    expr)
      (list (let ((count-str (match-string 1 expr)))
              (if (or (null count-str) (string-empty-p count-str))
                  1
                (string-to-number count-str)))
            (string-to-number (match-string 2 expr))
            nil nil))
     
     (t (error "Invalid dice expression: %s" expr)))))

(defun roll--evaluate-dice-expr (expr)
  "Evaluate a dice expression and return (result . details)."
  (pcase-let ((`(,count ,sides ,op ,val) (roll--parse-dice-expr expr)))
    (let* ((results (roll--dice count sides))
           (sorted (sort results #'>))
           (result results)
           details)
      
      (cond
       ((null op)                          ; Basic roll
        (setq details (format "%d个d%d: %s" count sides
                              (string-join (mapcar #'number-to-string results) ", "))))
       
       ((eq op 'drop)                      ; Drop lowest Z
        (when (> val count)
          (error "Cannot drop %d dice from %d dice" val count))
        (let ((kept (cl-subseq sorted 0 (- count val))))
          (setq result kept)
          (setq details (format "%d个d%d, 去掉最低%d个: %s → %s"
                                count sides val
                                (string-join (mapcar #'number-to-string results) ", ")
                                (string-join (mapcar #'number-to-string kept) ", ")))))
       
       ((eq op 'keep)                      ; Keep highest Z
        (when (> val count)
          (error "Cannot keep %d dice from %d dice" val count))
        (let ((kept (cl-subseq sorted 0 val)))
          (setq result kept)
          (setq details (format "%d个d%d, 保留最高%d个: %s → %s"
                                count sides val
                                (string-join (mapcar #'number-to-string results) ", ")
                                (string-join (mapcar #'number-to-string kept) ", ")))))
       
       ((eq op 'reroll)                    ; Reroll below Z
        (let ((rerolled (cl-loop for r in results
                                 collect (if (< r val)
                                             (roll--die sides)
                                           r))))
          (setq result rerolled)
          (setq details (format "%d个d%d, 重骰低于%d: %s → %s"
                                count sides val
                                (string-join (mapcar #'number-to-string results) ", ")
                                (string-join (mapcar #'number-to-string rerolled) ", ")))))
       
       ((eq op 'reroll-keep)               ; Reroll below Z once, keep result
        (let ((rerolled (cl-loop for r in results
                                 collect (if (< r val)
                                             (roll--die sides)
                                           r))))
          (setq result rerolled)
          (setq details (format "%d个d%d, 重骰低于%d一次: %s → %s"
                                count sides val
                                (string-join (mapcar #'number-to-string results) ", ")
                                (string-join (mapcar #'number-to-string rerolled) ", "))))))
      
      (cons (if (listp result)
                (cl-reduce #'+ result)
              result)
            details))))

;;; Expression evaluator

(defun roll--collect-dice-exprs (expr)
  "Collect all dice expressions from EXPR.
Returns list of (match-string start-position)."
  (let ((matches nil)
        (pos 0))
    (while (string-match roll-dice-regex expr pos)
      (push (list (match-string 0 expr) (match-beginning 0) (match-end 0))
            matches)
      (setq pos (match-end 0)))
    (nreverse matches)))

(defun roll--replace-dice-exprs (expr)
  "Replace all dice expressions in EXPR with their results.
Return (evaluated-expr results-details)."
  (let* ((dice-matches (roll--collect-dice-exprs expr))
         (result-expr expr)
         (details-list nil)
         (dice-count (length dice-matches)))
    
    (when (> dice-count roll-max-dice-expr)
      (error "Too many dice expressions (max: %d)" roll-max-dice-expr))
    
    ;; 从后往前替换，避免位置偏移
    (dolist (match (reverse dice-matches))
      (pcase-let ((`(,dice ,start ,end) match))
        (pcase-let ((`(,val . ,detail) (roll--evaluate-dice-expr dice)))
          (let ((result-str (number-to-string val)))
            ;; 从后往前替换，直接用 start 和 end
            (setq result-expr (concat (substring result-expr 0 start)
                                      result-str
                                      (substring result-expr end)))
            (push detail details-list)))))
    
    (list result-expr (nreverse details-list))))

(defun roll--validate-expression (expr)
  "Validate that EXPR contains only allowed characters and operations."
  (when (> (length expr) roll-max-expression-length)
    (error "Expression too long (max: %d)" roll-max-expression-length))
  
  ;; 移除 Math.xxx() 调用，但保留 d, k, r 等骰子字符
  (let* ((cleaned (replace-regexp-in-string "Math\\.[a-zA-Z]+\\s-*(" "(" expr))
         (cleaned (replace-regexp-in-string "[()]" "" cleaned))
         ;; 允许: 数字, +, *, /, ., ,, 空格, -, d, k, r (骰子语法)
         (allowed "^[0-9+*/.,[:space:]-dkr]+$"))
    (unless (string-match-p allowed cleaned)
      (error "Expression contains disallowed characters: %s" expr)))
  t)

(defun roll--safe-eval (expr)
  "Safely evaluate EXPR using Emacs calculator."
  ;; ✅ 不需要再次验证，已经在 roll 中验证过了
  ;; (roll--validate-expression expr)  ; 删除这行
  
  ;; 修复: 使用 ceil 而不是 ceiling，因为 calc 认识 ceil
  (let* ((cleaned (replace-regexp-in-string "Math\\.ceil" "ceil" expr))
         (cleaned (replace-regexp-in-string "Math\\.floor" "floor" cleaned))
         (cleaned (replace-regexp-in-string "Math\\.round" "round" cleaned))
         (cleaned (replace-regexp-in-string "Math\\.abs" "abs" cleaned))
         (cleaned (replace-regexp-in-string "Math\\.max" "max" cleaned))
         (cleaned (replace-regexp-in-string "Math\\.min" "min" cleaned)))
    (condition-case nil
        (let ((result (calc-eval cleaned)))
          (if (stringp result)
              (string-to-number result)
            result))
      (error (error "Failed to evaluate expression: %s" expr)))))

;;; Main public functions

;;;###autoload
;;;###autoload
(defun roll (expr &optional times)
  "Roll dice according to EXPR.
If TIMES is specified, roll multiple times.
Returns a string with results and details."
  (interactive)
  (unless times (setq times 1))
  (when (> times roll-max-times)
    (error "Too many rolls (max: %d)" roll-max-times))
  
  ;; ✅ 先验证原始表达式
  (roll--validate-expression expr)
  
  (let ((results nil)
        (all-details nil)
        (current-expr expr))
    
    (dotimes (i times)
      (pcase-let ((`(,evaled-expr ,details) (roll--replace-dice-exprs current-expr)))
        (let ((result (roll--safe-eval evaled-expr)))
          (push (format "结果 #%d: %s = %s"
                        (1+ i)
                        (string-join details ", ")
                        (if (integerp result)
                            (number-to-string (round result))
                          (format "%.2f" result)))
                results))))
    
    (string-join (nreverse results) "\n")))

;;;###autoload
(defun roll-interactive (expr &optional times)
  "Interactive dice rolling.
Prompt for EXPR and optional TIMES, display results."
  (interactive
   (let ((expr (read-string "掷骰表达式: " nil nil "d6 + 2")))
     (list expr
           (if current-prefix-arg
               (string-to-number (read-string "次数: " nil nil "1"))
             1))))
  (let ((result (roll expr times)))
    (message (concat "\n" result))
    result))

;;;###autoload
;;;###autoload
(defun roll-region (start end &optional times)
  "Roll dice for the selected region.
Replace dice expressions in region with their final calculated results.
Preserves non-dice text like labels and punctuation."
  (interactive "r")
  (unless times (setq times 1))
  (let* ((text (buffer-substring-no-properties start end))
         (lines (split-string text "\n" t))
         (processed-lines nil)
         (updated-count 0))
    
    (dolist (line lines)
      (if (string-match roll-dice-regex line)
          (progn
            (let* ((start-pos (match-beginning 0))
                   (before (substring line 0 start-pos))
                   ;; 从骰子位置开始，提取所有数学相关部分
                   (rest (substring line start-pos))
                   ;; 匹配数学表达式（直到遇到非数学字符）
                   ;; 修复：把 - 放在最后，并且用 \\- 转义
                   (math-parts (when (string-match 
                                      "^\\([0-9]*d[0-9]+[dkr0-9]*\\(?:\\s-*[+*/\\-]\\s-*\\(?:[0-9]*d[0-9]+[dkr0-9]*\\|[0-9]+\\(?:\\.[0-9]+\\)?\\)\\)*\\)" 
                                      rest)
                                 (match-string 1 rest)))
                   (full-expr (or math-parts (match-string 0 line)))
                   (after (substring line (+ start-pos (length full-expr))))
                   ;; 计算完整表达式
                   (result (roll full-expr times))
                   ;; 提取最终数字
                   (result-number (if (string-match "= \\([0-9.]+\\)$" result)
                                      (match-string 1 result)
                                    (car (split-string result "\n" t)))))
              (push (concat before result-number after) processed-lines)
              (setq updated-count (1+ updated-count))))
        (push line processed-lines)))
    
    (let ((final-result (string-join (reverse processed-lines) "\n")))
      (delete-region start end)
      (insert final-result)
      (kill-new final-result)
      (when (> updated-count 0)
        (message "Updated %d line%s containing dice expressions!" 
                 updated-count (if (> updated-count 1) "s" "")))
      final-result)))
;;; Utility functions

;;;###autoload
(defun roll-pick (choices)
  "Randomly pick one item from CHOICES (string with space-separated items)."
  (interactive "s选项 (用空格分隔): ")
  (let* ((items (split-string choices "\\s-+" t))
         (count (length items)))
    (when (< count 2)
      (error "需要至少2个选项"))
    (let ((pick (nth (random count) items)))
      (message "从 %d 个选项中随机选中: %s" count pick)
      pick)))

;;;###autoload
(defun roll-shuffle (items)
  "Shuffle ITEMS (string with space-separated items)."
  (interactive "s项目 (用空格分隔): ")
  (let* ((item-list (split-string items "\\s-+" t))
         (count (length item-list)))
    (when (< count 2)
      (error "需要至少2个项目"))
    (let ((shuffled (cl-loop with seq = (copy-sequence item-list)
                             for i from (1- count) downto 1
                             do (cl-rotatef (elt seq i)
                                            (elt seq (random (1+ i))))
                             finally return seq)))
      (message "原始: %s\n洗牌后: %s"
               (string-join item-list " ")
               (string-join shuffled " "))
      shuffled)))

;;;###autoload
(defun roll-luck (&optional pool)
  "Test your luck for today.
POOL can be 'default' (7 levels), 'twelve' (12 levels), or 'asakusa'."
  (interactive)
  (unless pool (setq pool 'default))
  (let* ((levels
          (pcase pool
            ('default '("大吉" "吉" "中吉" "小吉" "末吉" "凶" "大凶"))
            ('twelve '("大吉" "吉" "中吉" "小吉" "半吉" "末吉"
                       "末小吉" "凶" "小凶" "半凶" "末凶" "大凶"))
            ('asakusa (cl-loop for _i from 1 to 100
                               collect (cond ((<= _i 30) "大吉")
                                             ((<= _i 32) "吉")
                                             ((<= _i 38) "半吉")
                                             ((<= _i 43) "小吉")
                                             ((<= _i 48) "末吉")
                                             ((<= _i 83) "末小吉")
                                             (t "凶"))))
            (_ '("大吉" "吉" "中吉" "小吉" "末吉" "凶" "大凶"))))
         (result (if (listp (car levels))
                     (nth (random (length levels)) levels)
                   (nth (random (length levels)) levels))))
    (message "今日运势: %s (运势池: %s)" result pool)
    result))

;;; Quick access functions

;;;###autoload
(defun roll-d20 ()
  "Roll a d20."
  (interactive)
  (roll-interactive "1d20"))

;;;###autoload
(defun roll-d6 ()
  "Roll a d6."
  (interactive)
  (roll-interactive "1d6"))

;;;###autoload
(defun roll-d100 ()
  "Roll a d100."
  (interactive)
  (roll-interactive "1d100"))

;;;###autoload
(defun roll-advantage ()
  "Roll 2d20 and keep highest (advantage)."
  (interactive)
  (roll-interactive "2d20k1"))

;;;###autoload
(defun roll-disadvantage ()
  "Roll 2d20 and keep lowest (disadvantage)."
  (interactive)
  (roll-interactive "2d20d1"))

;;; History

(defvar roll-history nil
  "History of dice expressions.")
(put 'roll-history 'history-length 50)

(provide 'roll)

;;; roll.el ends here