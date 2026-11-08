#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

FEEDS_PATH="./feeds"
PACKAGE_PATH="./package"

#修补命令统一入口：FIX <名称> <守卫目录> <命令...>
#守卫目录不存在时直接跳过，保证在 bash -e 下不中断
FIX() {
	local NAME=$1
	local GUARD=$2
	shift 2

	[ -d "$GUARD" ] || return 0

	echo " "
	if "$@"; then
		echo "$NAME has been fixed!"
	else
		echo "$NAME fix failed; continuing!"
	fi
}

#设置菜单排序：SET_MENU_ORDER <名称> <menu.d文件> <菜单键> <排序值>
SET_MENU_ORDER() {
	local NAME=$1
	local FILE=$2
	local KEY=$3
	local ORDER=$4

	if [ ! -f "$FILE" ]; then
		echo "$NAME not found: $FILE"
		return 0
	fi

	if ! jq -e --arg KEY "$KEY" 'has($KEY)' "$FILE" >/dev/null 2>&1; then
		echo "$NAME key not found: $KEY"
		return 0
	fi

	if jq --arg KEY "$KEY" --argjson ORDER "$ORDER" '.[$KEY].order = $ORDER' "$FILE" > "$FILE.tmp"; then
		mv -f "$FILE.tmp" "$FILE"
		echo "$NAME order set to $ORDER"
	else
		rm -f "$FILE.tmp"
		echo "$NAME order set failed; continuing!"
	fi
}

#设置菜单标题：SET_MENU_TITLE <名称> <menu.d文件> <菜单键> <标题>
SET_MENU_TITLE() {
	local NAME=$1
	local FILE=$2
	local KEY=$3
	local TITLE=$4

	if [ ! -f "$FILE" ]; then
		echo "$NAME not found: $FILE"
		return 0
	fi

	if ! jq -e --arg KEY "$KEY" 'has($KEY)' "$FILE" >/dev/null 2>&1; then
		echo "$NAME key not found: $KEY"
		return 0
	fi

	if jq --arg KEY "$KEY" --arg TITLE "$TITLE" '.[$KEY].title = $TITLE' "$FILE" > "$FILE.tmp"; then
		mv -f "$FILE.tmp" "$FILE"
		echo "$NAME title set to $TITLE"
	else
		rm -f "$FILE.tmp"
		echo "$NAME title set failed; continuing!"
	fi
}

#fork: 使用 argon 默认配色，不应用字体和颜色修补

#fork: 不修改 aurora 菜单式样
#FIX "theme-aurora" "$PACKAGE_PATH/luci-app-aurora-config" find \
#	"$PACKAGE_PATH/luci-app-aurora-config/root/usr/share/aurora/" -type f -name '*.template' -exec sed -i \
#	"s/nav_type '.*'/nav_type 'dropdown'/g; s/struct_radius_base '.*'/struct_radius_base '0.125rem'/g" {} +

#fork: 不修改 vantage 进度条标签字体
#FIX "theme-vantage" "$PACKAGE_PATH/luci-theme-vantage" sed -i \
#	-e '/^\/\* progress bars: thin track/,$ { /^\.cbi-progressbar::before {/,/^}/ { s/^[[:space:]]*font: 500 var(--fs-micro)\/1\.2 var(--mono);/\tfont: inherit; line-height: normal;/; } }' \
#	"$PACKAGE_PATH/luci-theme-vantage/luci-theme-vantage/htdocs/luci-static/vantage/vantage.css"

#调整终端菜单位置：重启之后、aurora主题设计之前
FIX "ttyd-menu" "$FEEDS_PATH/luci/applications/luci-app-ttyd" sed -i \
	'/"admin\/system\/ttyd": {/,/"action"/ s/"title": "Terminal",/&\n\t\t"order": 95,/' \
	"$FEEDS_PATH/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json"

#修改mini-diskmanager菜单位置
FIX "mini-diskmanager" "$PACKAGE_PATH/luci-app-mini-diskmanager" sed -i "s/services/system/g" \
	"$PACKAGE_PATH/luci-app-mini-diskmanager/luci-app-mini-diskmanager/root/usr/share/luci/menu.d/luci-app-mini-diskmanager.json"

#修改natmapt菜单位置
FIX "natmapt" "$PACKAGE_PATH/luci-app-natmapt" sed -i "s/network/services/g" \
	"$PACKAGE_PATH/luci-app-natmapt/root/usr/share/luci/menu.d/luci-app-natmap.json"

#调整服务菜单顺序：Momo、Nikki 上移，NATMap 后移，rtp2httpd 前移
SET_MENU_ORDER "momo-menu" "$PACKAGE_PATH/OpenWrt-momo/luci-app-momo/root/usr/share/luci/menu.d/luci-app-momo.json" \
	"admin/services/momo" 61
SET_MENU_ORDER "nikki-menu" "$PACKAGE_PATH/OpenWrt-nikki/luci-app-nikki/root/usr/share/luci/menu.d/luci-app-nikki.json" \
	"admin/services/nikki" 62
SET_MENU_ORDER "natmap-menu" "$PACKAGE_PATH/luci-app-natmapt/root/usr/share/luci/menu.d/luci-app-natmap.json" \
	"admin/services/natmap" 63
SET_MENU_ORDER "rtp2httpd-menu" "$PACKAGE_PATH/rtp2httpd/openwrt-support/luci-app-rtp2httpd/root/usr/share/luci/menu.d/luci-app-rtp2httpd.json" \
	"admin/services/rtp2httpd" 64
SET_MENU_ORDER "msd-lite-menu" "$FEEDS_PATH/luci/applications/luci-app-msd_lite/root/usr/share/luci/menu.d/luci-app-msd_lite.json" \
	"admin/services/msd_lite" 65
SET_MENU_ORDER "omcproxy-menu" "$FEEDS_PATH/luci/applications/luci-app-omcproxy/root/usr/share/luci/menu.d/luci-app-omcproxy.json" \
	"admin/services/omcproxy" 66
SET_MENU_ORDER "upnp-menu" "$PACKAGE_PATH/packages/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json" \
	"admin/services/upnp" 67

#调整系统菜单顺序：主题入口后移，重启排在主题之后
SET_MENU_ORDER "aurora-menu" "$PACKAGE_PATH/luci-app-aurora-config/root/usr/share/luci/menu.d/luci-app-aurora.json" \
	"admin/system/aurora" 91
SET_MENU_ORDER "footstrap-menu" "$PACKAGE_PATH/luci-theme-footstrap/luci-theme-footstrap/root/usr/share/luci/menu.d/luci-theme-footstrap.json" \
	"admin/system/footstrap" 92
SET_MENU_TITLE "footstrap-menu" "$PACKAGE_PATH/luci-theme-footstrap/luci-theme-footstrap/root/usr/share/luci/menu.d/luci-theme-footstrap.json" \
	"admin/system/footstrap" "Footstrap 主题设置"
SET_MENU_ORDER "reboot-menu" "$FEEDS_PATH/luci/modules/luci-mod-system/root/usr/share/luci/menu.d/luci-mod-system.json" \
	"admin/system/reboot" 93
