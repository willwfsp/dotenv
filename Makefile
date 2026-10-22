.DEFAULT_GOAL := menu
.PHONY: menu help install apply diff update ios xcode remote-access doctor

menu: ## Interactive menu (plain target list when there's no terminal)
	@./scripts/menu.sh

help: ## Show available targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

install: ## Bootstrap a fresh Mac (CLT, Homebrew, chezmoi) and apply dotfiles
	./install.sh

apply: ## Apply dotfiles to $HOME
	chezmoi apply

diff: ## Preview what apply would change
	chezmoi diff

update: ## Pull the repo and apply
	chezmoi update

ios: ## Turn on the iOS profile (xcodes, Tuist) and apply
	chezmoi init --data=false --promptBool "Install the iOS profile (xcodes, Tuist)=true" --apply

xcode: ## Install Xcode via xcodes (pick a version, defaults to latest stable)
	./scripts/xcode.sh

remote-access: ## Turn on key-only SSH into this Mac (needs a key in .chezmoidata/ssh.yaml)
	./scripts/remote-access.sh

doctor: ## Health checks for chezmoi, Homebrew and mise
	chezmoi doctor; brew doctor; mise doctor
