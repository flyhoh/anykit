#!/bin/bash

#####################################################################
#
#   Copyright (c) 2017 MengFei.
#   All Rights Reserved.
#
#   Author   :  MengFei
#   Version  :  1.0
#   Creation :  2017/06/20
#
#####################################################################

export ANY_HOME=`pwd`

function __printx()
{
    echo -e "$@"
}

function __printl()
{
    echo -n "$@"
}

JobFlag=0
MakeDir=$1
DevHome=$2
DstPath=$3
EnvType=$4

if [ `getconf LONG_BIT` = 64 ]
then
    Platform=x64
else
    Platform=x86
fi

if [ "${MakeDir}" = "" ]
then
    echo Please set the \<Makefile\> path!
    exit
fi

if [ "${DevHome}" = "" ]
then
    echo Please set the \<depend\> path!
    exit
fi

if [ "${DstPath}" = "" ]
then
    echo Please set the \<target\> path!
    exit
fi

if [ ! -d ${MakeDir} ]
then
    echo Makefile path \<${MakeDir}\> not exists!
    exit
fi

if [ ! -d ${DevHome} ]
then
    echo DEV home \<${DevHome}\> not exists!
    exit
fi

if [ "${EnvType}" = "Debug" ] || [ "${EnvType}" = "Release" ]
then
    JobFlag=1
else
    JobFlag=0
fi

while [ ${JobFlag} = 0 ]
do
    clear
    echo 
    echo ================================================================
    echo "               Set the target environment:"
    echo "                   [1] Linux ${Platform} Debug"
    echo "                   [2] Linux ${Platform} Release"
    echo "                   [0] Exit"
    echo 

    read -p "Input your choice(default is 1): " DoWhat
    # Default is 1
    DoWhat=${DoWhat:-1}

    if [ ${DoWhat} = 0 ]
    then
        clear
        exit
    elif [ ${DoWhat} = 1 ]
    then
        EnvType=Debug
        JobFlag=1
    elif [ ${DoWhat} = 2 ]
    then
        EnvType=Release
        JobFlag=1
    else
        JobFlag=0
    fi
done

clear

#
# Build
#
CurPath=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
if [ -f ${CurPath}/.setenv.sh ]
then
    SetEnv=${CurPath}/.setenv.sh
else
    SetEnv=${CurPath}/setenv.sh
fi

${SetEnv} ${DevHome} ${DstPath} ${EnvType}

cd ${MakeDir}

make clean
if [ "$EnvType" = "Debug" ]
then
    make set runpath=. debug
else
    make set runpath=.
fi
make install

MakeResult="$?"

cd ../../

#
# Check status.
#
if [ $MakeResult != "0" ]; then
    __printx "\nBuild $EnvType error, stop ..."
    exit 1
fi

__printx "\nBuild $EnvType OK.\n"

