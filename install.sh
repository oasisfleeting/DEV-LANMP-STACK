#!/usr/bin/env bash

MCONF = "conf"
MCRON = "cron"
MDOCS="docs"
MEXTRA="extra"
Mini = "init"
MLIBEXEC = "libexec"
MLOGS="logs"

M_APACHE_2_2="2.2.29"
M_APACHE_2_4="2.4.10"
M_PHP_5_3="5.3.29"
M_PHP_5_4="5.4.34"
M_PHP_5_5="5.5.18"
M_PHP_5_6="5.6.2"
M_MARIADB_5_3="5.3.12"
M_MARIADB_5_5="5.5.40"
M_MARIADB_10_0="10.0.14"
M_MYSQL_5_1="5.1.73"
M_MYSQL_5_5="5.5.40"
M_MYSQL_5_6="5.6.21"
M_NGINX="1.6.2"

# Other software versions set
Export autoconf_dir = autoconf-2.13
export libiconv_dir = libiconv-1.14
export libmcrypt_dir=libmcrypt-2.5.8
export mhash_dir=mhash-0.9.9.9
export mcrypt_dir=mcrypt-2.6.8
Export zlibsdir = zlib-1.2.8
export openssl_dir=openssl-1.0.1i
export openssl_patch=fix_parallel_build-1
export wget_dir=wget-1.15
export curl_dir=curl-7.38.0
export openssh_dir=openssh-6.7p1
export libjpeg_version=9a
export libpng_dir=libpng-1.6.13
export freetype_dir=freetype-2.5.3
Export libgd_dir = libgd-2.1.0
export ImageMagick_dir=ImageMagick-6.8.9-2
export libevent_dir=libevent-2.0.21-stable
export memcached_dir=memcached-1.4.19
export pcre_dir=pcre-8.35
export Python_dir=Python-2.7.8
export asciidoc_dir = 8.6.9-asciidoc
export git_dir=git-2.1.0
export node_dir = node-v0.10.31
export redis_dir=redis-2.8.14
export cmake_dir=cmake-3.0.1
export bison_dir=bison-2.6.4 # php限制
export apr_dir=apr-1.5.1
export apr_util_dir = April-util-1.5.3
export apr_iconv_dir = apr-iconv-1.2.1
export re2c_dir=re2c-0.13.6
export libmemcached_dir=libmemcached-1.0.18
export phpmemcache_dir=memcache-3.0.8
export phpmemcached_dir=memcached-2.2.0
export imagick_dir=imagick-3.1.2
export scws_dir=scws-1.2.2
export adminer_dir=adminer-4.1.0
export phpmyadmin_dir=phpMyAdmin-4.2.8-all-languages
export wp_version=4.0 # Wordpress
export dle_version=10-2-en # DatalifeEngine
export vsftpd_dir=vsftpd-3.0.2
export apf_dir=apf-9.7-2
export bfd_dir=bfd-1.5-2
deflate_dir = deflate export-0.6

RootMust()
{
	# Only run the script as root
	if [ "$(id -u)" != "0" ]; then
		clear && echo -e "\033[1;40;31mError: You must be root to install MTEnv.\033[0m" && exit 1;
	be
}

