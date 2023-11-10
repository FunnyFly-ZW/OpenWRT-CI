#!/bin/bash

#Design Theme
git clone --depth=1 --single-branch --branch $(echo $OWRT_URL | grep -iq "lede" && echo "main" || echo "js") https://github.com/gngpp/luci-theme-design.git
git clone --depth=1 --single-branch https://github.com/gngpp/luci-app-design-config.git
#Argon Theme
git clone --depth=1 --single-branch --branch $(echo $OWRT_URL | grep -iq "lede" && echo "18.06" || echo "master") https://github.com/jerrykuku/luci-theme-argon.git
git clone --depth=1 --single-branch --branch $(echo $OWRT_URL | grep -iq "lede" && echo "18.06" || echo "master") https://github.com/jerrykuku/luci-app-argon-config.git

#PassWall
git clone --depth=1 --single-branch https://github.com/xiaorouji/openwrt-passwall.git
git clone --depth=1 --single-branch https://github.com/xiaorouji/openwrt-passwall2.git
git clone --depth=1 --single-branch https://github.com/xiaorouji/openwrt-passwall-packages.git
#OpenClash
git clone --depth=1 --single-branch --branch "dev" https://github.com/vernesong/OpenClash.git
#HelloWorld
#git clone --depth=1 --single-branch --branch "main" https://github.com/fw876/helloworld.git

#MosDNS
git clone --depth=1 --single-branch https://github.com/sbwml/luci-app-mosdns.git
git clone --depth=1 --single-branch https://github.com/sbwml/v2ray-geodata.git
#SmartDNS
#sed -i 's/1.2023.42/1.2023.43/g' feeds/packages/net/smartdns/Makefile
#sed -i 's/ed102cda03c56e9c63040d33d4a391b56491493e/60a3719ec739be2cc1e11724ac049b09a75059cb/g' feeds/packages/net/smartdns/Makefile
#sed -i 's/^PKG_MIRROR_HASH/#&/' feeds/packages/net/smartdns/Makefile
git clone  --depth=1 --single-branch --branch "lede" https://github.com/pymumu/luci-app-smartdns.git

#Home Proxy
if [[ $OWRT_URL == *"immortalwrt"* ]] ; then
  git clone --depth=1 --single-branch --branch "dev" https://github.com/immortalwrt/homebridger.git
fi

#修复OpenClash报错
sed -i "194s#/usr/lib/lua/luci/http.lua#/usr/share/ucode/luci/http.uc#" ./OpenClash/luci-app-openclash/root/etc/uci-defaults/luci-openclash

#预置Openclash内核和GEO数据
export CORE_VER=https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/core_version
export CORE_TUN=https://github.com/vernesong/OpenClash/raw/core/dev/premium/clash-linux
export CORE_DEV=https://github.com/vernesong/OpenClash/raw/core/dev/dev/clash-linux
export CORE_MATE=https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux

export CORE_TYPE=$(echo $OWRT_TARGET | grep -Eiq "64|86" && echo "amd64" || echo "arm64")
export TUN_VER=$(curl -sfL $CORE_VER | sed -n "2{s/\r$//;p;q}")

export GEO_MMDB=https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb
export GEO_SITE=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat
export GEO_IP=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat
export META_DB=https://github.com/MetaCubeX/meta-rules-dat/raw/release/geoip.metadb

cd ./OpenClash/luci-app-openclash/root/etc/openclash

curl -sfL -o ./Country.mmdb $GEO_MMDB
curl -sfL -o ./GeoSite.dat $GEO_SITE
curl -sfL -o ./GeoIP.dat $GEO_IP
curl -sfL -o ./GeoIP.metadb $META_DB

mkdir ./core && cd ./core

curl -sfL -o ./tun.gz "$CORE_TUN"-"$CORE_TYPE"-"$TUN_VER".gz
gzip -d ./tun.gz && mv ./tun ./clash_tun

curl -sfL -o ./meta.tar.gz "$CORE_MATE"-"$CORE_TYPE".tar.gz
tar -zxf ./meta.tar.gz && mv ./clash ./clash_meta

curl -sfL -o ./dev.tar.gz "$CORE_DEV"-"$CORE_TYPE".tar.gz
tar -zxf ./dev.tar.gz

chmod +x ./clash* ; rm -rf ./*.gz
