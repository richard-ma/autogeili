#!/usr/bin/env bash

# =============================================================================
# File Name: autogeili
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

if [[ ! $1 ]] || [[ ! $1 =~ ^[0-9]{4}\.[0-9]{1,2}\.[0-9]{1,2} ]];then
    IMG_DATE_PREFIX=$TIME_NOW_DATE
else
    IMG_DATE_PREFIX=$1
fi

readonly IMG_MONTH_PREFIX=`echo $IMG_DATE_PREFIX | cut -d '.' -f -2`

readonly CONFIG_FILE=~/.autogeilirc
readonly CONFIG_DIR=~/.autogeili

readonly WALLPAPER_TMP_FILE=$CONFIG_DIR/tmp_wallpaper
readonly WALLPAPER_DOWNLOAD_FILE=$CONFIG_DIR/down_wallpaper

readonly DOMAIN_URL=wordsmotivate.me
readonly IMG_PREFIX_URL=img
readonly API_PREFIX_URL=api
readonly API_SUFFIX_URL=WallpaperFormat.php
readonly IMG_SUFFIX_URL=$IMG_MONTH_PREFIX/$IMG_DATE_PREFIX
readonly IMG_URL=http://$IMG_PREFIX_URL.$DOMAIN_URL/$IMG_SUFFIX_URL
readonly API_URL=http://$API_PREFIX_URL.$DOMAIN_URL/$API_SUFFIX_URL

readonly ICON_FILE=/usr/share/autogeili/autogeili-icon.png
readonly GNOME_VERSION=`gnome-shell --version | awk '{print $3}' | awk 'BEGIN{FS="."}{print $1}'`
readonly WALLPAPER_FILE_PREFIX=$CONFIG_DIR/$IMG_DATE_PREFIX

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
	today_date=$IMG_DATE_PREFIX

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
	IMG_TYPE=`curl -m 5 $API_URL | awk 'BEGIN{FS=":"}{print $2}' | awk 'BEGIN{FS="["}{print $1}' | tr '[A-Z]' '[a-z]'`
	[[ ! $IMG_TYPE ]] && [[ -f $CONFIG_DIR/format.api ]] && IMG_TYPE=`cat $CONFIG_DIR/format.api`
	[[ ! $IMG_TYPE ]] && echo "unknown" && exit
	if [ $IMG_TYPE != "jpg" ] && [ $IMG_TYPE != "png" ]; then
		IMG_TYPE=`cat $CONFIG_DIR/format.api`
	fi
	if [ $IMG_TYPE == "jpg" ] || [ $IMG_TYPE == "png" ]; then
		echo $IMG_TYPE | tee $CONFIG_DIR/format.api
	else
		echo "unknown"
	fi
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

	if [ $GNOME_VERSION == "3" ];then
		gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper"
		echo 0
		return
	else
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
	fi
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
        screen_all=(`xrandr|grep \*|awk '{print $1}'|awk 'BEGIN{FS="x"}{print $1,$2}'`)
	screen_width=${screen_all[0]}
        screen_height=${screen_all[1]}

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
		-P $CONFIG_DIR
	if [ 0 -ne $? ]; then
		abs_var=`autogeili_notify "Cann't download today wallpaper." $ICON_FILE`
		return 5
	fi

	succ_flg=`autogeili_set_wallpaper $WALLPAPER_TMP_FILE.$y_file_type`
	if [ 0 -ne $succ_flg ]; then
		abs_var=`autogeili_notify "Cann't set wallpaper." $ICON_FILE`
		return 7
	fi

	WALLPAPER_FILE="${WALLPAPER_FILE_PREFIX}_${resolution}.$file_type"
	succ_flg=`autogeili_set_wallpaper $WALLPAPER_FILE`
	if [ 0 -ne $succ_flg ]; then
		abs_var=`autogeili_notify "Cann't set wallpaper." $ICON_FILE`
		return 8
	fi

	# 
	# Update user profile
	#
	sed -i -e "s/^last_update:[0-9\.]*$/last_update:$IMG_DATE_PREFIX/g" $CONFIG_FILE 

	abs_var=`autogeili_notify "Update complete." $ICON_FILE`
	return 0
}
# =============================================================================
# =============================================================================

while getopts :d: option
do
    case "$option" in
        d)
            abs_var=`autogeili_notify "still working." $ICON_FILE`
            sleep $OPTARG
            ;;
        *)
            abs_var=`autogeili_notify "Invalid option" $ICON_FILE`
            exit -1
            ;;
    esac
done

main
exit $?
# =============================================================================
