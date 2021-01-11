#!/bin/sh
#
# Bash script to check for version of BigFix client,
# detect operation, install target client#
#

_target_version="9.5.16.90"
_date_now=$(date +"%Y%m%d")
_date_now_file_name=${_date_now}".log"

check_hostname () {
	_host="$(echo $HOSTNAME)"
	echo $_host
}

check_os_version () {
	_uname_results="$(uname -a)"
	echo $_uname_results
}

check_installed_bigfix_version () {
	_installed_version="$(cat /var/opt/BESClient/besclient.config | grep LastClientVersion | cut -d"=" -f2 | xargs)"
	echo $_installed_version
}

check_bigfix_logs () {
	_log_messages="$(tail -20 /var/opt/BESClient/__BESData/__Global/Logs/${fileName})"
}

stop_bigfix_service () {
	systemctl stop besclient
	_previous_pid=$!
	wait $_previous_pid
	echo "Service stopped"
}

start_bigfix_service () {
	systemctl start besclient
	_previous_pid=$!
	wait $_previous_pid
	echo "Service started"
}

restart_bigfix_service () {
	systemctl stop besclient
	_previous_pid=$!
	wait $_previous_pid
	echo "Service restarted"
}

remove_bigfix_rpm () {
	besAgent="$(rpm -qa | grep -i BESAgent)"
	rpm -e ${besAgent}
	_previous_pid=$!
	wait $_previous_pid
	echo "rpm removed"
}

remove_installed_bigfix_directories () {
	rm -rf /etc/opt/BESClient
	_previous_pid=$!
	wait $_previous_pid
	rm -rf /opt/BESClient
	_previous_pid=$!
	wait $_previous_pid
	rm -rf /tmp/BES
	_previous_pid=$!
	wait $_previous_pid
	rm -rf /var/opt/BESClient
	_previous_pid=$!
	wait $_previous_pid
	rm -rf /var/opt/BESCommon
	_previous_pid=$!
	wait $_previous_pid
	echo "Installation removed"
}

install_bigfix () {
	bash /repos/ecmo/ecmo-linux.sh #subject to linux admin's script
}

check_hostname
check_os_version

echo $_host
echo $_uname_results

if [[ $_uname_results == *"el7"* ]]; then
	if [[ -f "/var/opt/BESClient/besclient.config" ]]; then
		check_installed_bigfix_version
		if [[ $_installed_version == $_target_version ]]; then
			echo "Good version:" $_installed_version
			if [[ -f "/var/opt/BESClient/__BESData/__Global/Logs/${_date_now_file_name}"  ]]; then
				check_bigfix_logs				
				if [[ $_log_messages == *"GetURL failed"* ]]; then
					echo "Connection problem detected"
					#stop_bigfix_service
					#remove_bigfix_rpm					
					#remove_installed_bigfix_directories
					#install_bigfix
					#echo "Check logs for connection status"				
				else
					echo "No connection problem detected"
				fi
			else
				echo "No logs for today's date"
				#stop_bigfix_service
				#remove_bigfix_rpm
				#remove_installed_bigfix_directories
				#install_bigfix
				#echo "Check logs for connection status"
			fi
		else
			echo "Old version. Installing new version"
			#stop_bigfix_service
			#remove_bigfix_rpm
			#remove_installed_bigfix_directories
			#install_bigfix
			#echo "Check logs for connection status"
		fi	
	else
		echo "client not installed"
		#install_bigfix
		#echo "Check logs for connection status"
	fi
fi
