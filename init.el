(defvar my/proxy-server "127.0.0.1:6789" "本地代理服务器地址和端口")

(defun my/proxy-on ()
  "开启 Emacs 代理"
  (interactive)
  (setq url-proxy-services
        `(("http" . ,my/proxy-server)
          ("https" . ,my/proxy-server)))
  ;; 同时也为 Emacs 启动的外部子进程（如 git）设置环境变量
  (setenv "http_proxy" (concat "http://" my/proxy-server))
  (setenv "https_proxy" (concat "http://" my/proxy-server))
  (message "Emacs 代理已开启: %s" my/proxy-server))

(defun my/proxy-off ()
  "关闭 Emacs 代理"
  (interactive)
  (setq url-proxy-services nil)
  (setenv "http_proxy" nil)
  (setenv "https_proxy" nil)
  (message "Emacs 代理已关闭"))

;; 默认随 Emacs 启动自动开启代理
;;(my/proxy-on)


;; ==========================================
;; 2. ELPA 镜像配置 (清华大学 TUNA 镜像)
;; ==========================================

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

;; 设置你的本地 Org 笔记路径（这里默认定位到 Windows 的用户文档目录下的 org 文件夹）
;; 如果你存放在其他地方（例如 D 盘），可以把 "~/Documents/org" 改为 "D:/org" 这样的路径
(defconst ORG-PATH (expand-file-name "~/Documents/org"))

(defconst FALLBACK-FONTS '("Jigmo" "Jigmo2" "Jigmo3"))
(defconst FONT-SIZE 12)
(defconst DEFAULT-FONT (format "Consolas %d" FONT-SIZE))
(defconst ORG-FONT (format "PragmataPro %d" FONT-SIZE))
(defconst ZH-DEFAULT-FONT "LXGW WenKai Screen")
(defconst EMOJI-FONTS '("Segoe UI Emoji"))
(defconst SYMBOL-FONT '("PragmataPro"
                        "Segoe UI Symbol"
                        "Symbola"
                        "Symbol"))

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
    (rose-pine :host github :repo "LuciusChen/rose-pine")
    
    ;; 笔记项目管理与快速跳转
    projectile consult-dir scratch ace-pinyin
    
    ;; 核心笔记包 (Denote & Org-mode)
    denote denote-org denote-journal denote-markdown org-modern org-remark org-cliplink
    
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

(require 'init-org)        ; 你的核心 Org-mode 配置

(require 'init-local)

(provide 'init)
;; Local Variables:
;; coding: utf-8
;; no-byte-compile: t
;; End:
;;; init.el ends here