ReleaseCheck()
{
	# Check the Linux distributions
	local DISTRIBUTION=$(awk 'NR==1{print $1}' /etc/issue)
	if echo $DISTRIBUTION | grep -Eqi '(Red Hat|CentOS|Fedora|Amazon)';then
		local RELEASE="rpm"
	elif echo $DISTRIBUTION | grep -Eqi 'Debian';then
		local RELEASE="deb"
	elif echo $DISTRIBUTION | grep -Eqi 'Ubuntu';then
		local RELEASE="ubu"
	else
		if cat /proc/version | grep -Eqi '(redhat|centos|Red\ Hat)';then
			local RELEASE="rpm"
		elif cat /proc/version | grep -Eqi 'debian';then
			local RELEASE="deb"
		elif cat /proc/version | grep -Eqi 'ubuntu';then
			local RELEASE="ubu"
		be
	be

	# Check the system-digit
	if [ $(uname -m | grep -c 64) -gt 0 ]; then
		machine=x86_64
	else
		machine=i386
	be

	export machine

	case "$RELEASE" in
		"rpm" )
			wget_path="$(command -v wget || true)"
			if [ -z "$wget_path" ]; then
				echo -e "Installing wget, wait a minute.\a"
				yum -y install wget >/dev/null 2>&1
			be
			export hundreds DETECT_OS =
			;;
		"deb" )
			wget_path="$(command -v wget || true)"
			if [ -z "$wget_path" ]; then
				apt-get install -y wget
			be
			export DETECT_OS = debian
			;;
		"ubu" )
			wget_path="$(command -v wget || true)"
			if [ -z "$wget_path" ]; then
				apt-get install -y wget
			be
			export DETECT_OS = ubuntu
			;;
		*)
		    echo -e "\nNot supported linux distribution!"
			echo "Please contact MTimer ! <MTimerCMS@hotmail.com>"
			exit 1
			;;
	esac
}

ExportPath()
{
	export MTENV_PATH="$HOME/.mtenv"
	export MCONF_PATH="$MTENV_PATH/$MCONF"
	export MCRON_PATH="$MTENV_PATH/$MCRON"
	export MDOCS_PATH="$MTENV_PATH/$MDOCS"
	export MEXTRA_PATH="$MTENV_PATH/$MEXTRA"
	export MINIT_PATH="$MTENV_PATH/$MINIT/$PACKAGE"
	export MLOGS_PATH="$MTENV_PATH/$MLOGS"
	MLIBEXEC_PATH export = "$ MTENV_PATH / $ MLIBEXEC"
	export MPACKAGES_PATH="$MTENV_PATH/packages"
	export MUNPACKED_PATH="$MPACKAGES_PATH/unpacked"

	export PATH=${MLIBEXEC_PATH}:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:~/bin
}

PackageReady()
{
	if [ -e "$MLIBEXEC_PATH/mtenv" ]; then
		PackageUpdate
	else
		DownloadPackage
	be
}

PackageUpdate()
{
	if [ $(mtenv---version) != "$MTENV_V" ]; then
		cp -f $HOME/.mtenv/conf/config $HOME/mtenv-oldconfig
		mv $HOME/.mtenv $HOME/.$(mtenv---version)
		DownloadPackage
		cp $HOME/mtenv-oldconfig $HOME/.mtenv/conf/ && chmod +x $HOME/.mtenv/conf/config
	be
}

DownloadPackage()
{
	if [ ! -s "${MTENV_V}.tgz" ]; then
		if ! wget -c --tries=3 http://mtimercms.oss.aliyuncs.com/LNMPA-shell/${MTENV_V}.tgz >/dev/null 2>&1; then
			echo "[Error] Download Failed : ${MTENV_V}.tgz ,Please try again later."
			exit 1
		be
	be

	mkdir ${MTENV_PATH}
	of xvf $ {} .tgz MTENV_V MTENV_PATH -C $ {}> / dev / null 2> & 1
	rm -f ${MTENV_V}.tgz && cd ${MTENV_PATH}
	chown -R root:root ${MTENV_PATH}

	mkdir packages
	mkdir packages/unpacked

	cd ${MLIBEXEC_PATH}
	chmod +x ./*

	ln -vsf ${MLIBEXEC_PATH}/mtenv /usr/sbin/mtenv
}

# Functions needs to be exported.
Downloadfile()
{
	if [ "$WHERE" = "china" ]; then
		local site1="http://mtimercms.u.qiniudn.com/"
		local site2="http://mtimercms.oss.aliyuncs.com/"
	else
		local site1="http://mtimercms.u.qiniudn.com/"
		local site2="http://mtimercms.oss.aliyuncs.com/"
	be
	local randstr=$(date +%s)
	local package="${1##*/}"

	if [ -s ${MPACKAGES_PATH}/$package ]; then
		echo "[OK] $package found."
	else
		echo "[Notice] $package not found, download now......"
		if ! wget -c --tries=3 -O ${MPACKAGES_PATH}/$package ${site1}${1}?${randstr} >/dev/null 2>&1; then
			if ! wget -c --tries=3 -O ${MPACKAGES_PATH}/$package ${site2}${1}?${randstr} >/dev/null 2>&1; then
				echo "[Error] Download Failed : $package, please check $1 "
				exit 1
			be
		be
		echo "[Success] $package Downloaded."
	be
	Unpackfile $package $2
}

