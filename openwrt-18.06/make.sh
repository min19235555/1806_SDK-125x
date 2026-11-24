#!/bin/bash
#$1 should be p10 or p20

board=a28_evb
imgtype=rel

#$1 p10 p10m p20 86v clean default p10m
if [ -n "$1" ]; then
	board=$1
fi

#$2 shoule be auto/flash/rel  default rel
if [ -n "$2" ]; then
	imgtype=$2
fi


git branch > /dev/null 2>&1
if [ ! $? -eq 0 ] ; then
	echo "dose not exist git base"
	tag="0.0"
	branch="default"
else
	# branch=`git branch  -r | grep "\->" |awk -F "/" 'END{print $NF}'`
	local_branch_name=`git branch -vv |grep "*" |awk '{print $2}'`
	# echo "local branch name $local_branch_name"
	if [ "$local_branch_name" = "(no" ]; then
		echo "branch set fail no local branch"
		exit 1
	fi

	branch=`git branch -vv |grep "*" | awk -F "[][]" '{print $2}'| awk -F "[/:]" '{print $2}'`
	echo "branch is $branch"

	# handle release branch case release branch name is not release!!!
	is_rep_release=$(echo $branch | grep "release.rep")
	isrelease=$(echo $branch | grep "release")

	if [ "$is_rep_release" != "" ];then
		branch="release.rep"
	elif [ "$isrelease" != "" ];then
		branch="release"
	fi
# need to use tag for rep
#	is_rep_board=$(echo $board | grep "rep")

#	if [ "$is_rep_board" != "" ];then
#		tag=`git tag  |  grep "${branch}.rep-" | sort -V | awk 'END{print}'`
#	else
#${branch}-2 is specailly for release2.0.0 branch
#		tag=`git tag  |  grep "${branch}-2" | sort -V | awk 'END{print}'`
#	fi


	if [ ! -n "$tag" ] ;then
		#compatible with old version
		tag_commit=`git rev-list --tags --max-count=1`
		tag=`git describe --tags $tag_commit`
		version=$tag
	else
		version=`printf "$tag" | awk -F "[-]" '{print $2}'`
	fi
	echo "version is $version"
	tag_commit=`git show $tag|grep ^commit | awk '{print substr($2,0,7)}'`
	echo "tag commit $tag_commit"
	last_commit=`git rev-parse --short HEAD`
	echo "last commit $last_commit"

	if [ $tag_commit != ${last_commit:0:7} ]; then
		commit_suffix=$last_commit
	fi
fi


case ${board} in
	a28_evb)
		target_board=target/linux/siflower/sf19a28_evb_fullmask_def.config
		;;
	a28_ac28)
		target_board=target/linux/siflower/sf19a28_ac28_fullmask_def.config
		;;
	a28_ac28nand)
		target_board=target/linux/siflower/sf19a28_ac28nand_fullmask_def.config
		;;
	a28_ac28s)
		target_board=target/linux/siflower/sf19a28_ac28s_fullmask_def.config
		;;
	a28_phy)
		target_board=target/linux/siflower/sf19a28_phy_fullmask_def.config
		;;
	a28_yts)
		target_board=target/linux/siflower/sf19a28_yts_fullmask_def.config
		;;
	a28_bpi)
		target_board=target/linux/siflower/sf19a28_bpi_fullmask_def.config
		;;
	a28_bpi_luci2)
		target_board=target/linux/siflower/sf19a28_bpi_luci2_fullmask_def.config
		;;
	a28_bpi_luci2_neutral)
		target_board=target/linux/siflower/sf19a28_bpi_luci2_neutral_fullmask_def.config
		;;
	a28_bpi_luci2_siflower)
		target_board=target/linux/siflower/sf19a28_bpi_luci2_siflower_fullmask_def.config
		;;
	a28_router_1211)
		target_board=target/linux/siflower/sf19a28_router_1211_fullmask_def.config
		;;
	a28_cpe1250s)
		target_board=target/linux/siflower/sf19a28_cpe1250s_fullmask_def.config
		;;
	clean)
		echo "clean build enviroment"
		echo "delete build dir "
		rm -rf build_dir
		echo "delete tmp"
		rm -rf tmp
		echo "delete board"
		rm .board
		exit 1
		;;
	*)
		echo "error arg"
		exit 1 # Command to come out of the program with status 1
		;;
