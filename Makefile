SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# ifndef DEBUG
# .SILENT:
# endif

.DEFAULT_GOAL := switch

WORKDIR 	:=$(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
USER    	?=$(shell whoami)
HOSTNAME	?=$(shell hostname -s)
SYSTEM 		:=$(shell uname -s)

ifdef DEBUG
FLAGS			+=--verbose
FLAGS			+=--show-trace
else
NIX_FLAGS 		+=--no-warn-dirty
endif

ifeq ($(SYSTEM),Darwin)
FLAGS			+=--impure
else # NixOS:
FLAGS			+=--option pure-eval no
endif

ifeq ($(SYSTEM),Darwin)
NIX_REBUILD :=darwin-rebuild $(FLAGS)
else
NIX_REBUILD :=home-manager $(FLAGS)
endif
NIX_REBUILD +=--flake $(WORKDIR)\#$(USER)@$(HOSTNAME)

# NOTE: trailing slash is significant
DOOMDIR  ?= ${HOME}/.doom.d/
EMACSDIR ?= ${HOME}/.emacs.d/

.PHONY: all clean
all: switch
clean: ; rm -f result

# Build targets.
.PHONY: switch rollback upgrade
switch: 	; $(NIX_REBUILD) switch
rollback: 	; $(NIX_REBUILD) switch --rollback
upgrade: 	; $(NIX_REBUILD) switch --upgrade

.PHONY: test
test: ACTION=$(if $(filter-out Darwin,$(SYSTEM)),test,check)
test: ; $(NIX_REBUILD) $(ACTION)

.PHONY: update
update:
	nix flake update

.PHONY:	gc
gc:
ifeq ($(SYSTEM),Darwin) 
	brew bundle cleanup --zap --force
endif
	nix-collect-garbage -d

.PHONY: emacs
emacs: $(EMACSDIR) $(DOOMDIR)
	$(EMACSDIR)/bin/doom install

$(EMACSDIR):
	git clone --depth 1 https://github.com/doomemacs/doomemacs $@

$(DOOMDIR): 
	git clone https://github.com/loganlinn/.doom.d $@
