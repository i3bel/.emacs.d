;;; early-init.el ---  -*- lexical-binding: t -*-

  ;; Author: Kyure_A <github.com/Kyure-A>
  ;; Maintainer: Kyure_A <github.com/Kyure-A>

  ;;; Commentary:

  ;;              .mmmmmmmmmmmmmm.                   .cccccccc!                .(.
  ;;  .+eeeee.   .??:   +m<   <mm.    .aaaaaaaa.    ccC!           .+sssss{    (!!
  ;; .ee:        .mm:   +mm   .mm_   .aa>   (aaA    cCC           .ss>         1!:
  ;; .ee_        .mm:   +mm   .mm_   .aa{    aaA    ccC           .sss.        !!
  ;; .ee_ <ee    .mm:   +mm   .mm_   .aa{ .(AaaA    cCC`           .<sssss    .!:
  ;; .ee_        .mm:   +mm   .mm_   .aa{ .??aaA    cCCc......         .ss:   ..
  ;; .eee....    .<<!   ?<<   .<<`   .aa{    aaA     ?CCCCCCC!    ....(s=: .!!-
  ;;  .?eeeee`                       .AA!    AAA                  .ssss<s!   .!!

  ;;; Code:  

  (require 'profiler)
  (profiler-start 'cpu)

  (setq package-enable-at-startup nil)

  (setq gc-cons-threshold (* 512 1024 1024))

  (defun display-startup-echo-area-message ())
  (setq inhibit-startup-message t)
  (setq inhibit-startup-screen t)
  (setq initial-scratch-message nil)
  (setq inhibit-startup-buffer-menu t)
  (setq message-log-max nil)
  (setq ring-bell-function 'ignore)
  (setq default-directory "~/")
  (setq command-line-default-directory "~/")

  (push '(min-height . 1) default-frame-alist)
  (push '(min-width . 1) default-frame-alist)
  (push '(height . 45) default-frame-alist)
  (push '(width . 81) default-frame-alist)
  (push '(internal-border-width . 24) default-frame-alist)
  (push '(vertical-scroll-bars . nil) default-frame-alist)
  (push '(left-fringe . 1) default-frame-alist)
  (push '(right-fringe . 1) default-frame-alist)
  (push '(fullscreen . maximized) default-frame-alist)
  (push '(tool-bar-lines . 0) default-frame-alist)
  (push '(menu-bar-lines . 0) default-frame-alist)

  (setq frame-inhibit-implied-resize t)

  (setq display-warning-minimum-level :error)

  (setq user-full-name "Kyure_A")
  (setq user-mail-address "49436968+Kyure-A@users.noreply.github.com")

  (defconst init/saved-file-name-handler-alist file-name-handler-alist)
  (setq file-name-handler-alist nil)

  (set-language-environment "Japanese")
  (prefer-coding-system 'utf-8)
  (set-default 'buffer-file-coding-system 'utf-8)

  (setq custom-file (locate-user-emacs-file "custom.el"))

  (setq debug-on-error t)

  (custom-set-variables '(warning-suppress-types '((comp))))
  (with-eval-after-load 'comp
    (setq native-comp-async-jobs-number 8)
    (setq native-comp-speed 3)
    (setq native-comp-always-compile t))

