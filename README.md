# DdnsWithDnspod

* DDNS with dnspod.cn in LEDE(Openwrt).
* Fork自[MitchellJo/DdnsWithDnspod](https://github.com/MitchellJo/DdnsWithDnspod)的一个脚本，在其基础上添加了子域名的选择同时减少了对 `API` 不必要的调用。

## 特点说明

* 使用官方API
* 没有使用curl，转而使用wget（因为我的路由器性能比较低，没有多余空间再安装curl）
* 需要使用cron
* 理论上Openwrt也可以使用

## 使用方法

### 更新wget，因为LEDE自带wget不完整，无法使用https

```bash
opkg install wget
reboot
```
### 配置 DdnsWithDnspod.sh

把 `DdnsWithDnspod.sh` 放到 `/etc/hotplug.d/iface` 并将其改名为 `[int]-[name]` 比如 `99-DdnsWithDnspod` 系统会按照前面数字的顺序执行脚本，`-` 之后的名字随意

给予执行权限 `chmod 755 99-DdnsWithDnspod`

### 替换下面账号信息为自己的

```bash
LOGIN_TOKEN="xxxxx,yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
DOMAIN="youdomain.xx"
SUB_DOMAIN="@"
```

其中 `LOGIN_TOKEN` 可用从[DNSPOD 密钥管理](https://console.dnspod.cn/account/token)获取

## 添加任务到 cron

如果你要将其添加到 `cron` 执行，请先删除 [L51-L52](https://github.com/blackyau/DdnsWithDnspod/blob/master/DdnsWithDnspod.sh#L51-L52) 行代码，再进行以下操作，否则脚本讲无法正常运行

在luci页面的Scheduled Tasks中添加下面这样的信息
```bash
*/10 * * * * sh /root/DdnsWithDnspod.sh >> /root/DdnsWithDnspod.log
```
重启一下路由器

如果每隔10min可以看到/root/DdnsWithDnspod.log有更新，说明DDNS已经正常运行。
