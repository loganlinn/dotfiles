# vim:fileencoding=utf-8:foldmethod=marker

#: Shell {{{
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
#: }}}

#: Echoing {{{
V ?=
Q := $(if $(V),,@)
#: }}}

#: Colors {{{
TERM_COLORS?=$(if $(TERM),$(shell tput colors 2>/dev/null),)
ifeq (0,$(shell test 8 -le $(or $(TERM_COLORS),0); echo $$?))
COLOR_RESET   = $(shell tput sgr0)
COLOR_BOLD    = $(shell tput bold)
COLOR_BLACK   = $(shell tput setaf 0)
COLOR_RED     = $(shell tput setaf 1)
COLOR_GREEN   = $(shell tput setaf 2)
COLOR_YELLOW  = $(shell tput setaf 3)
COLOR_BLUE    = $(shell tput setaf 4)
COLOR_MAGENTA = $(shell tput setaf 5)
COLOR_CYAN    = $(shell tput setaf 6)
COLOR_WHITE   = $(shell tput setaf 7)
endif
#: }}}

#: Helpers {{{
ok    = $(COLOR_BOLD)$(COLOR_GREEN)$(or $1,OK)$(COLOR_RESET)
label = $(COLOR_BOLD)$(COLOR_MAGENTA)$1$(COLOR_RESET)
fatal = @(echo >&2 "$(COLOR_BOLD)$(COLOR_FATAL)$1$(COLOR_RESET)"; exit 1)

print-labeled = echo >&2 "$(call label,$1): $2"
find-command  = $(shell command -v $1 2>/dev/null)
show-command  = printf '%-16s%s\n' "$1" "$(call find-command,$1)" | tr ' ' .;
file-exists   = $(wildcard $1)
download-file = ($(call print-labeled,download,$2 <- $1); curl -fSL -o $2 $1)

github-repo-release-latest-tag = $(shell curl -fsSLI -o /dev/null -w %{url_effective} "https://github.com/$(strip $(1))/releases/latest" | rev | cut -d/ -f1 | rev)

islinux = $(filter Linux,$(ostype))
ismacos = $(filter Darwin,$(ostype))

ostype  := $(shell uname -s)
cputype := $(if $(ismacos),$($(shell uname -m):i386=x86_64),$(shell uname -m)) # Darwin `uname -m` lies
arch    := $(cputype:-=_)-$(shell printf %s "$(ostype)" | tr '[:upper:]' '[:lower:]')
ext     := $(if $(findstring windows,$(ostype)),.exe,)
#: }}

PACKAGES := bash zsh curl rcm
COMMANDS := apt brew bash zsh rcup curl asdf bin rustup tmux fzf fd vim emacs emacs broot
DOWNLOADS = $(LEIN_BIN) $(BIN_BIN)

.PHONY: all
all: info $(DOWNLOADS)

.PHONY: info
info: $(addprefix show-command-,$(sort $(COMMANDS)))

.PHONY: install
install:
	rcup -v

.PHONY: rustup
rustup:  # Installs rustup tool
	@$(call label,rustup): $(if $(rustup),detected,missing)
ifeq (,$(rustup))
	$(Q)curl --proto '=https' --tlsv1.2 -ssf https://sh.rustup.rs | sh
endif

ASDF_DIR ?= $(HOME)/.asdf
ASDF_SH   = $(ASDF_DIR)/asdf.sh

.PHONY: asdf
asdf:  ## Installs asdf version manager
	$(Q)git -C $(ASDF_DIR) rev-parse 2>/dev/null || git clone https://github.com/asdf-vm/asdf.git $(ASDF_DIR)
	source $(ASDF_DIR)/asdf.sh
	asdf update

# https://github.com/marcosnils/bin/releases/download/v0.9.1/bin_0.9.1_Linux_x86_64
BIN_TAG  = $(call github-repo-release-latest-tag,marcosnils/bin)
BIN_URL  = https://github.com/marcosnils/bin/releases/download/$(BIN_TAG)/bin_$(BIN_TAG:v%=%)_$(ostype)_$(cputype)$(ext)
BIN_BIN := local/bin/bin

$(BIN_BIN): # Installs bin tool
	$(Q)mkdir -p $(@D)
	$(Q)$(call download-file,$(BIN_URL),$@)
	$(Q)chmod +x $@

LEIN_TAG := stable
LEIN_URL := https://raw.githubusercontent.com/technomancy/leiningen/$(LEIN_TAG)/bin/lein
LEIN_BIN := local/bin/lein

$(LEIN_BIN): ## Installs Leiningen tool
	$(Q)mkdir -p $(@D)
	$(Q)$(call download-file,$(LEIN_URL),$@)
	$(Q)chmod +x $@

.PHONY: packages
packages: $(PACKAGES)

.PHONY: $(PACKAGES)
$(PACKAGES):
	@$(call print-labeled,install,$*)
ifneq (,$(apt))
	$(Q)$(apt) install -y $@
else ifneq (,$(brew))
	$(Q)$(brew) install $@
else
	@$(call fatal,Unable to detect package manager to install $@)
endif

show-command-%  Scmd-% : ; @$(call show-command,$*)
show-variable-% Svar-% : ; @echo -e "$(COLOR_BOLD)$(COLOR_BLUE)$*$(COLOR_RESET)=$($*)"

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / \
		{printf "\033[38;2;98;209;150m%-20s\033[0m %s\n", $$1, $$2}' \
		$(MAKEFILE_LIST)