esac

config_profile=`grep "^CONFIG_TARGET_siflower_" ${target_board} | head -1 | awk -F "[_=]" '{print $4" "$5}'`
read chip chip_ver <<< "${config_profile}"

echo "build board is $board chip ${chip}_${chip_ver} imgtype $imgtype"

if [ -n "$commit_suffix" ]; then
	prefix=openwrt1806_${branch}_${board}_${chip}_${chip_ver}_${imgtype}_${version}_${commit_suffix}
else
	prefix=openwrt1806_${branch}_${board}_${chip}_${chip_ver}_${imgtype}_${version}
fi

# The firmware image is written by OpenWrt into bin/targets/<target>/<subtarget>/
# and its name embeds the dist name, the version and (optionally) the device
# profile, so it is resolved by glob instead of by a hard coded path.
target_glob="bin/targets/siflower/*/*squashfs-sysupgrade.bin"

echo "prefix is ${prefix}"
#set up version.mk
rm include/siwifi_version.mk
echo "VERSION_DIST:=SiWiFi" >> include/siwifi_version.mk
echo 'VERSION_NICK:=$(PROFILE)' >> include/siwifi_version.mk
echo "VERSION_NUMBER:=${prefix}" >> include/siwifi_version.mk

sed -e '12cVERSION_NUMBER:='${prefix}'' include/siwifi_version.mk > tmp_version

sed -e '14cVERSION_NUMBER:='${prefix}'' tmp_version > include/siwifi_version.mk

rm tmp_version

echo "set openwrt version"


echo "set up board $target_config"

if [ "$imgtype" = "flash" ]; then
	target_board=target/linux/siflower/${chip}_p10_${chip_ver}_flash.config
fi

if [ -f .board ] && [ "$imagetype" != "auto" ]; then
	cmp_reselt=`cmp $target_board .config`
	if [ -n "$cmp_reselt" ]; then
		echo "board change, clean build enviroment"
		rm -rf build_dir
		rm -rf tmp
		cp $target_board .config
	fi
else
	cp $target_board .config
fi

rm -f ${target_glob}

case ${imgtype} in
	auto)
		echo "CONFIG_PACKAGE_autotest=y" >> .config
		echo "build auto"
		;;

	flash)
		echo "build flash"
		;;
	rel)
		echo "build release"
		;;
	*)
		echo "imgtype error arg"
		exit 1 # Command to come out of the program with status 1
		;;
esac

# Resolve the package configuration before building.
#
# include/toplevel.mk only *compares* .config against the kconfig resolution
# (conf --defconfig=tmp/.config) and prints "your configuration is out of
# sync" when they differ - it never writes the resolved config back. A def
# config copied verbatim therefore keeps every "+dependency" package
# unselected, because kconfig "select" is what turns a "+pkg" entry in a
# package DEPENDS line into CONFIG_PACKAGE_pkg=y.
#
# qmodem declares its whole dependency tree that way (kmod-usb2, kmod-usb3,
# kmod-usb-serial*, kmod-usb-net*, coreutils, jq, ...) and luci-app-qmodem-next
# expands it into the ipkg Depends field, so the image assembly step died with
# "satisfy_dependencies_for: Cannot satisfy the following dependencies for
# luci-app-qmodem-next". Running "make defconfig" re-resolves .config so the
# select chain is applied.
echo "resolving package configuration (make defconfig)"
make defconfig
defconfig_rc=$?
if [ $defconfig_rc -ne 0 ]; then
	echo "defconfig failed: make exit ${defconfig_rc}"
	exit $defconfig_rc
fi

make package/base-files/clean
make package/network/services/hostapd/clean
make -j${JOBS:-32} ${MAKE_EXTRA_FLAGS} V=s
make_rc=$?

if [ $make_rc -ne 0 ]; then
	echo "build failed: make exit ${make_rc}"
	exit $make_rc
fi

target_bin=$(ls -1 ${target_glob} 2>/dev/null | head -n 1)
if [ -n "$target_bin" ] && [ -f "$target_bin" ]; then
	cp "$target_bin" ${prefix}.bin
	echo "build ok: ${target_bin} -> ${prefix}.bin"
else
	echo "build fail, don't get target_bin"
	exit 1
fi

echo "build end"
