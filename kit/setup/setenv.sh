#!/bin/bash

JobFlag=0
DevHome=$1
DstPath=$2
EnvType=$3

if [ `getconf LONG_BIT` = 64 ]
then
    Platform=x64
else
    Platform=x86
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

if [ ! -d ${DevHome} ]
then
    echo DEV home \<${DevHome}\> not exists!
    exit
fi

if [ "${EnvType}" = "Debug" ]
then
    EnvType=DLL_Debug
fi

if [ "${EnvType}" = "Release" ]
then
    EnvType=DLL_Release
fi

if [ "${EnvType}" = "DLL_Debug" ] || [ "${EnvType}" = "DLL_Release" ] || [ "${EnvType}" = "LIB_Debug" ] || [ "${EnvType}" = "LIB_Release" ]
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
    echo "                   [1] Linux ${Platform} DLL_Debug"
    echo "                   [2] Linux ${Platform} DLL_Release"
    echo "                   [3] Linux ${Platform} LIB_Debug"
    echo "                   [4] Linux ${Platform} LIB_Release"
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
        EnvType=DLL_Debug
        JobFlag=1
    elif [ ${DoWhat} = 2 ]
    then
        EnvType=DLL_Release
        JobFlag=1
    elif [ ${DoWhat} = 3 ]
    then
        EnvType=LIB_Debug
        JobFlag=1
    elif [ ${DoWhat} = 4 ]
    then
        EnvType=LIB_Release
        JobFlag=1
    else
        JobFlag=0
    fi
done

clear

if [ ! -d ${DstPath}/bin ]
then
    mkdir -p ${DstPath}/bin
fi

if [ ! -d ${DstPath}/lib ]
then
    mkdir -p ${DstPath}/lib
fi

if [ ! -d ${DstPath}/etc ]
then
    mkdir -p ${DstPath}/etc
fi

if [ ! -d ${DstPath}/log ]
then
    mkdir -p ${DstPath}/log
fi

if [ ! -d ${DstPath}/tmp ]
then
    mkdir -p ${DstPath}/tmp
fi

echo
echo Cleanup installed environment ...

if [ "${EnvType}" = "DLL_Debug" ] || [ "${EnvType}" = "DLL_Release" ]
then
    rm -f ${DstPath}/lib/libGC*.a
    rm -f ${DstPath}/lib/libGc*.a
    rm -f ${DstPath}/lib/libAny*.a
else
    rm -f ${DstPath}/bin/libGC*.so
    rm -f ${DstPath}/bin/libGc*.so
    rm -f ${DstPath}/bin/libAny*.so
fi

echo
echo Set \<${EnvType}\> environment ...
echo --------------------------------------

if [ ${EnvType} = "DLL_Release" ]
then
    if [ -f ${DevHome}/bin_linux/gcfl_linux_x64.tar.gz ] 
    then
        tar -zxvf ${DevHome}/bin_linux/gcfl_linux_x64.tar.gz            -C ${DstPath}
    fi

    if [ -f ${DevHome}/bin_linux/any_linux_x64.tar.gz ] 
    then
        tar -zxvf ${DevHome}/bin_linux/any_linux_x64.tar.gz             -C ${DstPath}
    fi
elif [ ${EnvType} = "DLL_Debug" ]
then
    if [ -f ${DevHome}/bin_linux/gcfl_linux_x64_dbg.tar.gz ] 
    then
        tar -zxvf ${DevHome}/bin_linux/gcfl_linux_x64_dbg.tar.gz        -C ${DstPath}
    fi

    if [ -f ${DevHome}/bin_linux/any_linux_x64_dbg.tar.gz ] 
    then
        tar -zxvf ${DevHome}/bin_linux/any_linux_x64_dbg.tar.gz         -C ${DstPath}
    fi
elif [ ${EnvType} = "LIB_Release" ]
then
    if [ -f ${DevHome}/bin_linux/gcfl_linux_x64_static.tar.gz ] 
    then
        tar -zxvf ${DevHome}/bin_linux/gcfl_linux_x64_static.tar.gz     -C ${DstPath}
    fi

    if [ -f ${DevHome}/bin_linux/any_linux_x64_static.tar.gz ] 
    then
        tar -zxvf ${DevHome}/bin_linux/any_linux_x64_static.tar.gz      -C ${DstPath}
    fi
elif [ ${EnvType} = "LIB_Debug" ]
then
    if [ -f ${DevHome}/bin_linux/gcfl_linux_x64_static_dbg.tar.gz ] 
    then
        tar -zxvf ${DevHome}/bin_linux/gcfl_linux_x64_static_dbg.tar.gz -C ${DstPath}
    fi

    if [ -f ${DevHome}/bin_linux/any_linux_x64_static_dbg.tar.gz ] 
    then
        tar -zxvf ${DevHome}/bin_linux/any_linux_x64_static_dbg.tar.gz  -C ${DstPath}
    fi
else
    echo Invalid environment type!
fi

# Note: Use system installed openssl.
if [ -d ${DevHome}/include/openssl ]
then
    rm -rf ${DevHome}/include/openssl
fi

echo --------------------------------------
echo Set \<${EnvType}\> environment OK.
echo
