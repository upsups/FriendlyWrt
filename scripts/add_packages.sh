#!/usr/bin/env bash

# {{ Add luci-app-diskman
(cd friendlywrt && {
	mkdir -p package/luci-app-diskman
	rm -rf package/luci-app-diskman/Makefile
	curl -fsSL https://github.com/lisaac/luci-app-diskman/raw/refs/heads/master/applications/luci-app-diskman/Makefile -o package/luci-app-diskman/Makefile
	mkdir -p package/parted
	rm -rf package/parted/Makefile
	curl -fsSL https://github.com/lisaac/luci-app-diskman/raw/refs/heads/master/Parted.Makefile -o package/parted/Makefile
})
cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_btrfs_progs=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_lsblk=y
CONFIG_PACKAGE_smartmontools=y
EOL
# }}

# {{ Add luci-theme-argon
(cd friendlywrt/package && {
	[[ -d luci-theme-argon ]] && rm -rf luci-theme-argon
	git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon
})
echo "CONFIG_PACKAGE_luci-theme-argon=y" >> configs/rockchip/01-nanopi
sed -i -e 's/function init_theme/function init_theme_backup/g' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
cat > /tmp/appendtext.txt <<EOL
function init_theme() {
	if uci get luci.themes.Argon > /dev/null 2>&1; then
		uci set luci.main.mediaurlbase="/luci-static/argon"
		uci commit luci
	fi
}
EOL
sed -i -e '/boardname=/r /tmp/appendtext.txt' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
# }}
