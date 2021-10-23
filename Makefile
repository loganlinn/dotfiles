SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

makefile_path := $(realpath $(lastword $(MAKEFILE_LIST)))
makefile_dir  := $(dir $(MAKEFILE_PATH))

apt    := $(shell command -v apt 2>/dev/null)
brew   := $(shell command -v brew 2>/dev/null)
rustup := $(shell command -v rustup 2>/dev/null)

install: install-rcm install-rustup install-pre-commit

#######################

ifneq (,$(shell command -v pre-commit 2>/dev/null))
install-pre-commit:
	@echo "  ==> detected pre-commit"
else
install-pre-commit:
	@echo "  ==> install pre-commit"
	python3 -m pip install --upgrade pip
	python3 -m pip install --upgrade pre-commit
endif

#######################

install-zsh:
ifneq (,$(shell command -v zsh 2>/dev/null))
	@echo "  ==> detected zsh"
else
	@echo "  ==> install zsh"
ifneq (,$(apt))
	$(apt) install -y zsh
else ifneq (,$(brew))
	$(brew) install zsh
endif
endif

#######################

install-rcm:
ifneq (,$(shell command -v rcup 2>/dev/null))
	@echo "  ==> detected rcm"
else
	@echo "  ==> install rcm"
ifneq (,$(apt))
	$(apt) install -y rcm
else ifneq (,$(brew))
	$(brew) install rcm
endif
endif

#######################

install-rustup:
ifeq (,$(rustup))
	@echo "  ==> install rustup"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
else
	@echo "  ==> detected rustup"
endif

#######################

pr-% : ; @echo $*=$($*)
