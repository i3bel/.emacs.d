;;; publish-site.el --- Build website for GitHub Pages -*- lexical-binding: t; -*-

(require 'org)
(require 'ox-publish)

(setq org-html-doctype "html5")
(setq org-html-html5-fancy t)
;; htmlize is not installed in CI; disable syntax highlighting instead of warning.
(setq org-html-htmlize-output-type nil)

(defconst kyre/site-theme
  (concat
   "<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\" />\n"
   "<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin />\n"
   "<link href=\"https://fonts.googleapis.com/css2?"
   "family=Manrope:wght@400;600;800&family=JetBrains+Mono:wght@400;600&display=swap\""
   " rel=\"stylesheet\" />\n"
   "<style>\n"
   ":root {\n"
   "  --bg-a: #272822;\n"
   "  --bg-b: #1f201b;\n"
   "  --card: rgba(39, 40, 34, 0.92);\n"
   "  --text: #f8f8f2;\n"
   "  --muted: #b7b7a8;\n"
   "  --line: rgba(249, 38, 114, 0.28);\n"
   "  --accent: #66d9ef;\n"
   "  --accent-2: #a6e22e;\n"
   "  --warn: #fd971f;\n"
   "}\n"
   "* { box-sizing: border-box; }\n"
   "body {\n"
   "  margin: 0;\n"
   "  color: var(--text);\n"
   "  font-family: 'Manrope', 'Avenir Next', 'Segoe UI', sans-serif;\n"
   "  line-height: 1.75;\n"
   "  background:\n"
   "    radial-gradient(circle at 12% 14%, rgba(249, 38, 114, 0.18), transparent 43%),\n"
   "    radial-gradient(circle at 88% 0%, rgba(166, 226, 46, 0.12), transparent 40%),\n"
   "    linear-gradient(150deg, var(--bg-a), var(--bg-b));\n"
   "  min-height: 100vh;\n"
   "}\n"
   "#content {\n"
   "  width: min(980px, 92vw);\n"
   "  margin: 44px auto 22px;\n"
   "  padding: clamp(22px, 3.4vw, 38px);\n"
   "  border: 1px solid var(--line);\n"
   "  border-radius: 24px;\n"
   "  background: var(--card);\n"
   "  backdrop-filter: blur(8px);\n"
   "  box-shadow: 0 24px 60px rgba(8, 12, 20, 0.3);\n"
   "}\n"
   "h1, h2, h3, h4 {\n"
   "  letter-spacing: -0.01em;\n"
   "  line-height: 1.25;\n"
   "}\n"
   "h1.title {\n"
   "  margin-top: 0;\n"
   "  margin-bottom: 1.2rem;\n"
   "  font-size: clamp(1.8rem, 4vw, 2.7rem);\n"
   "}\n"
   "h2 { margin-top: 2.2rem; font-size: clamp(1.3rem, 2.5vw, 1.8rem); }\n"
   "h3 { margin-top: 1.6rem; font-size: clamp(1.1rem, 2vw, 1.3rem); }\n"
   "a {\n"
   "  color: var(--accent);\n"
   "  text-decoration-thickness: 2px;\n"
   "  text-underline-offset: 2px;\n"
   "}\n"
   "a:hover { color: var(--accent-2); }\n"
   "p, li { max-width: 75ch; }\n"
   "ul.org-ul { padding-left: 1.3rem; }\n"
   "#table-of-contents {\n"
   "  margin: 1.2rem 0 1.5rem;\n"
   "  padding: 1rem 1.1rem;\n"
   "  border: 1px solid var(--line);\n"
   "  border-radius: 14px;\n"
   "  background: rgba(166, 226, 46, 0.06);\n"
   "}\n"
   "pre, code, .src {\n"
   "  font-family: 'JetBrains Mono', 'Cascadia Code', 'SFMono-Regular', monospace;\n"
   "}\n"
   "pre {\n"
   "  margin: 1rem 0;\n"
   "  padding: 0.9rem 1rem;\n"
   "  border: 1px solid var(--line);\n"
   "  border-radius: 12px;\n"
   "  background: rgba(15, 16, 13, 0.86);\n"
   "  overflow-x: auto;\n"
   "}\n"
   ".todo, .priority { color: var(--warn); }\n"
   "img {\n"
   "  border-radius: 12px;\n"
   "  border: 1px solid var(--line);\n"
   "  max-width: 100%;\n"
   "}\n"
   "#postamble {\n"
   "  width: min(980px, 92vw);\n"
   "  margin: 0 auto 48px;\n"
   "  color: var(--muted);\n"
   "  font-size: 0.92rem;\n"
   "}\n"
   "</style>\n"))

(setq org-publish-project-alist
      `(("site"
         :base-directory "./"
         :base-extension "org"
         :recursive t
         :exclude "README\\.org"
         :publishing-directory "./public"
         :publishing-function org-html-publish-to-html
         :with-author t
         :with-sub-superscript nil
         :with-toc t
         :section-numbers nil
         :html-validation-link nil
         :time-stamp-file nil
         :auto-sitemap t
         :sitemap-title ".emacs.d configuration"
         :sitemap-filename "index.org"
         :html-head-include-default-style nil
         :html-head-include-scripts nil
         :html-head ,kyre/site-theme)))

(org-publish-all t)
