SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

APT_COMMAND  ?= $(shell command -v apt 2>/dev/null)
BREW_COMMAND ?= $(shell command -v brew 2>/dev/null)
ASDF_DIR     ?= $(HOME)/.asdf

kernel_name   := $(shell uname -s)
makefile_path := $(realpath $(lastword $(MAKEFILE_LIST)))
makefile_dir  := $(dir $(MAKEFILE_PATH))

.DEFAULT_GOAL := help

.PHONY: help
help: showenv

.PHONY: install
install: asdf

.PHONY: asdf
asdf: $(HOME)/.asdf/asdf.sh
	[ -d $(ASDF_DIR) ] || git clone https://github.com/asdf-vm/asdf.git $(ASDF_DIR)

.PHONY: showenv
showenv: showenv/SHELL showenv/makefile_path showenv/kernel_name showenv/APT_COMMAND showenv/BREW_COMMAND

showenv/% : ; @echo $*=$($*)
