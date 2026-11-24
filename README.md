# Siflower SF19A2890/SF19A2890S/SF19A2890S1/SF19A2890S2 OpenWrt1806_SDK
# 矽昌WiFi5方案开源SDK,基于openwrt18.06 + linux 4.14.90内核版本
# 合作联系 irving.luo@siflower.com.cn

## CPE1250S (QMODEM / HF25QH128AE)

- Board alias: `a28_cpe1250s`
- Defconfig: `openwrt-18.06/target/linux/siflower/sf19a28_cpe1250s_fullmask_def.config`
- NOR: HuaHong HF25QH128AE (JEDEC `A1 40 18`, 16 MiB), added to kernel and U-Boot ID tables.
- Modem: Quectel RG200U-CN managed by QMODEM (`ONLY-RG200U` feed); data via ECM (`usb0`), AT only on `ttyUSB2`.
- Local build: `cd openwrt-18.06 && ./make.sh a28_cpe1250s rel`
- Cloud build: dispatch the `Build CPE1250S` workflow; the artifact is `openwrt1806_*_a28_cpe1250s_*.bin`.
