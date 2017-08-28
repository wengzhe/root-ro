## V1.1 @ 2017.8.7

- 新增修复脚本，用于树莓派内核版本发生变化时。
   - 实测同一个镜像在1代和3代上使用的内核版本不同，可以用此脚本修复。


## V1.0 @ 2016.12.11

- 使用overlayfs在initramfs实现的Read-Only文件系统
- 使用niun/root-ro @ gist.github.com
- 使用install.sh安装，uninstall.sh恢复
- 使用switch.sh切换状态（需要重启）


翁喆