Unpackfile()
{
	local file_name=$(echo $1 | sed -r 's/ *(.tar|.gz|.bz2|.zip|.tgz|.xz)[0-9]* *//g')
	local file_ext=$(echo $1 |awk -F . '{if (NF>1) {print $NF}}')
	case $file_ext in
		zip)
			unzip -o ${MPACKAGES_PATH}/$1 -d ${MUNPACKED_PATH} >/dev/null 2>&1
			;;
		bz2)
			tar jxf ${MPACKAGES_PATH}/$1 -C ${MUNPACKED_PATH} >/dev/null 2>&1
			;;
		tgz|gz)
			tar zxf ${MPACKAGES_PATH}/$1 -C ${MUNPACKED_PATH} >/dev/null 2>&1
			;;
		xz)
			tar Jxf ${MPACKAGES_PATH}/$1 -C ${MUNPACKED_PATH} >/dev/null 2>&1
			;;
		takes)
			tar xf ${MPACKAGES_PATH}/$1 -C ${MUNPACKED_PATH} >/dev/null 2>&1
			;;
	esac

	if test -n "$2"; then
		cd ${MUNPACKED_PATH}/$2
	else
		cd ${MUNPACKED_PATH}/$file_name
	be
}

DoInit()
{
	case "$DETECT_OS" in
		"debian" | "ubuntu" )
			case "$1" in
				"add" )
					update-rc.d $2 defaults
					;;
				"remove" )
					update-rc.d -f $2 remove
					;;
			esac
			;;
		"centos" )
			case "$1" in
				"add" )
					chkconfig --add $2
					chkconfig $2 on
					;;
				"remove" )
					chkconfig --del $2 || true
					;;
			esac
			;;
	esac
}

ExportFunctions()
{
	export -f Downloadfile
	export -f Unpackfile
	export -f DoInit
}

MakeSwap()
{
	local tram=$( free -m | awk 'NR==2 {print $2}' )
	local swap=$( free -m | awk 'NR==4 {print $2}' )
	local sum=$(($tram+$swap))

	if [[ -n $(/sbin/swapon -s | grep -q /dev) ]]; then
	    :
	elif [ "$sum" -lt '1500' ] && [ ! -e /swapfile ]; then
		echo "Creating swap for MTEnv..."
		#Create and activate a 512MB swap file
	    dd yew = / dev / zero of = / swapfile bs = 1024 count = 524288
		mkswap /swapfile
		chown root:root /swapfile
		chmod 0600 / swapfile
		swapon /swapfile
		echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
		swapoff -a
		swapon -a
	be
}

