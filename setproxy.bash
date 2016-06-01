#!/bin/bash

# exit if not root
if [ ! $(id -u) -eq 0 ]
then
	echo 'This script should be run with root permission'
	exit
fi

# variables for protocols
hp=http_proxy
hsp=https_proxy
fp=ftp_proxy
np=no_proxy


# function to set proxy in enviroment file
proxy_env()
{
	echo "SETTING ENV PROXY"
	# if None proxy then this next line is enough
	# pipe is in extended regular expr, reqs -r to enable it in GNU sed
	sed -r "/($hp|$hsp|$fp|$np).*/d" /etc/environment >> ./.temp_file_env;
	if [ ! $WIFI_PROXY = "None" ]
	then 

		HTP=http://$WIFI_PROXY/
		HTPS=https://$WIFI_PROXY/
		FP=ftp://$WIFI_PROXY/

		printf "$hp=\"$HTP\"\n$hsp=\"$HTPS\"\n$fp=\"$FP\"\n$np=\"localhost,127.0.0.1\"\n"  >> ./.temp_file_env;
	fi
	mv ./.temp_file_env /etc/environment
}
	
# setting proxy for apt in file apt.conf
proxy_apt()
{
	echo "SETTING PROXY FOR APT, MAYBE NOT REQD FOR UBUNTU\nNECESSARY FOR KUBUNTU,XUBUNTU,LINUX MINT"
	
	# rm /etc/apt/apt.conf

	if [ $WIFI_PROXY = "None" ]
	then 
		echo clearing 95proxies file 
		printf "Acquire::http::Proxy \"false\";" >> ./.temp_file_apt;
	else

		printf "Acquire::http::Proxy \"$HTP\";\nAcquire::https::Proxy \"$HTPS\";\nAcquire::ftp::Proxy \"$FP\";\n" >> ./.temp_file_apt;
		echo creating apt.conf file	
	fi
	mv ./.temp_file_apt /etc/apt/apt.conf
}

PROXY_OP=$(python3 surely_parallel.py | tail -1)
echo THE OP IS $PROXY_OP
key=$(echo $PROXY_OP | sed 's/Proxy : .*/Proxy/')
echo THE KEY IS $key

if [[ $key = 'Proxy' ]]
then
    WIFI_PROXY=$(echo $PROXY_OP | sed 's/Proxy : \(.*\)/\1/')
else
    WIFI_PROXY=None 

