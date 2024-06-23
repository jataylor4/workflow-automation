#!/bin/bash

set -euo pipefail

# Constants
USER=$(whoami)
HOME_DIR="/home/$USER"
CONFIG_DIR=$(dirname "$(readlink -f "$0")")
BACKUP_DIR="$HOME_DIR/backup_configs"

# Command line argument flags
SKIP_LIBS=false
RESTORE=false
SAVE_CONFIG=false
BACKUP=false

# Function to display usage information
usage() {
	cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --skip-libs       Skip library installation
  --restore         Restore configuration from backup
  --save-config     Save current configuration
  --backup	    Backup current configs
  -h, --help        Display this help message
EOF
	exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
	case $1 in
	--skip-libs) SKIP_LIBS=true ;;
	--restore) RESTORE=true ;;
	--save-config) SAVE_CONFIG=true ;;
	--backup) BACKUP=true ;;
	-h | --help) usage ;;
	*)
		echo "Invalid option: $1"
		usage
		;;
	esac
	shift
done

# Determine the Linux distribution
if [[ -f /etc/lsb-release ]]; then
	DISTRO="ubuntu"
elif [[ -f /etc/centos-release ]]; then
	DISTRO="centos"
else
	echo "Unsupported Linux distribution"
	exit 1
fi

# Lists for purging, configurations, and scripts
PURGE_LIST=(vim npm node nodejs neovim-runtime)
CONFIG_LIST=(.tmux.conf .bashrc .zshrc .fzf.bash .fzf.zsh .p10k.zsh)
USER_SCRIPTS=(docker_functions.sh Dockerfile)

# Functions for package management
update_system() {
	echo "Updating the system..."
	if [[ "$DISTRO" == "ubuntu" ]]; then
		sudo apt-get update
	elif [[ "$DISTRO" == "centos" ]]; then
		sudo yum update -y
	fi
}

purge_libs() {
	echo "Purging unnecessary libraries..."
	if [[ "$DISTRO" == "ubuntu" ]]; then
		sudo apt-get purge -y "${PURGE_LIST[@]}" || true
		sudo apt-get autoremove -y && sudo apt-get clean
	elif [[ "$DISTRO" == "centos" ]]; then
		sudo yum remove -y "${PURGE_LIST[@]}" || true
		sudo yum autoremove -y && sudo yum clean all
	fi

	echo "Removing Neovim configuration..."
	sudo rm -rf "$HOME_DIR/.config/nvim" "$HOME_DIR/.local/share/nvim"
}

install_libs() {
	echo "Installing essential libraries..."
	if [[ "$DISTRO" == "ubuntu" ]]; then
		sudo apt-get install -y --no-install-recommends \
			build-essential ca-certificates cmake curl git htop nano tmux wget \
			gdb valgrind lldb python3 python3-pip python3-venv \
			shellcheck libboost-all-dev cppcheck \
			ripgrep fzf exuberant-ctags tig silversearcher-ag shfmt python3-dbg
		sudo apt-get clean
	elif [[ "$DISTRO" == "centos" ]]; then
		sudo yum install -y gcc gcc-c++ make openssl-devel cmake curl git htop \
			nano tmux wget gdb valgrind lldb python3 python3-pip python3-venv \
			shellcheck boost-devel cppcheck \
			ripgrep fzf ctags tig the_silver_searcher shfmt python3-dbg
		sudo yum clean all
	fi

	pip3 install jupyter black pytest pylint mypy pdbpp ipython wheel pipenv shell-gpt
}

backup_existing_configs() {
	echo "Backing up existing configuration files..."
	mkdir -p "$BACKUP_DIR"
	for file in "${CONFIG_LIST[@]}" "$HOME_DIR/.config/nvim" "$HOME_DIR/.local/share/nvim" "$HOME_DIR/.local/share/zinit"; do
		[[ -e "$file" ]] && cp -r "$file" "$BACKUP_DIR"
	done
}

restore_configs() {
	echo "Restoring configuration files from backup..."
	for file in "${CONFIG_LIST[@]}"; do
		[[ -e "$BACKUP_DIR/$file" ]] && cp "$BACKUP_DIR/$file" "$HOME_DIR/"
	done
	cp -r "$BACKUP_DIR/nvim" "$HOME_DIR/.config/"
	cp -r "$BACKUP_DIR/zinit" "$HOME_DIR/.local/share/"
}

install_neovim() {
	echo "Installing Neovim..."
	local NVIM_URL="https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz"
	local NVIM_TAR="nvim-linux64.tar.gz"
	local NVIM_DIR="nvim-linux64"

	wget -O "$NVIM_TAR" "$NVIM_URL"
	tar -xzvf "$NVIM_TAR"
	sudo mv "$NVIM_DIR" /usr/local/nvim
	sudo ln -sf /usr/local/nvim/bin/nvim /usr/bin/nvim
	rm "$NVIM_TAR"
}

install_node_npm() {
	echo "Installing Node.js and npm..."
	curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
	if [[ "$DISTRO" == "ubuntu" ]]; then
		sudo apt-get install -y --no-install-recommends nodejs
		sudo apt-get clean
	elif [[ "$DISTRO" == "centos" ]]; then
		sudo yum install -y nodejs
		sudo yum clean all
	fi
}

