#!/usr/bin/env bash

# =============================================================================
# File Name: autogeili.sh
# Author: Richard Ma (richard_ma)
# Email: richard.ma.19850509@gmail.com
# Blog: http://www.richardma.org
# 
# GitHub
# 	https://github.com/richard-ma/autogeili
# Google Code:
# 	http://code.google.com/p/autogeili/
# 
# wallpaper source - wordsmotivate:
# 	http://www.wordsmotivate.me
# 
# LICENSE:
# 	GPL V3
# 	http://www.gnu.org/licenses/gpl.txt
# =============================================================================

readonly TIME_NOW_DATE=`date +%Y.%-m.%-d`
readonly TIME_NOW_MONTH=`date +%Y.%-m`

readonly CONFIG_FILE=~/.autogeilirc
readonly CONFIG_DIR=~/.autogeili

readonly WALLPAPER_FILE=$CONFIG_DIR/wallpaper
readonly WALLPAPER_TMP_FILE=$CONFIG_DIR/tmp_wallpaper
readonly WALLPAPER_DOWNLOAD_FILE=$CONFIG_DIR/down_wallpaper

readonly DOMAIN_URL=wordsmotivate.me
readonly IMG_PREFIX_URL=img
readonly API_PREFIX_URL=api
readonly API_SUFFIX_URL=WallpaperFormat.php
readonly IMG_SUFFIX_URL=$TIME_NOW_MONTH/$TIME_NOW_DATE
readonly IMG_URL=http://$IMG_PREFIX_URL.$DOMAIN_URL/$IMG_SUFFIX_URL
readonly API_URL=http://$API_PREFIX_URL.$DOMAIN_URL/$API_SUFFIX_URL

readonly ICON_FILE=/usr/share/autogeili/autogeili-icon-sf.png

# 
# Function: autogeili_check_need_update
#
# Params:
# 	$1 config_file:	User rc profile
# 	
# Return:
# 	Currect:	0	need update
# 	Error:		1
# -----------------------------------------------------------------------------
function autogeili_check_need_update()
{
	config_file=$1

	log_date=`cat $config_file | grep -i "last_update" | cut -d':' -f2`
	today_date=$TIME_NOW_DATE

	if [ $log_date == $today_date ]; then
		echo 1		# already updated
	else
		echo 0		# need update
	fi
}

#
# Function: autogeili_get_file_type
#
# Params:
# 	None
#
# Return:
# 	Currect:	valid file type
# 	Error:		unknown
#
# Valid file type
# 	jpg
# 	png
# -----------------------------------------------------------------------------
function autogeili_get_file_type()
{
	wget \
		-c $API_URL \
		-O $CONFIG_DIR/format.api
	if [ $? -ne 0 ]; then
		echo "unknown"
		return
	fi

	IMG_TYPE=`cat $CONFIG_DIR/format.api | grep REQ_RESULT_END | cut -d'[' -f 1 | cut -d':' -f 2 | tr '[A-Z]' '[a-z]'`
	rm $CONFIG_DIR/format.api

	echo $IMG_TYPE
}

# 
# Function: autogeili_check_user_dir
#
# Params:
# 	None
#
# Return:
# 	Currect:	0
# 	Error:		0
# -----------------------------------------------------------------------------
function autogeili_check_user_dir()
{
	if [ ! -e $CONFIG_DIR ]; then
		mkdir -p $CONFIG_DIR
		touch $WALLPAPER_FILE.jpg
	fi

	if [ ! -e $CONFIG_FILE ]; then
		touch $CONFIG_FILE
		echo "last_update:`date --date=\"yesterday\" +%y.%-m.%-d`" >> $CONFIG_FILE
	fi

	echo 0
}

#
# Function: autogeili_set_wallpaper
#
# Params:
# 	$1 wallpaper:	The wallpaper file and full path
#
# Return:
# 	Currect: 	0
# 	Error:		1
# -----------------------------------------------------------------------------
function autogeili_set_wallpaper()
{
	wallpaper=$1

	while true
	do
		gconftool-2 \
			--type string \
			--set /desktop/gnome/background/picture_options "zoom"
		if [ $? -ne 0 ]; then break; fi
		gconftool-2 \
			--type int 	\
			--set /desktop/gnome/background/picture_opacity 100
		if [ $? -ne 0 ]; then break; fi
		gconftool-2 \
			--type string \
			--set /desktop/gnome/background/color_shading_type "solid"
		if [ $? -ne 0 ]; then break; fi
		gconftool-2 \
			--type bool 	\
			--set /desktop/gnome/background/draw_background true
		if [ $? -ne 0 ]; then break; fi
		gconftool-2 \
			--type string \
			--set /desktop/gnome/background/picture_filename "$wallpaper"
		if [ $? -ne 0 ]; then break; fi

		echo 0
		return
	done;

	echo 1
}