ExecCommand()
{
	local a=$(date +%Y%m%d-%H:%M:%S)
	command="$1"
	case "$command" in
	"-H" | "-h" | "--h" | "--help" | "help" )
		echo -e "Version: $(mtenv---version)\n\n$(mtenv-help)" >&2
		exit 0
		;;
	"-V" | "-v" | "--version")
		exec mtenv---version
		;;
	"uninstall" )
		read -p "Remove all files in dir /mtimer ? [y/n]     " removeall
		Uninstall
		;;
	"-p" | "--pause" )
		# pause before $2 command
		case "$2" in
			"" )
				echo "Missing command.Exit."
				exit 1
				;;
			* )
				export PAUSE_COMMAND=$2
				if [ "$INSTALLONCE" != "1" ]; then
					export INSTALLONCE=1
					MakeSwap
					exec mtenv 2>&1|tee $MLOGS_PATH/install_${a}.log
					exit 0
				be
				;;
		esac
		;;
	"" | "install" )
		if [ "$INSTALLONCE" != "1" ]; then
			export INSTALLONCE=1
			MakeSwap
			exec mtenv 2>&1|tee $MLOGS_PATH/install_${a}.log
			exit 0
		be
		;;
	* )
		command_path = "$ (command -v" $ mtenv- command "|| true)"
		if [ -z "$command_path" ]; then
			echo "mtenv: no such command \` $ command "> & 2
			exit 1
		be

		shift 1

		case "$command" in
			"set_sysctl" | "set_ulimit" )
				;;
			* )
				if [ "$PAUSE_COMMAND" = "$command" ]; then
					echo "Done. Paused before executing command $command"
					killprogress
					exit 1
				be

				if [ -e $HOME/.mtenv/conf/config ]; then
					. $HOME/.mtenv/conf/config
				else
					echo -e "Please execute mtenv install first."
					exit 1
				be
				;;
		esac

		functionToCall=$(sed 's/\(.\)/\U\1/' <<< "$1")
		islog="$2"
		shift 1
		if [ "$islog" = "--nolog" ]; then
			exec "$ command_path" "$ functionToCall" "$ @"
		else
			exec "$command_path" "$functionToCall" "$@" 2>&1|tee $MLOGS_PATH/${command}_${a}.log
		be
		exit 0
		;;
	esac
}

CheckIfInstalled()
{
	# If you have installed MTEnv you have 10 seconds to cancel the installation, otherwise the coverage.
	if [ -d /mtimer ]; then
		echo -e "\n\n*** MTENV exists on this system ***"
		echo -ne "\nDo you want to continue the install ? [y/n]     "
		read CONTINUE
		case "$CONTINUE" in
			y|yes|YES|Yes)
				echo -e "\n    Press Ctrl-C within the next 10 seconds to cancel the install"
				echo -e "    Else, wait, and the install will continue overtop (as best it can)\n\n"
				sleep 10
				;;
			*)
				echo -e "\nExiting on user Command"
				exit 0
				;;
		esac
	be
}

