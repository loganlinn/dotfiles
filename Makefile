MAKEFILE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
KERNEL_NAME := $(shell sh -c 'uname -s 2>/dev/null')
APT_COMMAND  ?= $(shell command -v apt 2>/dev/null)
BREW_COMMAND ?= $(shell command -v brew 2>/dev/null)

SHELL := bash
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:

default: help

.PHONY: install
install:

.PHONY: help
help: info

.PHONY: info
info: print-SHELL print-MAKEFILE_DIR print-KERNEL_NAME print-APT_COMMAND print-BREW_COMMAND

print-% : ; @echo $*=$($*)

