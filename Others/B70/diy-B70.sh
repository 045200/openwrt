#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.77.1/g' package/base-files/files/bin/config_generate

#删除默认密码
sed -i "/CYXluq4wUazHjmCDBCqXF/d" package/default-settings/files/zzz-default-settings

#设置FAT为utf8编码
find target/linux -path "target/linux/*/config-*" | xargs -i sed -i '$a CONFIG_ACPI=y\nCONFIG_X86_ACPI_CPUFREQ=y\n \
CONFIG_NR_CPUS=128\nCONFIG_FAT_DEFAULT_IOCHARSET="utf8"' {}

#默认主题改为argon, lienol的主题设置别碰, 大坑
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci/Makefile

# 网络接口适配
sed -i ':a;N;$!ba;s/hc5962/&|\\\n\t&-spi/1' ./target/linux/ramips/mt7621/base-files/etc/board.d/02_network

cat >> ./target/linux/ramips/image/mt7621.mk <<EOF
define Device/hc5962-spi
  DTS := HC5962-SPI
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_VENDOR := HiWiFi
  DEVICE_TITLE := HC5962-SPI
  DEVICE_PACKAGES := kmod-mt7603 kmod-mt76x2 wpad-openssl
endef
TARGET_DEVICES += hc5962-spi
EOF
sed -i 's/^[ \t]*//g' ./target/linux/ramips/image/mt7621.mk

#设置32m闪存
#sed -i 's/0xfb0000/0x1fb0000/g' target/linux/ramips/dts/HC5962-SPI.dts
#sed -i 's/fw_size_16M/fw_size_32M/g' target/linux/ramips/image/mt7621.mk

# 默认turboacc开启DNS Caching功能
#sed -i -r "s/(dns_caching )'0'/\1'1'/1" package/feeds/custom/luci-app-turboacc/root/etc/config/turboacc 
# 修复DHCP服务, 从5.4内核改回4.14内核的resolv.conf路径
sed -i 's|resolv.conf.d/resolv.conf.auto|resolv.conf.auto|g' `grep -l resolv.conf.d package/feeds/custom/*/root/etc/init.d/*`
# custom插件汉化
mv package/feeds/custom/luci-app-turboacc/po/zh_Hans package/feeds/custom/luci-app-turboacc/po/zh-cn
