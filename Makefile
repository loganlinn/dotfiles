SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

V ?=
Q := $(if $(V),,@)

MAKEFILE_PATH := $(realpath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR  := $(dir $(MAKEFILE_PATH))/

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

##
## Helpers for $(call helper,...)
##
find-command  = $(shell command -v $(1) 2>/dev/null)
file-exists   = $(wildcard $1)
ok            = echo "$(COLOR_BOLD)$(COLOR_GREEN)$(or $(1),OK)$(COLOR_RESET)"
label         = echo "$(COLOR_BOLD)$(COLOR_MAGENTA)$(1)$(COLOR_RESET)$(2)"
fatal         = (echo "$(COLOR_BOLD)$(COLOR_FATAL)$(1)$(COLOR_RESET)"; exit 1)

#######################

apt    = $(call find-command,apt)
brew   = $(call find-command,brew)
rustup = $(call find-command,rustup)
rcup   = $(call find-command,rcup)
zsh    = $(call find-command,zsh)

DEPS := zsh rcup rustup

export PATH:=$(MAKEFILE_DIR)bin:$(PATH)

.PHONY: deps
deps: show_deps install_deps

.PHONY: show_deps
show_deps: $(foreach dep,$(DEPS),show_$(dep))

.PHONY: install_deps
install_deps: $(foreach dep,$(DEPS),install_$(dep))
	@$(ok)

.PHONY: $(foreach dep,$(DEPS),install_$(dep))

install_zsh:
ifeq (,$(zsh))
	@$(call label,Installing zsh...)
ifneq (,$(apt))
	$(Q)$(apt) install -y zsh
else ifneq (,$(brew))
	$(Q)$(brew) install zsh
endif
	@$(ok)
endif


install_rustup:
ifeq (,$(rustup))
	@$(call label,Installing rustup...)
	$(Q)curl --proto '=https' --tlsv1.2 -ssf https://sh.rustup.rs | sh
endif


install_rup:
ifeq (,$(rcup))
	@$(call label,Installing rcm...)
ifneq (,$(apt))
	$(apt) install -y rcm
else ifneq (,$(brew))
	$(brew) install rcm
endif
endif


show_% : ; @echo "$(COLOR_BOLD)$(COLOR_BLUE)$*$(COLOR_RESET)=$($*)" # Displays variable
