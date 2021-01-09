#!/bin/sh
#
# Bash script to check for version of BigFix client
#
#

targetVersion="9.5.16.90"
dateNow=$(date +"%Y%m%d")
fileName=${dateNow}".log"
echo $HOSTNAME
if [ -n "$(uname -a | grep el7)" ]; then
	OS_RELEASE_VERS="7"
	if [[ -f "/var/opt/BESClient/besclient.config" ]]; then
		#check version
		VERSION="$(cat /var/opt/BESClient/besclient.config | grep LastClientVersion | cut -d"=" -f2 | xargs)"
		if [[ $targetVersion == $VERSION ]]; then
			echo "Good version:" $VERSION
			if [[ -f "/var/opt/BESClient/__BESData/__Global/Logs/${fileName}"  ]]; then
				messages="$(tail -20 /var/opt/BESClient/__BESData/__Global/Logs/${fileName})"
				if [[ $messages == *"GetURL failed"* ]]; then
					echo "Connection problem detected. Removing installation"
					systemctl stop besclient
					previousPid=$!
					wait $previousPid
					echo "Service stopped"
					besAgent="$(rpm -qa | grep -i BESAgent)"
					rpm -e ${besAgent}
					previousPid=$!
                                        wait $previousPid
					echo "rpm removed"
					rm -rf /etc/opt/BESClient 
					previousPid=$!
                                        wait $previousPid
					rm -rf /opt/BESClient 
					previousPid=$!
                                        wait $previousPid
					rm -rf /tmp/BES 
					previousPid=$!
                                        wait $previousPid
					rm -rf /var/opt/BESClient 
					previousPid=$!
                                        wait $previousPid
					rm -rf /var/opt/BESCommon 
					previousPid=$!
                                        wait $previousPid
					echo "Installation removed"
					echo "Installing client"
					bash /repos/ecmo/ecmo-linux.sh
					#mkdir -p /etc/opt/BESClient
					#previousPid=$!
                                        #wait $previousPid
					#yum install -y BESAgent-9.5.16.90-rhe6.x86_64.rpm
					#previousPid=$!
                                        #wait $previousPid
					#cp /repos/ecmo/besclient.config /var/opt/BESClient/
					#previousPid=$!
                                        #wait $previousPid
					#cp /repos/ecmo/actionsite.afxm /etc/opt/BESClient/
					#previousPid=$!
                                        #wait $previousPid
					#cp /repos/ecmo/dcid.skey /opt/BESClient/bin/
					#previousPid=$!
                                        #wait $previousPid
					#echo "Starting service"
					#systemctl start besclient
					#previousPid=$!
                                        #wait $previousPid
					#echo "Service started"
					echo "Checking logs for connection status"				
				else
					echo "No connection problem detected"
				fi
			else
				echo "No log"
			fi
				#systemctl restart besclient
                        	#previousPid=$!
                        	#wait $previousPid
                        	#echo "Service restarted"
		else
			echo "Bad version"
			#stat /krug
                        systemctl restart besclient
			previousPid=$!
                        wait $previousPid
			NEW_VERSION="$(cat /var/opt/BESClient/besclient.config | grep LastClientVersion | cut -d"=" -f2 | xargs)"
                        echo "New Version:" $NEW_VERSION
		fi	
	else
		echo "client not installed"
		bash /repos/ecmo/ecmo-linux.sh
		#echo "Installing client"
                #mkdir -p /etc/opt/BESClient
                #previousPid=$!
                #wait $previousPid
                #yum install -y BESAgent-9.5.16.90-rhe6.x86_64.rpm
                #previousPid=$!
                #wait $previousPid
                #cp /repos/ecmo/besclient.config /var/opt/BESClient/                
                #previousPid=$!
                #wait $previousPid
                #cp /repos/ecmo/actionsite.afxm /etc/opt/BESClient/               
                #previousPid=$!
                #wait $previousPid
                #cp /repos/ecmo/dcid.skey /opt/BESClient/bin/         
                #previousPid=$!
                #wait $previousPid
                #echo "Starting service"
                #systemctl start	besclient
                #previousPid=$!
                #wait $previousPid
                #echo "Service started"
                echo "Checking logs for	connection status"
	fi
elif [ -n "$(uname -a | grep el6)" ]; then
        OS_RELEASE_VERS="6"
        if [[ -f "/var/opt/BESClient/besclient.config" ]]; then
		#check version
		VERSION="$(cat /var/opt/BESClient/besclient.config | grep LastClientVersion | cut -d"=" -f2 | xargs)"
		if [[ $targetVersion == $VERSION ]]; then	
			echo "Good version:" $VERSION
		else
			echo "Bad version:" $VERSION
			#stat /krug
			systemctl restart besclient
		fi
	else
		echo "not installed"
		stat /krug
	fi
elif [ -n "$(uname -a | grep el8)" ]; then
        OS_RELEASE_VERS="8"
        if [[ -f "/var/opt/BESClient/besclient.config" ]]; then
		#check version
		VERSION="$(cat /var/opt/BESClient/besclient.config | grep LastClientVersion | cut -d"=" -f2 | xargs)"
		if [[ $targetVersion == $VERSION ]]; then	
			echo "Good version:" $VERSION
		else
			echo "Bad version"	
			stat /krug
		fi
	else
		echo "not installed"
		stat /krug
	fi
else
        OS_RELEASE_VERS="0"
fi
