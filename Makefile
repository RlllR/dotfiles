DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
CANDIDATES := $(whildcard .??*) bin
EXCLUSIONS := .git .gitmodules .travis.yml
DOTFILES   := $(filter-out $(EXCLUSIONS0), $(CANDIDATES))

test: # DEBUG
	@echo $(DOTPATH)

all:

list: ## Show dot files in thie repo
	@$(foreach val, $(DOTFILES), /bin/ls -dF $(val;))
