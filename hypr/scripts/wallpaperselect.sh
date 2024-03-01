#!/usr/bin/env sh

# set variables
ScrDir=`dirname "$(realpath "$0")"`
RofiConf="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/wallpaperselect.rasi"
wallPath="${XDG_CONFIG_HOME:-$HOME/.config}/swww/wallpapers"

# scale for monitor x res
x_monres=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
monitor_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')
x_monres=$(( x_monres * 17 / monitor_scale ))

# launch rofi menu
RofiSel=$( find -L "${wallPath}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -exec basename {} \; | sort | while read rfile
do
  echo -en "$rfile\x00icon\x1f${wallPath}/${rfile}\n"
done | rofi -show -dmenu -theme  "${RofiConf}" -select "${currentWall}")

# apply wallpaper
if [ ! -z "${RofiSel}" ] ; then
  selected="${wallPath}/${RofiSel}"

  swww img $selected \
    --transition-type "wipe" \
    --transition-duration 2

  dunstify "Changed Wallpaper to ${RofiSel}" -a "Wallpaper" -i "${wallPath}/${RofiSel}" -r 91190 -t 2200
  wal -i "${wallPath}"
  pkill waybar && waybar
  pywalfox update
fi
