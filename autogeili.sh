#!/usr/bin/env bash

# =============================================================================
# File name: autogeili.sh
# Author: Richard Ma (richard_ma)
# Gmail: richard.ma.19850509@gmail.com
# Blog: http://www.richardma.org
#
# Google Code:
# 	http://code.google.com/p/autogeili/
# Wallpaper Source - WordsMotivate:
# 	http://www.wordsmotivate.me
# =============================================================================

#
# Settings
#
# Resolution valid value: 
# 	1920x1200
#	1920x1080
#	1600x1200
# -----------------------------------------------------------------------------
resolution=1600x1200

temp_file=.today
temp_dir=$PWD

#
# Remove yesterday wallpaper
# -----------------------------------------------------------------------------
if [ -e $temp_dir/$temp_file.jpg ]
then
	rm $temp_dir/$temp_file.jpg
fi

if [ -e $temp_dir/$temp_file.png ]
then
	rm $temp_dir/$temp_file.png
fi

# 
# Get today wallpaper.
# -----------------------------------------------------------------------------
wget \
	-c http://img.wordsmotivate.me/`date +%Y.%m`/`date +%Y.%m.%d`_$resolution.jpg \
       	-O $temp_file.jpg

if [ $? -eq 0 ]
then
	suffix=jpg
	success_flg=0
else
	wget \
		-c http://img.wordsmotivate.me/`date +%Y.%m`/`date +%Y.%m.%d`_$resolution.png \
	       	-O $temp_file.png
	if [ $? -eq 0 ]
	then
		suffix=png
		success_flg=0
	else
		# cann't get image
		success_flg=-1
		notify-send "Autogeili" "Cann't download wallpaper!" -i /usr/share/pixmaps/gnome-irc.png
	fi
fi

# 
# Config wallpaper using gconftool
# -----------------------------------------------------------------------------
if [ $success_flg -eq 0 ]
then 
	gconftool-2 --type string \
		--set /desktop/gnome/background/picture_options "zoom"
	gconftool-2 --type int 	\
		--set /desktop/gnome/background/picture_opacity 100
	gconftool-2 --type string \
		--set /desktop/gnome/background/color_shading_type "solid"
	gconftool-2 --type bool 	\
		--set /desktop/gnome/background/draw_background true
	gconftool-2 --type string \
		--set /desktop/gnome/background/picture_filename "$temp_dir/$temp_file.$suffix"
fi

#
# Job completed !
# -----------------------------------------------------------------------------
if [ $success_flg -eq 0 ]
then
	notify-send "Autogeili" "Update Completed!" -i /usr/share/pixmaps/gnome-irc.png
fi