# 
# Function: autogeili_notify
#
# Params:
# 	$1 msg:		The message will display
# 	$2 icon:	The icon of autogeili
#
# Return:
# 	Currect:	0
# 	Error:		0
# -----------------------------------------------------------------------------
function autogeili_notify()
{
	msg=$1
	icon=$2

	notify-send "Autogeili" "$msg" -i "$icon"

	# error occurd
	if [ $? -ne 0 ]; then
		echo 1
		return 
	fi

	echo 0
}

# 
# Function: autogeili_autodetect_resolution
#
# Params:
# 	None
#
# Return:
# 	Currect:	valid resolution value
# 	Error:		0x0
#
# Resolution valid value: 
# 	1920x1200 ( 8: 5)
#	1920x1080 (16: 9)
#	1920x1080 (1366x768) Fix Resolution 1366x768
#	1600x1200 ( 4: 3)
#	1600x1200 ( 5: 4) Fix Resolution 1280x1024
# -----------------------------------------------------------------------------
function autogeili_autodetect_resolution()
{
	screen_width=`xrandr | grep \* | cut -d' ' -f 4 | cut -d'x' -f 1`
	screen_height=`xrandr | grep \* | cut -d' ' -f 4 | cut -d'x' -f 2`

	if [ `expr $screen_width \* 5` -eq `expr $screen_height \* 8` ]; then
		resolution="1920x1200"
	elif  [ `expr $screen_width \* 9` -eq `expr $screen_height \* 16` ]; then
		resolution="1920x1080"
	elif  [ $screen_width -eq 1366 ] && [ $screen_height -eq 768 ]; then
		resolution="1920x1080"
	elif  [ `expr $screen_width \* 3` -eq `expr $screen_height \* 4` ]; then
		resolution="1600x1200"
	elif  [ `expr $screen_width \* 4` -eq `expr $screen_height \* 5` ]; then
		resolution="1600x1200"
	else
		resolution="0x0"
	fi
	
	echo $resolution
}

# 
# Function: main
# =============================================================================
function main()
{
	succ_flg=0

	# 
	# Check user profile and user temp dir.
	#
	succ_flg=`autogeili_check_user_dir`
	if [ 0 -lt $succ_flg ]; then 
		abs_var=`autogeili_notify "Cann't get user profile." $ICON_FILE`
		return 1
	fi

	# 
	# Check last update date
	#
	succ_flg=`autogeili_check_need_update $CONFIG_FILE`
	if [ 0 -lt $succ_flg ]; then 
		abs_var=`autogeili_notify "Today's wallpaper has already been updated." $ICON_FILE`
		return 2
 	fi

	# 
	# Get screen resolution.
	#
	succ_flg=`autogeili_autodetect_resolution`
	if [ "0x0" == $succ_flg ]; then
		abs_var=`autogeili_notify "Cann't get screen resolution." $ICON_FILE`
		return 3
	fi
	readonly resolution=$succ_flg

	#
	# Get file type.
	#
	succ_flg=`autogeili_get_file_type`
	if [ "unknown" == $succ_flg ]; then
		abs_var=`autogeili_notify "Cann't get wordsmotivate api info." $ICON_FILE`
		return 4
	fi
	readonly file_type=$succ_flg

	# 
	# Download wallpaper.
	#
	wget \
		-c $IMG_URL\_$resolution.$file_type \
		-O $WALLPAPER_DOWNLOAD_FILE.$file_type
	if [ 0 -ne $? ]; then
		abs_var=`autogeili_notify "Cann't download today wallpaper." $ICON_FILE`
		return 5
	fi

	# 
	# Detect yesterday wallpaper file type.
	#
	if [ -e $WALLPAPER_FILE.jpg ]; then
		y_file_type="jpg"
	elif [ -e $WALLPAPER_FILE.png ]; then
		y_file_type="png"
	else
		abs_var=`autogeili_notify "Cann't find yesterday wallpaper." $ICON_FILE`
		return 6
	fi

	# 
	# Replace wallpaper.
	#
	cp $WALLPAPER_FILE.$y_file_type $WALLPAPER_TMP_FILE.$y_file_type

	succ_flg=`autogeili_set_wallpaper $WALLPAPER_TMP_FILE.$y_file_type`
	if [ 0 -ne $succ_flg ]; then
		abs_var=`autogeili_notify "Cann't set wallpaper." $ICON_FILE`
		return 7
	fi
	
	rm $WALLPAPER_FILE.$y_file_type
	mv $WALLPAPER_DOWNLOAD_FILE.$file_type $WALLPAPER_FILE.$file_type

	succ_flg=`autogeili_set_wallpaper $WALLPAPER_FILE.$file_type`
	if [ 0 -ne $succ_flg ]; then
		abs_var=`autogeili_notify "Cann't set wallpaper." $ICON_FILE`
		return 8
	fi

	rm $WALLPAPER_TMP_FILE.$y_file_type

	# 
	# Update user profile
	#
	sed -i -e "s/last_update:[0-9\.]*$/last_update:$TIME_NOW_DATE/g" $CONFIG_FILE 

	return 0
}
# =============================================================================
# =============================================================================

main
exit $?
# =============================================================================
