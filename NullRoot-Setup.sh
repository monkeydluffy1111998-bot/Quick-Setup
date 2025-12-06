#!/usr/bin/env bash

###################################################################
#                     NULLROOT SCRIPT ENGINE                      #
###################################################################

# Clear terminal for full-page effect
clear

# ------------------------------- #
# Logging
# ------------------------------- #
LOGFILE="$HOME/nullroot-install-$(date +"%Y-%m-%d_%H-%M-%S").log"
exec > >(tee -a "$LOGFILE") 2>&1

# ------------------------------- #
# Status UI
# ------------------------------- #
success() { echo "[✔] $1"; }
error() {
  echo "[✘] $1"
  exit 1
}
info() { echo "[➤] $1"; }
warn() { echo "[!] $1"; }

# ------------------------------- #
# Banner
# ------------------------------- #
cat <<"EOF"

###################################################################
#                     NULLROOT SCRIPT ENGINE                      #
###################################################################
#   _   _       _ _ ____             _                            #
#  | \ | |_   _| | |  _ \ ___   ___ | |_                          #
#  | \| | | | | | | |_) / _ \ / _ \| __|                         #
#  | |\  | |_| | | |  _ < (_) | (_) | |_                          #
#  |_| \_|\__,_|_|_|_| \_\___/ \___/ \__|                         #
#                                                                 #
#                     Created By: NullRoot                        #
#                     GitHub: github.com/nullroot                 #
###################################################################

EOF

echo "Log file: $LOGFILE"
# ------------------------------- #
# Main Menu
# ------------------------------- #
echo
echo "Choose what you want to install:"
echo " 1) Full Installation (Pacman + AUR + Flatpak)"
echo " 2) Only Pacman Packages"
echo " 3) Only AUR Packages"
echo " 4) Only Flatpak Setup"
echo " 5) Exit"
echo

read -p "Enter choice (1-5): " choice

case "$choice" in
1) MODE="full" ;;
2) MODE="pacman" ;;
3) MODE="aur" ;;
4) MODE="flatpak" ;;
5)
  info "Exiting..."
  exit 0
  ;;
*) error "Invalid choice! Exiting." ;;
esac

# ------------------------------- #
# Confirm
# ------------------------------- #
read -p "Are you sure you want to continue? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
  info "Cancelled by user."
  exit 0
fi

clear
info "Starting NullRoot installation..."
sleep 1

# ------------------------------- #
# Progress bar function
# ------------------------------- #
progress_bar() {
  local progress=$1
  local width=40
  local done=$((progress * width / 100))
  local left=$((width - done))
  printf "\r["
  printf "%0.s#" $(seq 1 $done)
  printf "%0.s-" $(seq 1 $left)
  printf "] %d%%" "$progress"
}

run_progress() {
  for i in $(seq 1 100); do
    progress_bar "$i"
    sleep 0.003
  done
  echo
}

# ------------------------------- #
# Pacman Installer
# ------------------------------- #
install_pkg() {
  if pacman -Qi "$1" &>/dev/null; then
    success "$1 already installed (skipped)"
  else
    info "Installing $1..."
    run_progress
    sudo pacman -S --noconfirm "$1" && success "$1 installed" || warn "$1 failed"
  fi
}

if [[ "$MODE" == "full" || "$MODE" == "pacman" ]]; then
  PAC_PKGS=(git wget curl base-devel unzip htop fastfetch btop kitty vim nano firefox flatpak discord telegram-desktop)
  for pkg in "${PAC_PKGS[@]}"; do
    install_pkg "$pkg"
  done
fi

# ------------------------------- #
# AUR Installer
# ------------------------------- #
install_aur() {
  if yay -Qi "$1" &>/dev/null; then
    success "$1 already installed (skipped)"
  else
    info "Installing AUR package: $1..."
    run_progress
    yay -S --noconfirm "$1" && success "$1 installed" || warn "$1 failed (AUR)"
  fi
}

if [[ "$MODE" == "full" || "$MODE" == "aur" ]]; then
  if command -v yay &>/dev/null; then
    AUR_PKGS=(zen-browser-bin google-chrome brave-bin visual-studio-code-bin spotify whatsapp-nativefier onlyoffice-bin)
    for aur in "${AUR_PKGS[@]}"; do
      install_aur "$aur"
    done
  else
    warn "YAY not installed! Skipping AUR packages."
  fi
fi

# ------------------------------- #
# Flatpak Setup
# ------------------------------- #
if [[ "$MODE" == "full" || "$MODE" == "flatpak" ]]; then
  if command -v flatpak &>/dev/null; then
    info "Adding Flathub repo..."
    run_progress
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    success "Flathub ready"
  else
    warn "Flatpak not installed! Skipping."
  fi
fi

# ------------------------------- #
# Finished
# ------------------------------- #
echo
success "NullRoot Setup Completed Successfully ✅"
echo "Jai Shree Ram 🚩"
echo "Installation log saved at: $LOGFILE"
read -p "Press ENTER to exit..."
clear