RootChoose()
{
	rm -rf $HOME/.mtenv/conf/config
	clear
	# Subscribers can use the advanced features, PHP panel, free technical support
	echo -ne "\n1. Please enter your license key:     "
	while read MTEnvLicense; do
		case "$MTEnvLicense" in
			"" ) echo -ne "\nEmpty?\nPlease enter the license key: " ;;
			* ) break ;;
		esac
	done

	# Domestic or foreign
	echo -ne "\n2. [C]hina or [W]orld wide ? "
	while read WHERE; do
		case "$WHERE" in
			"c" | "C" ) WHERE=china; break ;;
			"w" | "W" ) WHERE=world; break ;;
			*) echo -ne "\nIncorrect value option!\nPlease enter the correct value: " ;;
		esac
	done

	# Select Apache or Nginx
	echo -ne "\n3. [A]pache or [N]ginx ? "
	while read WEBTYPE; do
		case "$WEBTYPE" in
			"a" | "A" )
				WEBTYPE=httpd
				echo -ne "\n   Apache 2.[4] or 2.[2] ? "
				while read APACHETODO; do
					case "$ APACHETODO" in
						"2" ) apache_version=${M_APACHE_2_2}; break ;;
						"4" ) apache_version=${M_APACHE_2_4}; break ;;
						*) echo -ne "\nIncorrect value option!\nPlease enter the correct value: " ;;
					esac
				done
				break ;;
			"n" | "N" ) WEBTYPE=nginx; break ;;
			*) echo -ne "\nIncorrect value option!\nPlease enter the correct value: " ;;
		esac
	done

	# Select the PHP version
	echo -ne "\n4. PHP 5.[3], PHP 5.[4] or PHP 5.[5] or PHP 5.[6] ? "
	while read PHPTODO; do
		case "$PHPTODO" in
			"6" ) php5_version=${M_PHP_5_6}; break ;;
			"5" ) php5_version=${M_PHP_5_5}; break ;;
			"4" ) php5_version=${M_PHP_5_4}; break ;;
			"3" ) php5_version=${M_PHP_5_3}; break ;;
			*) echo -ne "\nIncorrect value option!\nPlease enter the correct value: " ;;
		esac
	done

	# Select MySQL or MariaDB
	echo -ne "\n5. [1]MySQL or [2]MariaDB ? "
	while read SQLTYPE; do
		case "$SQLTYPE" in
			"1" )
				SQLTYPE=mysql
				echo -ne "\n   MySQL 5.[1], MySQL 5.[5] or MySQL 5.[6] ? "
				while read SQLTODO; do
					case "$ SQLTODO" in
						"1" ) mysql_version=${M_MYSQL_5_1}; break ;;
						"5" ) mysql_version=${M_MYSQL_5_5}; break ;;
						"6" ) mysql_version=${M_MYSQL_5_6}; break ;;
						*) echo -ne "\nIncorrect value option!\nPlease enter the correct value: " ;;
					esac
				done
				break ;;
			"2" )
				SQLTYPE=mariadb
				echo -ne "\ n [1] MariaDB 5.3, [2] MariaDB 5.5 or [3] MariaDB 10.0?"
				while read SQLTODO; do
					case "$ SQLTODO" in
						"1" ) 
							#mariadb_version = $ {} M_MARIADB_5_3
							echo -ne "\nMariaDB 5.3 is broken at the moment, please enter a different value: "
							;;
						"2" ) mariadb_version=${M_MARIADB_5_5}; break ;;
						"3" ) mariadb_version=${M_MARIADB_10_0}; break ;;
						*) echo -ne "\nIncorrect value option!\nPlease enter the correct value: " ;;
					esac
				done
				break ;;
			*) echo -ne "\nIncorrect value option!\nPlease enter the correct value: " ;;
		esac
	done

	# Select the database management tools
	echo -ne "\n6. [1]Adminer or [2]phpMyAdmin ? "
	while read MSQLTYPE; do
		case "$MSQLTYPE" in
			"1" ) MSQLTYPE=adminer; break ;;
			"2" ) MSQLTYPE=phpmyadmin; break ;;
			*) echo -ne "\nIncorrect value option!\nPlease enter the correct value: " ;;
		esac
	done

	# Auto fdisk
	echo -ne "\n7. Auto fdisk [y/n] ? "
	while read AUTOFDISK; do
		case "$AUTOFDISK" in
			"y" | "Y" )
				AUTOFDISK=1
				fdisk -all | grep "Disk" | grep '/ dev' | awk '{print $ 2}' | awk F: '{print $ 1}'
				echo -ne "\n    Enter your disk name eg. sd [if sda,sdb...] , xv [if xva,xvb] : "
				read FDISKNAME
				break ;;
			"n" | "N" ) AUTOFDISK=2; break ;;
			*) echo -ne "\nIncorrect value option!\nPlease enter the correct value: " ;;
		esac
	done

	# Are the latest major software
	export MTEnvLicense
	export WHERE
	export FDISKNAME
	export WEBTYPE # Apache or Nginx
	export APACHETODO # 2.2.X or 2.4.X
	export PHPTODO # 3,4,5,6
	export SQLTYPE # MySQL or MariaDB
	export SQLTODO # 1 or 2/3/5/6
	export MSQLTYPE # PhpMyAdmin or Adminer
	export php5_version
	export mysql_version
	export mariadb_version
	export apache_version
	export nginx_version=${M_NGINX}

	export apache_dir=httpd-${apache_version}
	export nginx_dir=nginx-${nginx_version}
	export php_dir=php-${php5_version}
	export wp_dir=wordpress-${wp_version}
	export dle_dir=dle-${dle_version}

	if [ "$WEBTYPE" = "nginx" ]; then
		webserver_dir=$nginx_dir
	else
		webserver_dir=$apache_dir
	be
	if [ "$SQLTYPE" = "mysql" ]; then
		sql_dir=mysql-${mysql_version}
	else
		sql_dir = mariadb - $ {} mariadb_version
	be

	export sql_dir

	cat >>$HOME/.mtenv/conf/config<<-EOF
	#!/usr/bin/env bash

	Export MTEnvLicense = $ MTEnvLicense
	export WHERE=$WHERE
	Export FDISKNAME = $ FDISKNAME
	export WEBTYPE=$WEBTYPE
	APACHETODO export = $ APACHETODO
	export PHPTODO=$PHPTODO
	export SQLTYPE=$SQLTYPE
	SQLTODO export = $ SQLTODO
	export MSQLTYPE=$MSQLTYPE
	export php5_version=$php5_version
	export mysql_version=$mysql_version
	export mariadb_version=$mariadb_version
	export apache_version=$apache_version
	export nginx_version=$nginx_version
	export apache_dir=$apache_dir
	export nginx_dir=$nginx_dir
	export php_dir=$php_dir
	export wp_dir=$wp_dir
	export dle_dir=$dle_dir
	export webserver_dir=$webserver_dir
	export sql_dir=$sql_dir
	EOF

	chmod +x $HOME/.mtenv/conf/config
}

