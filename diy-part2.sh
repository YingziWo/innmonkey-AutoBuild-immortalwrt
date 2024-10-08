#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
set -x
pwd
ls -l

# 移除要替换的包
rm -rf feeds/packages/net/v2ray-geodata

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 添加额外插件
#git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns # 编译出错
#git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
#git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-aliddns
#git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-pushbot
#git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-jellyfin luci-lib-taskd luci-lib-xterm taskd
#git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-linkease linkease ffmpeg-remux # 编译出错

# 加入OpenClash核心
chmod -R a+x $GITHUB_WORKSPACE/preset-clash-core.sh
$GITHUB_WORKSPACE/preset-clash-core.sh

# 增加需要的功能插件
echo "
# mosdns 编译过程出错
# CONFIG_PACKAGE_luci-app-mosdns=y
# CONFIG_PACKAGE_luci-i18n-mosdns-zh-cn=y

# pushbot
# CONFIG_PACKAGE_luci-app-pushbot=y

# 阿里DDNS
# CONFIG_PACKAGE_luci-app-aliddns=y

# Jellyfin
# CONFIG_PACKAGE_luci-app-jellyfin=y

# 易有云
#CONFIG_PACKAGE_luci-app-linkease=y

# passwall
CONFIG_PACKAGE_luci-app-passwall=y
CONFIG_PACKAGE_luci-i18n-passwall-zh-cn=y

# smartdns 编译过程出错
# CONFIG_PACKAGE_luci-app-smartdns=y

# ssr-plus
#CONFIG_PACKAGE_luci-app-ssr-plus=y
#CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_IPT2Socks=y
#CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Trojan=y

" >> .config

########为增加的插件添加依赖包########
git_sparse_clone master https://github.com/kiddin9/openwrt-packages brook
git_sparse_clone master https://github.com/kiddin9/openwrt-packages chinadns-ng
git_sparse_clone master https://github.com/kiddin9/openwrt-packages dns2socks
git_sparse_clone master https://github.com/kiddin9/openwrt-packages dns2tcp
git_sparse_clone master https://github.com/kiddin9/openwrt-packages gn
git_sparse_clone master https://github.com/kiddin9/openwrt-packages hysteria
git_sparse_clone master https://github.com/kiddin9/openwrt-packages ipt2socks
git_sparse_clone master https://github.com/kiddin9/openwrt-packages microsocks
git_sparse_clone master https://github.com/kiddin9/openwrt-packages naiveproxy
#git_sparse_clone master https://github.com/kiddin9/openwrt-packages pdnsd-alt
git_sparse_clone master https://github.com/kiddin9/openwrt-packages shadowsocksr-libev
git_sparse_clone master https://github.com/kiddin9/openwrt-packages shadowsocks-rust
git_sparse_clone master https://github.com/kiddin9/openwrt-packages simple-obfs
git_sparse_clone master https://github.com/kiddin9/openwrt-packages sing-box
git_sparse_clone master https://github.com/kiddin9/openwrt-packages ssocks
git_sparse_clone master https://github.com/kiddin9/openwrt-packages tcping
git_sparse_clone master https://github.com/kiddin9/openwrt-packages trojan
git_sparse_clone master https://github.com/kiddin9/openwrt-packages trojan-go
git_sparse_clone master https://github.com/kiddin9/openwrt-packages trojan-plus
git_sparse_clone master https://github.com/kiddin9/openwrt-packages tuic-client
git_sparse_clone master https://github.com/kiddin9/openwrt-packages v2ray-core
#git_sparse_clone master https://github.com/kiddin9/openwrt-packages v2ray-geodata
git_sparse_clone master https://github.com/kiddin9/openwrt-packages v2ray-plugin
git_sparse_clone master https://github.com/kiddin9/openwrt-packages xray-core
git_sparse_clone master https://github.com/kiddin9/openwrt-packages xray-plugin
git_sparse_clone master https://github.com/kiddin9/openwrt-packages lua-neturl
git_sparse_clone master https://github.com/kiddin9/openwrt-packages redsocks2
git_sparse_clone master https://github.com/kiddin9/openwrt-packages shadow-tls
git_sparse_clone master https://github.com/kiddin9/openwrt-packages lua-maxminddb

# 修改默认IP
sed -i 's/192.168.1.1/192.168.0.2/g' package/base-files/files/bin/config_generate
cat package/base-files/files/bin/config_generate

# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
cat feeds/luci/collections/luci/Makefile

# 修改主机名
sed -i 's/ImmortalWrt/OpenWrt/g' package/base-files/files/bin/config_generate
cat package/base-files/files/bin/config_generate
pwd

# 修改系统信息
cat package/emortal/default-settings/files/99-default-settings
cp -f $GITHUB_WORKSPACE/99-default-settings package/emortal/default-settings/files/99-default-settings
cat package/emortal/default-settings/files/99-default-settings
cp -f $GITHUB_WORKSPACE/banner package/base-files/files/etc/banner

# 修改主题背景
pwd 
ls -l 
cp -f $GITHUB_WORKSPACE/argon/img/bg1.jpg feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
cp -f $GITHUB_WORKSPACE/argon/img/argon.svg feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/argon.svg
cp -f $GITHUB_WORKSPACE/argon/favicon.ico feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/favicon.ico
cp -f $GITHUB_WORKSPACE/argon/icon/android-icon-192x192.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/android-icon-192x192.png
cp -f $GITHUB_WORKSPACE/argon/icon/apple-icon-144x144.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/apple-icon-144x144.png
cp -f $GITHUB_WORKSPACE/argon/icon/apple-icon-60x60.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/apple-icon-60x60.png
cp -f $GITHUB_WORKSPACE/argon/icon/apple-icon-72x72.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/apple-icon-72x72.png
cp -f $GITHUB_WORKSPACE/argon/icon/favicon-16x16.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/favicon-16x16.png
cp -f $GITHUB_WORKSPACE/argon/icon/favicon-32x32.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/favicon-32x32.png
cp -f $GITHUB_WORKSPACE/argon/icon/favicon-96x96.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/favicon-96x96.png
cp -f $GITHUB_WORKSPACE/argon/icon/ms-icon-144x144.png feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/icon/ms-icon-144x144.png

