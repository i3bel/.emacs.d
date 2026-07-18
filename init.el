;; ==========================================
;; 0. ELPA 镜像配置 (清华大学 TUNA 镜像)
;; ==========================================
;; 只隐藏启动时的特定消息
(setq inhibit-startup-message t
      inhibit-startup-screen t
      inhibit-startup-echo-area-message t
      initial-scratch-message nil)

;; 启动完成后清空底部
(add-hook 'emacs-startup-hook
          (lambda ()
            (run-with-idle-timer 0.1 nil
                                  (lambda ()
                                    (message "")))))

;; 使用清华大学 TUNA 镜像
(setq package-archives
      '(("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
        ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
        ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setopt use-package-always-ensure t)

(defun my/use-package-ensure-smart (name args state &optional no-refresh)
  "如果 NAME 已经是内置可用的功能/函数,就跳过安装,否则走正常的 package-install。"
  (unless (or (fboundp name) (featurep name) (locate-library (symbol-name name)))
    (use-package-ensure-elpa name args state no-refresh)))

(setopt use-package-ensure-function #'my/use-package-ensure-smart)

;; 忽略原生编译警告
(setq warning-minimum-level :emergency)



;; ==========================================
;; 1. Windows 专属路径与字体设置
;; ==========================================

;; 限制最大窗口尺寸，避免超出屏幕
(setq default-frame-alist
      '((width . 70)          ;; 字符宽度
        (height . 34)          ;; 字符高度
        (left . 50)            ;; 左边距像素
        (top . 10)             ;; 上边距像素
        (fullscreen . nil)))   ;; 不要全屏


;; 设置你的本地 Org 笔记路径（这里默认定位到 Windows 的用户文档目录下的 org 文件夹）
;; 如果你存放在其他地方（例如 D 盘），可以把 "~/Documents/org" 改为 "D:/org" 这样的路径
(defconst ORG-PATH (expand-file-name "~/Documents/org"))

;; === 字号设置 ===
;; Emacs height = 点数 × 10
(defconst FONT-SIZE 180)      ;; 18pt
(defconst FONT-SIZE-ZH 200)   ;; 20pt，比例 1.11

;; === 字体族 ===
(defconst DEFAULT-FONT "Consolas")
(defconst ORG-FONT "PragmataPro")
(defconst ZH-DEFAULT-FONT "LXGW WenKai Screen")
(defconst EMOJI-FONTS '("Segoe UI Emoji"))
(defconst SYMBOL-FONT '("PragmataPro"
                        "Segoe UI Symbol"
                        "Symbola"
                        "Symbol"))
(defconst FALLBACK-FONTS '("Jigmo" "Jigmo2" "Jigmo3"))

;; === 设置函数 ===
(defun my/setup-fonts (&optional frame)
  (let ((frame (or frame (selected-frame))))
    (set-face-attribute 'default frame
                        :family DEFAULT-FONT
                        :height FONT-SIZE)
    
    (dolist (charset '(han cjk-misc bopomofo kana hangul))
      (set-fontset-font t charset
                        (font-spec :family ZH-DEFAULT-FONT
                                   :size FONT-SIZE-ZH)
                        frame))
    
    (set-fontset-font t 'emoji
                      (font-spec :family "Segoe UI Emoji" :size FONT-SIZE)
                      frame)
    
    (set-fontset-font t 'symbol
                      (font-spec :family "Consolas" :size FONT-SIZE)
                      frame 'prepend)))

;; 初始化
(my/setup-fonts)

;; 新 frame 生效
(add-hook 'after-make-frame-functions #'my/setup-fonts)
;; ==========================================
;; 2. 安装并初始化 straight.el 包管理器
;; ==========================================
(setq straight-repository-branch "develop")
(setq straight-check-for-modifications '(check-on-save find-when-checking))
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; ==========================================
;; 3. 精简后的插件安装列表 (USE-PACKAGE-LIST)
;; ==========================================
;; ==========================================
;; 3. 终极瘦身版插件安装列表 (已将 panel, org-defuddle, chirp 加回)
;; ==========================================
(defvar USE-PACKAGE-LIST
  '(;; 基础网络与配置工具
    plz setup diminish
    popper 
    meow
    diff-hl
    goggles
    rainbow-delimiters
    clutch
    ox-hugo
    ;; 漂亮的界面与图标
    nerd-icons doom-modeline diredfl nerd-icons-completion
    rainbow-mode
    indent-bars
    breadcrumb 
    nerd-icons-corfu
    (rose-pine :host github :repo "LuciusChen/rose-pine")
    
    ;; 笔记项目管理与快速跳转
    projectile consult-dir scratch ace-pinyin
    
    ;; 核心笔记包 (Denote & Org-mode)
    denote
    denote-org
    denote-journal
    denote-markdown
    org-modern
    org-remark
    org-cliplink
    
    ;; 你特意保留的个性化工具
    (org-defuddle :host github :repo "LuciusChen/org-defuddle")
    (chirp :host github :repo "LuciusChen/chirp")
    (panel :host github :repo "LuciusChen/panel")
    (ob-clutch :host github :repo "LuciusChen/ob-clutch")
    
    ;; 文档排版美化
    mmm-mode language-detection))

(dolist (e USE-PACKAGE-LIST) (straight-use-package e))
(setq vc-follow-symlinks t)

;; ==========================================
;; 4. 加载模块目录
;; ==========================================
(dolist (dir '("lisp" "lib" "site-lisp"))
  (add-to-list 'load-path (expand-file-name dir user-emacs-directory)))

;; ==========================================
;; 5. 模块文件按需载入 (已剔除你不需要的模块)
;; ==========================================
(require 'init-setup)
(require 'init-auth)
(require 'init-ui)

(require 'init-editing)
(require 'init-vc)
(require 'init-prog)
(require 'init-nav)
(require 'init-transient)
(require 'init-minibuffer)

(require 'init-org)        ; 你的核心 Org-mode 配置

(require 'init-local)

(require 'init-completion)
(require 'init-local)

(require 'roll)

(provide 'init)
;; Local Variables:
;; coding: utf-8
;; no-byte-compile: t
;; End:
;;; init.el ends here