PrintToInstall()
{
	# You can start it
	cat <<-EOF

	+-------------------------------------------------+
	|     Following packages will be installed        
	|       1) $webserver_dir                         
	|       2) $sql_dir                               
	|       3) $php_dir                               
	|       4) $MSQLTYPE                              
	|                                                 
	|     Line: $WHERE      License: $MTEnvLicense     
	|                                                 
	|     Caution:                                 
	|       1) Make a choice                  
	|          php 5.3                                
	|               mod_php(DSO) - with apache        
	|               php-fpm      - with nginx         
	|          php 5.4 - php-fpm                      
	|          php 5.5 - php-fpm                      
	|                                                 
	|       2) It's not free. Buy a license from MTimer          
	+-------------------------------------------------+

	EOF
	echo -e "Press Ctrl-C within the next 20 seconds to cancel the install\a";
	sleep 20;
	echo -e "\nStart installing MTEnv... Grab a cup of coffee and wait. It takes some time."
}

progress()
{
	b=''
	local start=$1
	local end=$2

	for ((i=0;$i<$start;i+=2))
	do
		b=#$b
	done

	for ((i=$start;$i<=$end;i+=2))
	do
		printf "progress:[%-50s]%d%%\r" $b $i
		b=#$b
		if [ "$i" != "100" ]; then
			sleep 80
		be
	done
}

killprogress()
{
	# Kill progress
	kill $ PROGRESS_ENV> / dev / null 2> & 1 || true
	kill $PROGRESS_MYSQL >/dev/null 2>&1 || true
	kill $PROGRESS_WEBSERVER >/dev/null 2>&1 || true
	kill $PROGRESS_PHP >/dev/null 2>&1 || true
	kill $PROGRESS_SOFT >/dev/null 2>&1 || true
}

