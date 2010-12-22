#!/usr/bin/env bash

# =============================================================================
# File name: autogeili.sh
# Author: Richard Ma (richard_ma)
# Email: richard.ma.19850509@gmail.com
# Blog: http://www.richardma.org
#
# Google Code:
# 	http://code.google.com/p/autogeili/
# Wallpaper Source - WordsMotivate:
# 	http://www.wordsmotivate.me
# =============================================================================

img_file=today_wallpaper
data_file=data
config_dir=~/.autogeili

# 
# Create config_dir if not exsist
# -----------------------------------------------------------------------------
if [ ! -e $config_dir ]; then
	mkdir -p $config_dir
elif [ ! -d $config_dir ]; then
	notify-send "Autogeili" "Cann't create config directory. [$config_dir]" -i /usr/share/pixmaps/gnome-irc.png
	exit
fi

# 
# Update date in data_file
# -----------------------------------------------------------------------------
today_date=`date +%Y-%d-%m`
if [ -e $config_dir/$data_file ]; then
	data_date=`cat $config_dir/$data_file`
	if [ $today_date = $data_date ]; then
		notify-send "Autogeili" "You have already downloaded today's wallpaper." -i /usr/share/pixmaps/gnome-irc.png
		exit
	fi
fi

echo $today_date > $config_dir/$data_file

# 
# Setting another wallpaper
# -----------------------------------------------------------------------------
gconftool-2 \
	--type string \
	--set /desktop/gnome/background/picture_filename "/usr/share/backgrounds/warty-final-ubuntu.png"

#
# Screen Resolution autodetect 
#
# Resolution valid value: 
# 	1920x1200 (16:10)
#	1920x1080 (16: 9)
#	1600x1200 ( 4: 3)
#	1600x1200 ( 5: 4) Fix Resolution 1280x1024
# -----------------------------------------------------------------------------
screen_width=`xrandr | grep \* | cut -d' ' -f 4 | cut -d'x' -f 1`
screen_height=`xrandr | grep \* | cut -d' ' -f 4 | cut -d'x' -f 2`

if [ `expr $screen_width \* 10` -eq `expr $screen_height \* 16` ]; then
	resolution=1920x1200
elif  [ `expr $screen_width \* 9` -eq `expr $screen_height \* 16` ]; then
	resolution=1920x1080
elif  [ `expr $screen_width \* 3` -eq `expr $screen_height \* 4` ]; then
	resolution=1600x1200
elif  [ `expr $screen_width \* 4` -eq `expr $screen_height \* 5` ]; then
	resolution=1600x1200
else
	success_flg=-1
fi

#
# Remove yesterday wallpaper
# -----------------------------------------------------------------------------
if [ -e $config_dir/$img_file.jpg ]; then
	rm $config_dir/$img_file.jpg
fi

if [ -e $config_dir/$img_file.png ]; then
	rm $config_dir/$img_file.png
fi

# 
# Get today wallpaper.
# -----------------------------------------------------------------------------
wget \
	-c http://img.wordsmotivate.me/`date +%Y.%m`/`date +%Y.%m.%d`_$resolution.jpg \
       	-O $config_dir/$img_file.jpg

if [ $? -eq 0 ]; then
	suffix=jpg
	success_flg=0
else
	wget \
		-c http://img.wordsmotivate.me/`date +%Y.%m`/`date +%Y.%m.%d`_$resolution.png \
	       	-O $config_dir/$img_file.png
	if [ $? -eq 0 ]; then
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
if [ $success_flg -eq 0 ]; then
	gconftool-2 \
		--type string \
		--set /desktop/gnome/background/picture_options "zoom"
	gconftool-2 \
		--type int 	\
		--set /desktop/gnome/background/picture_opacity 100
	gconftool-2 \
		--type string \
		--set /desktop/gnome/background/color_shading_type "solid"
	gconftool-2 \
		--type bool 	\
		--set /desktop/gnome/background/draw_background true
	gconftool-2 \
		--type string \
		--set /desktop/gnome/background/picture_filename "$config_dir/$img_file.$suffix"
fi

#
# Job completed !
# -----------------------------------------------------------------------------
if [ $success_flg -eq 0 ]; then
	notify-send "Autogeili" "Update Completed!" -i /usr/share/pixmaps/gnome-irc.png
fi
