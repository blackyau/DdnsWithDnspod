#!/bin/sh
#Program:
#	Used for ddns with DNSPod in LEDE.

LOGIN_TOKEN="xxxxx,yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
DOMAIN="youdomain.xx"
SUB_DOMAIN="@"

wlan_ip=""
record_ip=""
record_id=""
record_line_id=""

log_info()
{
	_date=$(date)
	echo -e "${_date}\t$1"
}

get_wlan_ip()
{
	wlan_ip=$(wget -q -O- http://ddns.oray.com/checkip|grep -Eo '\d+\.\d+\.\d+\.\d+')
}

get_record_info()
{
	record_info=$(wget -q -O- --no-check-certificate --post-data "format=json&offset=0&length=1&login_token=${LOGIN_TOKEN}&domain=${DOMAIN}&sub_domain=${SUB_DOMAIN}" https://dnsapi.cn/Record.List)
	record_info=$(echo "${record_info}"|grep -Eo 'records.*\}\]')
	record_ip=$(echo "${record_info}"|grep -Eo '\d+\.\d+\.\d+\.\d+')
	record_id=$(echo "${record_info}"|grep -Eo '\"id\":\"\d+\"'|grep -Eo '\d+')
	record_line_id=$(echo "${record_info}"|grep -Eo '\"line_id\":\"\d+\"'|grep -Eo '\d+')
}

update_record()
{
	if [ "${wlan_ip}" = "${record_ip}" ]; then
		log_info "Record is up to date. IP:${record_ip}"
		logger -t DdnsWithDnspod -s "Record is up to date. IP:${record_ip}" # Print log
	else
		result=$(wget -q -O- --no-check-certificate --post-data "format=json&login_token=${LOGIN_TOKEN}&domain=${DOMAIN}&sub_domain=${SUB_DOMAIN}&record_id=${record_id}&record_line_id=${record_line_id}&value=${wlan_ip}" https://dnsapi.cn/Record.Ddns)
		log_info "${result}"
		logger -t DdnsWithDnspod -s "${result}" # Print log
	fi
}

main()
{
	get_wlan_ip
	get_record_info
	update_record
	exit 0
}

if [ "${INTERFACE}" = "wan" ]; then # WAN status change
	if [ "${ACTION}" = "ifup" ]; then # Interface up
		logger -t DdnsWithDnspod -s "Start" # Print log
		main
	fi
fi