install_zsh_fonts() {
	echo "Installing Zsh and JetBrainsMono Nerd Font..."
	if [[ "$DISTRO" == "ubuntu" ]]; then
		sudo apt-get install -y zsh fontconfig unzip
	elif [[ "$DISTRO" == "centos" ]]; then
		sudo yum install -y zsh fontconfig unzip
	fi

	mkdir -p "$HOME_DIR/.local/share/fonts"
	cd "$HOME_DIR/.local/share/fonts"
	curl -fLo "JetBrainsMonoNerdFont.zip" \
		https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip
	unzip JetBrainsMonoNerdFont.zip -d JetBrainsMonoNerdFont
	rm JetBrainsMonoNerdFont.zip
	fc-cache -fv
}

create_aliases() {
	echo "Creating aliases..."
	sudo ln -sf /usr/bin/python3 /usr/bin/python
	sudo ln -sf /usr/bin/nvim /usr/bin/vim
}

copy_config_files() {
	echo "Copying configuration files..."
	for file in "${CONFIG_LIST[@]}"; do
		[[ -e "$CONFIG_DIR/files/$file" ]] && cp "$CONFIG_DIR/files/$file" "$HOME_DIR/"
	done

	echo "Copying utility scripts..."
	for script in "${USER_SCRIPTS[@]}"; do
		[[ -e "$CONFIG_DIR/files/$script" ]] && cp "$CONFIG_DIR/files/$script" "$HOME_DIR/"
	done

	echo "Copying Zinit and Neovim configuration..."
	mkdir -p "$HOME_DIR/.local/share/zinit" "$HOME_DIR/.config/nvim" "$HOME_DIR/.local/share/nvim"
	[[ -d "$CONFIG_DIR/.local/share/zinit" ]] && cp -r "$CONFIG_DIR/.local/share/zinit" "$HOME_DIR/.local/share/zinit"
	[[ -d "$CONFIG_DIR/.local/share/nvim" ]] && cp -r "$CONFIG_DIR/.local/share/nvim" "$HOME_DIR/.local/share/nvim"
	[[ -d "$CONFIG_DIR/.config/nvim" ]] && cp -r "$CONFIG_DIR/.config/nvim" "$HOME_DIR/.config/nvim"
}

setup_nvchad() {
	echo "Installing and configuring NvChad..."
	[[ -d "$HOME_DIR/.config/nvim" ]] && rm -rf "$HOME_DIR/.config/nvim"

	git clone https://github.com/NvChad/NvChad -b v2.0 "$HOME_DIR/.config/nvim"
	nvim --headless +qall

	echo "Waiting for lazy.nvim to finish downloading plugins..."
	sleep 10

	nvim --headless -c 'MasonInstallAll' -c 'qall'
	rm -rf "$HOME_DIR/.config/nvim/.git"

	echo "Copying custom NvChad configuration..."
	[[ -d "$CONFIG_DIR/.config/nvim/lua/custom" ]] && cp -r "$CONFIG_DIR/.config/nvim/lua/custom" "$HOME_DIR/.config/nvim/lua/" || echo "Custom NvChad configuration not found in $CONFIG_DIR"

	echo "Re-running MasonInstall..."
	nvim --headless -c 'MasonInstallAll' -c 'qall'
}

setup_zsh() {
	echo "Setting up Zsh..."
	if command -v zsh >/dev/null 2>&1; then
		sudo chsh -s "$(which zsh)" "$USER"
	fi
	sudo -u "$USER" zsh -c "source ~/.zshrc"
}

setup_pwndbg() {
	echo "Setting up Pwndbg..."
	git clone https://github.com/pwndbg/pwndbg "$HOME_DIR/pwndbg"
	bash "$HOME_DIR/pwndbg/setup.sh"
	rm -rf "$HOME_DIR/pwndbg"
}
save_config() {
	echo "Saving current configuration to $CONFIG_DIR..."
	mkdir -p "$CONFIG_DIR/files"
	for file in "${CONFIG_LIST[@]}"; do
		[[ -e "$HOME_DIR/$file" ]] && cp "$HOME_DIR/$file" "$CONFIG_DIR/files/"
	done
	cp -r "$HOME_DIR/.local/share/zinit" "$CONFIG_DIR/.local/share/"
	cp -r "$HOME_DIR/.config/nvim" "$CONFIG_DIR/.config/"
}

cleanup() {
	echo "Cleaning up..."
	rm -rf "$HOME_DIR/.local/share/zinit" "$HOME_DIR/.config/nvim" "$HOME_DIR/.local/share/nvim"
	rm -f "$HOME_DIR/.local/share/fonts/JetBrainsMonoNerdFont.zip"
	rm -rf "$HOME_DIR/.local/share/fonts/JetBrainsMonoNerdFont"
	sudo rm -rf /usr/local/nvim/nvim-linux64 || true
}

# Main script execution
cleanup

if [[ "$RESTORE" == true ]]; then
	restore_configs
	exit 0
fi

if [[ "$BACKUP" == true ]]; then
	backup_existing_configs
	exit 0
fi

if [[ "$ONLY_LIBS" == true ]]; then
	update_system
	install_libs
	create_aliases
	setup_pwndbg
	exit 0
fi

if [[ "$SKIP_LIBS" == false ]]; then
	update_system
	purge_libs
	install_libs
fi

copy_config_files
install_neovim
install_node_npm
install_zsh_fonts
install_pwndbg
create_aliases
setup_nvchad
setup_zsh

[[ "$SAVE_CONFIG" == true ]] && save_config

echo "Setup completed successfully."
echo "Note: to integrate shell-gpt run: sgpt --install-integration"
