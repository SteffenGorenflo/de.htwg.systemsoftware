#!/bin/bash


# paths
HOME_PATH=$PWD
RPI_PATH=../v3

################ RPi init ##############

init() 
{
	cd $RPI_PATH && ./v3_2 -run
	cd $HOME_PATH/modul-package && ./prepareModul.sh
	cd $HOME_PATH/modul-src && ./makeBuildrootPackets
	cd $HOME_PATH
}

compile()
{
	cd $RPI_PATH && ./v3_2 -co
	cd $HOME_PATH
}

git_source()
{
	cd $RPI_PATH && ./v3_2 -cp
	cd $HOME_PATH
}

buildroot_menu()
{
	cd ../buildroot && make menuconfig
	cd $HOME_PATH
}

################ br packages ##############
prepare_br()
{
	cd $HOME_PATH/modul-src && ./makeBuildrootPackets
}


help ()
{
	echo "Usage: ./v6.sh [OPTIONS]"
	echo ""
	echo "excample call: ./v3_1.sh -dn -pa"
	echo ""
	echo " -init	download sources & patch"
	echo " -co		compile"
	echo " -cp		copy files to server"
	echo " -p		copy buildroot (p)ackages "	
	echo " -m		buildroot menu"
	echo " -h		help"
	
}

ARGS=`getopt -o hr:pc:q:i:m: -- "$@"`

eval set -- "$ARGS"

argument=0

while true;
do
	case "$1" in
		'-i')
			if [ "$2" = "nit" ] 
			then
				init
			else
				help
			fi
			argument=1
			shift 2;;
		'-p')
			prepare_br
			argument=1
			shift 2;;
		'-m')
			buildroot_menu
			argument=1
			shift 2;;
		'-c')
			if [ "$2" = "p" -o "$2" = "o" ] 
			then
				if [ "$2" = "o" ] 
				then
					compile
				else
					git_source
				fi
			else
				help
			fi
			argument=1
			shift 2;;
		'-q')
			if [ "$2" = "e" ] 
			then
				start_qemu
			else
				help
			fi
			argument=1
			shift 2;;
		'-h')
			help
			argument=1
			break;;
		*)
			break;;
	esac
done

if [ $argument -eq 0 ]
then
	echo "argument required"
	help
fi