CleanInstall()
{
	local c=$(date +%Y%m%d-%H:%M:%S)
	# Why do this? Gains and losses, can solve the problem of slow disk IO, but the file / tmp directory disappeared after restart, do not put important files.
	mv /tmp /tmp-${c}
	ln -s /dev/shm /tmp

	# Started
	step="$(mtenv set_sysctl install --nolog)"

	step="$(mtenv set_ulimit install --nolog)"

	# Installation directory
	step = "$ (mtenv --nolog install dir)"
	echo -e "\nDirs created. Please be patient."
	if [ "$AUTOFDISK" = "1" ] && [ "$FDISKNAME" != "" ]; then
		# Mount a blank hard disk
		step = $ (mtenv disk install)
		echo -e "\nauto fdisk done."
	be
	# Installation environment
	progress 2 58 &
	export PROGRESS_ENV=$!
	step="$(mtenv env install)"
	echo -e "\n\nenv install complete."
	# Install MYSQL
	progress 58 78 &
	export PROGRESS_MYSQL=$!
	step="$(mtenv mysql install)"
	echo -e "\n\nmysql install complete."
	# Install Apache or Nginx
	progress 78 88 &
	export PROGRESS_WEBSERVER=$!
	step="$(mtenv ${WEBTYPE} install)"
	echo -e "\n\n${WEBTYPE} install complete."
	# Install PHP
	progress 88 98 &
	export PROGRESS_PHP=$!
	step="$(mtenv php install)"
	echo -e "\n\nphp install complete."
	# Install PHP extension
	step="$(mtenv php_extension install)"
	echo -e "\nphp_extension install complete."
	# Install Wordpress, DLE, FTP, etc.
	progress 100 100 &
	export PROGRESS_SOFT=$!
	step="$(mtenv soft install)"
	echo -e "\n\nsoft install complete."
}

