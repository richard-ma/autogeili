#!/usr/bin/env bash

# =============================================================================
# NOTICE: Must use this script under root or after sudo command!
# 注意：请在root用户或在sudo命令后使用本安装脚本！
#
# sudo ./install.sh
#
# =============================================================================

#
# Install gconf2 for gconftool-2
# -----------------------------------------------------------------------------
apt-get install gconf2

#
# Install libnotify-bin for notify-send
# -----------------------------------------------------------------------------
apt-get install libnotify-bin

# 
# Install x11-xserver-utils for xrandr
# -----------------------------------------------------------------------------
sudo apt-get install x11-xserver-utils

# 
# Install Files
# -----------------------------------------------------------------------------
install -d \
	/usr/bin \
	/usr/share/autogeili
install -m 0644 icons/* /usr/share/autogeili
install -m 0755 autogeili.sh /usr/bin

# 
# Create CONFIG_DIR and CONFIG_FILES
# -----------------------------------------------------------------------------
install -d \
    ~/.autogeili
