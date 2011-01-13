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

readonly DATE_TODAY=`date +%Y.%-m.%-d`
readonly MONTH_TODAY=`date +%Y.%-m`
readonly WALLPAPER_FILE=today_wallpaper
readonly CONFIG_FILE=config
readonly CONFIG_DIR=~/.autogeili
readonly DOMAIN_URL=wordsmotivate.me
readonly IMG_PREFIX_URL=img
readonly API_PREFIX_URL=api
readonly API_SUFFIX_URL=WallpaperFormat.php
         IMG_SUFFIX_URL=$MONTH_TODAY/$DATE_TODAY
         IMG_URL=http://$IMG_PREFIX_URL.$DOMAIN_URL/$IMG_SUFFIX_URL
         API_URL=http://$API_PREFIX_URL.$DOMAIN_URL/$API_SUFFIX_URL

# 
# Create CONFIG_DIR if not exsist
# -----------------------------------------------------------------------------
if [ ! -e $CONFIG_DIR ]; then
	mkdir -p $CONFIG_DIR
elif [ ! -d $CONFIG_DIR ]; then
	notify-send "Autogeili" "Cann't create config directory. [$CONFIG_DIR]" -i /usr/share/pixmaps/gnome-irc.png
	exit
fi

# 
# Update date in CONFIG_FILE
# -----------------------------------------------------------------------------
if [ -e $CONFIG_DIR/$CONFIG_FILE ]; then
	data_date=`cat $CONFIG_DIR/$CONFIG_FILE`
	if [ $DATE_TODAY = $data_date ]; then
		notify-send "Autogeili" "You have already downloaded today's wallpaper." -i /usr/share/pixmaps/gnome-irc.png
		exit
	fi
fi

echo $DATE_TODAY > $CONFIG_DIR/$CONFIG_FILE

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
# 	1920x1200 ( 8: 5)
#	1920x1080 (16: 9)
#	1920x1080 (1366x768) Fix Resolution 1366x768
#	1600x1200 ( 4: 3)
#	1600x1200 ( 5: 4) Fix Resolution 1280x1024
# -----------------------------------------------------------------------------
screen_width=`xrandr | grep \* | cut -d' ' -f 4 | cut -d'x' -f 1`
screen_height=`xrandr | grep \* | cut -d' ' -f 4 | cut -d'x' -f 2`

if [ `expr $screen_width \* 8` -eq `expr $screen_height \* 5` ]; then
	resolution=1920x1200
elif  [ `expr $screen_width \* 9` -eq `expr $screen_height \* 16` ]; then
	resolution=1920x1080
elif  [ $screen_width -eq 1366 ] && [ $screen_height -eq 768 ]; then
	resolution=1920x1080
elif  [ `expr $screen_width \* 3` -eq `expr $screen_height \* 4` ]; then
	resolution=1600x1200
elif  [ `expr $screen_width \* 4` -eq `expr $screen_height \* 5` ]; then
	resolution=1600x1200
else
	success_flg=-1
fi
IMG_URL=$IMG_URL\_$resolution

#
# Remove yesterday wallpaper
# -----------------------------------------------------------------------------
if [ -e $CONFIG_DIR/$WALLPAPER_FILE.jpg ]; then
	rm $CONFIG_DIR/$WALLPAPER_FILE.jpg
fi

if [ -e $CONFIG_DIR/$WALLPAPER_FILE.png ]; then
	rm $CONFIG_DIR/$WALLPAPER_FILE.png
fi

# 
# Get today wallpaper.
# -----------------------------------------------------------------------------
wget \
	-c $IMG_URL.jpg \
       	-O $CONFIG_DIR/$WALLPAPER_FILE.jpg

if [ $? -eq 0 ]; then
	suffix=jpg
	success_flg=0
else
	wget \
		-c $IMG_URL.png \
	       	-O $CONFIG_DIR/$WALLPAPER_FILE.png
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
		--set /desktop/gnome/background/picture_filename "$CONFIG_DIR/$WALLPAPER_FILE.$suffix"
fi

#
# Job completed !
# -----------------------------------------------------------------------------
if [ $success_flg -eq 0 ]; then
	notify-send "Autogeili" "Update Completed!" -i /usr/share/pixmaps/gnome-irc.png
fi