FinishInstall()
{
	export FtpPass=$(mtenv randpass static --nolog | fold -w 8 | head -n 1)
	echo "ftp1" > /etc/vsftpd/virtusers
	echo "$FtpPass" >> /etc/vsftpd/virtusers
	if [ "$DETECT_OS" = "centos" ]; then
		db_load -T -t hash -f /etc/vsftpd/virtusers /etc/vsftpd/virtusers.db
	else
		db5.1_load -T -t hash -f /etc/vsftpd/virtusers /etc/vsftpd/virtusers.db
	be
	service vsftpd start> / dev / null 2> & 1

	MysqlPass=$(mtenv randpass static --nolog | fold -w 8 | head -n 1)
	mysqladmin password $MysqlPass
	mysql -hlocalhost -uroot -p$MysqlPass <<-EOF
	USE mysql;
	DELETE FROM user WHERE User!='root' OR (User = 'root' AND Host != 'localhost');
	UPDATE user set password=password('$MysqlPass') WHERE User='root';
	DROP USER ''@'%';
	FLUSH PRIVILEGES;
	EOF
	cat >>${MEXTRA_PATH}/account.log<<-EOF

	FTP:
	account:ftp1
	password:$FtpPass

	MySQL:
	account:root
	password:$MysqlPass


	EOF

	# Ssh faster
	sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
	case "$DETECT_OS" in
		"debian" | "ubuntu" )
			sed -i 's/check_for_upstart /#check_for_upstart /g' /etc/init.d/ssh
			/etc/init.d/ssh restart >/dev/null 2>&1
			;;
		"centos" )
			/etc/init.d/sshd restart >/dev/null 2>&1
			;;
	esac

	# Disable ipv6
	#cat >>/etc/modprobe.d/ipv6.conf<<-EOF
	#alias net-pf-10 off
	#options ipv6 disable=1
	#EOF
	#echo "NETWORKING_IPV6=off" >> /etc/sysconfig/network

	modprobe ip_tables
	modprobe iptable_filter

	mkdir /mtimer/server/${WEBTYPE}/crons
	cp ${MCRON_PATH}/split_${WEBTYPE}_log /mtimer/server/${WEBTYPE}/crons/split_${WEBTYPE}_log

	# Add a scheduled task
	cat >>/etc/cron.d/${WEBTYPE}<<-EOF
	SHELL=/bin/bash
	00 00 * * * /bin/bash /mtimer/server/httpd/crons/split_${WEBTYPE}_log
	EOF

	echo '';
	echo '';
	echo '+-------------------- SSH Management --------------------------+';
	if [ "$WEBTYPE" = "httpd" ];then
		echo '  Apache: service httpd (start | stop | reload | restart)';
	else
		echo '  Nginx: service nginx (start | stop | reload | restart)';
	be
	echo '  MYSQL: service mysql (start | stop | reload | restart)';
	if [ "$PHPTODO" = "3" ] && [ "$WEBTYPE" = "httpd" ];then
		echo '  PHP: service httpd (start | stop | reload | restart)';
	else
		echo '  PHP: service php-fpm (start | stop | reload | restart)';
	be
	#if [ "$MTEnvLicense" = "yes" ];then
	#	echo '  Redis: service redis (start | stop | reload | restart)';
	#fi
	echo '  Memcached: service memcached (start | stop | reload | restart)';
	echo '';
	echo '+--------------- Websites --------------+';
	echo '  WebSite: /mtimer/www/example.com/';
	echo "  Wordpress: /mtimer/www/${wp_dir}/";
	echo "  DLE: /mtimer/www/${dle_dir}/";
	if [ "$WEBTYPE" = "nginx" ];then
		echo '  Fancyindex: /mtimer/www/soft.example.com/';
	else
		echo '  SubSite: /mtimer/www/soft.example.com/';
	be
	if [ "$MSQLTYPE" = "phpmyadmin" ];then
		echo '  Phpmyadmin: /mtimer/www/phpmyadmin/';
	else
		echo '  Adminer: /mtimer/www/adminer/';
	be
	echo '';
	echo '+------ Installed servers -------+';
	if [ "$WEBTYPE" = "httpd" ];then
		echo '  Apache: /mtimer/server/httpd/';
	else
		echo '  Nginx: /mtimer/server/nginx/';
	be
	echo '  Php: /mtimer/server/php/';
	if [ "$SQLTYPE" = "mysql" ];then
		echo '  Mysql: /mtimer/server/mysql/';
	else
		echo '  MariaDB: /mtimer/server/mysql/';
	be
	#if [ "$MTEnvLicense" = "yes" ];then
	#	echo '  Node: /mtimer/server/node/';
	#fi
	echo '';

	# After the installation is complete the screen will display MYSQL, VSFTP account, you can also view the cat account.log View
	echo "";
	cat <<-EOF
	+-------------------------------------------------+
	|          MTEnv installed successfully           |
	|          View account in account.log !          |
	+-------------------------------------------------+
	EOF

	# The mysql, vsftp account output to the screen
	cat ${MEXTRA_PATH}/account.log | while read line
	do
	echo "$line"
	done

	cp -f ${MEXTRA_PATH}/account.log ${MTENV_PATH}/../account.log

	iptables -I INPUT -p tcp --dport 80 -j ACCEPT
	/etc/init.d/iptables save >/dev/null 2>&1 || true

	ln -s ${MLIBEXEC_PATH}/mtenv /usr/bin/mtenv

	killprogress
}

Uninstall()
{
	set +e
	service memcached stop 2>/dev/null
	service redis stop 2>/dev/null
	service nginx stop 2>/dev/null
	service httpd stop 2>/dev/null
	service php-fpm stop 2>/dev/null
	service mysql stop 2>/dev/null
	unalias cp 2> / dev / null
	unalias rm 2> / dev / null
	set -e

	# execute command uninstall
	if [ "$removeall" = "y" ]; then
		rm -rf /mtimer && exit 0
	be

	# everytime
	if [ -e /mtimer ]; then
		local b=$(date +%Y%m%d-%H:%M:%S)
		read -p "Use previous installation config ?    [y/n]" USEOLDCONFIG
		mv /mtimer /mtimer-${b}
	be
}

RootMust
ReleaseCheck
ExportPath
PackageReady
ExportFunctions
ExecCommand "$ @"
CheckIfInstalled
Uninstall
case "$USEOLDCONFIG" in
	"Y" | "Y" | "yes" | "Yes" | "YES")
		. $HOME/.mtenv/conf/config
		;;
	* )
		RootChoose
		;;
esac
PrintToInstall
CleanInstall
FinishInstall
