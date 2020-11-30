#!/bin/sh

username=$1
password=$2

# ctcc-电信 cmcc-移动 cucc-联通 njupt-校园网
isp=$3

printf "Trying to login \n\n"

if [ "$isp" = "cmcc" ] 
then
	loginisp="@cmcc"
	printf "ISP choose to cmcc\n\n"
elif [ "$isp" = "ctcc" ]
then
	loginisp="@njxy"
	printf "ISP choose to njxy\n\n"
fi

# judge isConnected and get wlanuserip、wlanacip、wlanacname
curlStr=$(curl baidu.com)
isConnectedStr=$(echo $curlStr | grep -o "http://www.baidu.com/")
connectedStr="http://www.baidu.com/"
if [ "$isConnectedStr"x = "$connectedStr"x ]
then
	printf "ERROR: The network is connected. If you need to switch the network, please log out first! \n\n"
	exit 0
else
	loginhost=$(echo $curlStr | grep -Eo "http://[0-9A-Za-z]+\.[0-9A-Za-z]+\.[0-9A-Za-z]+\.[0-9A-Za-z]+" | grep -Eo "[0-9A-Za-z]+\.[0-9A-Za-z]+\.[0-9A-Za-z]+\.[0-9A-Za-z]+" | head -1)
	echo "loginhost: ${loginhost}"

	wlanuserip=$(echo $curlStr | grep -Eo "wlanuserip\=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | head -1)
	if [ ${#wlanuserip} -lt 4 ]
	then
		wlanuserip=$(echo $curlStr | grep -Eo "UserIP\=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | head -1)
	fi
	echo "wlanuserip: ${wlanuserip}"

	wlanacip=$(echo $curlStr | grep -Eo "wlanacip\=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | head -1)
	echo "wlanacip: ${wlanacip}"

	wlanacname=$(echo $curlStr | grep -Eo "wlanacname\=[A-Za-z0-9_\-]+" | grep -Eo "\=[A-Za-z0-9_\-]+" | head -1 | awk '{print substr($1,2)'})
	#wlanacname="${wlanacname:1}"
	echo "wlanacname: ${wlanacname}"

fi

# judge username 
if [ ${username} ]
then
	loginname=",0,${username}${loginisp}"
	echo "username：$username"
else
	printf "ERROR: unknown username \n\n"
	exit 0
fi

# judge password 
if [ ${password} ]
then
	loginpwd=${password}
	echo "username：********"
else
	printf "ERROR: unknown password \n\n"
	exit 0
fi

curl "http://${loginhost}:801/eportal/?c=ACSetting&a=Login&protocol=http:&hostname=${loginhost}&iTermType=1&wlanuserip=${wlanuserip}&wlanacip=${wlanacip}&wlanacname=${wlanacname}&mac=00-00-00-00-00-00&ip=${wlanuserip}&enAdvert=0&queryACIP=0&loginMethod=1" \
	--data-urlencode "DDDDD=$loginname" \
	--data-urlencode "upass=$loginpwd" \
	--data "R1=0&R2=0&R3=0&R6=0&para=00&0MKKey=123456&buttonClicked=&redirect_url=&err_flag=&username=&password=&user=&cmd=&Login=&v6ip="