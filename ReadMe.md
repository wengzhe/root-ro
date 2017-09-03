# 使用说明
- 主要代码为niun/root-ro @ gist.github.com
- 主要功能为让树莓派工作在只读模式下
- 使用install.sh/uninstall.sh进行安装卸载
- 使用switch.sh切换只读/读写模式
- 使用repair.sh在内核版本发生变化时进行修复

# 历史版本
- 没有做TAG，只是日志而已
- 如果需要，根据日期查找吧

## V2.0 @ 2017.9.2
- 增加runlevel脚本，可以在cmdline.txt中加入run-level=X，在系统启动后自动切换到X等级，在切换后会启动ssh服务以防无法连接
   - Raspbian支持的等级为1 3 5；2-4都会变成3；6为重启系统
   - runlevel=1为单用户模式，只有root用户可用，请允许ssh连接root
   - 由于initramfs早于init，因此依然需要重启切换是否只读
   - switch脚本可在启用读写时自动修改run-level为1，请根据提示操作

## V1.1 @ 2017.8.7
- 新增修复脚本，用于树莓派内核版本发生变化时。
   - 实测同一个镜像在1代和3代上使用的内核版本不同，可以用此脚本修复。

## V1.0 @ 2016.12.11
- 使用overlayfs在initramfs实现的Read-Only文件系统
- 使用niun/root-ro @ gist.github.com
- 使用install.sh安装，uninstall.sh恢复
- 使用switch.sh切换状态（需要重启）


翁喆
