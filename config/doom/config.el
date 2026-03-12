;;; config.el --- Personal configuration -*- lexical-binding: t; -*-

(load! "src-get")

(map! :leader
      :desc "Clone repository" "g c" #'src-get)