#!/usr/bin/env bash

# =============================================================================
# File name: autogeili.sh
# Author: Richard Ma
# Gmail: richard.ma.19850509@gmail.com
# Blog: http://www.richardma.org
#
# Google Code:
#
# Wallpaper Source - WordsMotivate:
# 	http://www.wordsmotivate.me
# =============================================================================

#
# Settings
#
# Valid value: 
# 	1920x1200
#	1920x1080
#	1600x1200
# -----------------------------------------------------------------------------
resolution=1920x1200

#
# Remove yesterday wallpaper
# -----------------------------------------------------------------------------
if [ -e today.jpg ]
then
	rm today.jpg
fi

if [ -e today.png ]
then
	rm today.png
fi

# 
# Get today wallpaper.
# -----------------------------------------------------------------------------
wget \
	-c http://img.wordsmotivate.me/`date +%Y.%m`/`date +%Y.%m.%d`_$resolution.jpg \
       	-O today.jpg
suffix=jpg

success_flg=true

# TODO: $success_flg always return true.
# Fix next version

if [ $? -ne 0 ]
then
	wget \
		-c http://img.wordsmotivate.me/`date +%Y.%m`/`date +%Y.%m.%d`_$resolution.png \
	       	-O today.png
	if [ $? ]
	then
		suffix=png
		success_flg=true
	else
		# cann't get image
		success_flg=false
		notify-send "Autogeili" "Cann't download wallpaper!" -i /usr/share/pixmaps/gnome-irc.png
	fi
fi

# 
# Config wallpaper using gconftool
# -----------------------------------------------------------------------------
if [ $success_flg ]
then 
	gconftool --type string \
		--set /desktop/gnome/background/picture_options "zoom"
	gconftool --type int 	\
		--set /desktop/gnome/background/picture_opacity 100
	gconftool --type string \
		--set /desktop/gnome/background/color_shading_type "solid"
	gconftool --type bool 	\
		--set /desktop/gnome/background/draw_background true
	gconftool --type string \
		--set /desktop/gnome/background/picture_filename "$PWD/today.$suffix"
fi

#
# Job completed !
# -----------------------------------------------------------------------------
if [ $success_flg ]
then
	notify-send "Autogeili" "Update Completed!" -i /usr/share/pixmaps/gnome-irc.png
fi
