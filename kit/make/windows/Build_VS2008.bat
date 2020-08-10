::------------------------------------------------------------------------------------------------::

@ECHO OFF

CALL :Build_VS2008 %*

GOTO :EOF

::------------------------------------------------------------------------------------------------::

::------------------------------------------------------------------------------------------------::
::
:: Function Section
::
::------------------------------------------------------------------------------------------------::

::------------------------------------------------------------------------------------------------::

:__Help
::
SETLOCAL

ECHO.
ECHO Usage:
ECHO   "Build_VS2008 <BuildResult> <ProjFile> [x64|x86|Win64|Win32] [Prifix][Release|Debug][Postfix] [ShowWarning|NoWarning]"
ECHO.

ENDLOCAL & GOTO :EOF

::------------------------------------------------------------------------------------------------::

:Build_VS2008 <BuildResult> <ProjFile> [x64|x86|Win64|Win32] [Prifix][Release|Debug][Postfix] [ShowWarning|NoWarning]
::
::      -- 使用VS2008编译工程
::      -- 用法：
::      --   CALL :Build_VS2008 BuildResult ProjFile [x64|x86|Win64|Win32] [Prifix][Release|Debug][Postfix] [ShowWarning|NoWarning]
::      -- 参数：
::      --   %1: BuildResult - 返回编译结果
::      --   %2: ProjFile    - 项目名称
::      --   ...
::
SETLOCAL EnableDelayedExpansion

::--------------------------------------------------------------

:: VS2008没有像VC6一样的‘MsDevDir’环境变量，但是有‘VS90COMNTOOLS’，可以利用相对路径获得。
SET Builder_VS2008=%VS90COMNTOOLS%..\IDE\devenv.exe

IF NOT EXIST "%Builder_VS2008%" (
    ECHO "%Builder_VS2008%" Not Exists!
    PAUSE
    GOTO :__End
)

::--------------------------------------------------------------

:__GetArgument

SET Base_Path=%~dp0
SET Proj_Path=%~dp2
SET Proj_File=%~f2

SET Cfg_Platform=Win32
SET Cfg_BuildType=Release
SET Cfg_ShowWarning=TRUE

:: Set it to error first.
SET Build_Result=1

:__NextArgument

:: Shift argument from %3 to %2.
SHIFT /2

SET ARG=%2

:: No more argument, start build.
IF "%ARG%"==""                      GOTO :__Start

IF /I "%ARG%"=="x64"                (SET Cfg_Platform=%ARG%)    & GOTO :__NextArgument
IF /I "%ARG%"=="x86"                (SET Cfg_Platform=%ARG%)    & GOTO :__NextArgument
IF /I "%ARG%"=="Win64"              (SET Cfg_Platform=%ARG%)    & GOTO :__NextArgument
IF /I "%ARG%"=="Win32"              (SET Cfg_Platform=%ARG%)    & GOTO :__NextArgument

IF NOT "%ARG:Release=%"=="%ARG%"    (SET Cfg_BuildType=%ARG%)   & GOTO :__NextArgument
IF NOT "%ARG:Debug=%"=="%ARG%"      (SET Cfg_BuildType=%ARG%)   & GOTO :__NextArgument

IF /I "%ARG%"=="ShowWarning"        (SET Cfg_ShowWarning=TRUE)  & GOTO :__NextArgument
IF /I "%ARG%"=="NoWarning"          (SET Cfg_ShowWarning=FALSE) & GOTO :__NextArgument

:: Invalid argument.
ECHO.
ECHO Invalid param "%ARG%"
CALL :__Help
PAUSE
GOTO :__End

::--------------------------------------------------------------

:__Start

SET Temp_Path=%Temp%
SET Build_Cfg=%Cfg_BuildType%^|%Cfg_Platform%
SET Log_File=%Temp_Path%\Build.log

IF "%Proj_File%"=="" (
    CALL :__Help
    PAUSE
    GOTO :__End
)
IF NOT EXIST "%Proj_File%" (
    ECHO "%Proj_File%" Not Exists!
    CALL :__Help
    PAUSE
    GOTO :__End
)

IF NOT EXIST "%Temp_Path%" (
    MKDIR "%Temp_Path%"
)

GOTO :__Build

::--------------------------------------------------------------

:__Build

ECHO.
ECHO Building "%Proj_File%" - "%Build_Cfg%" ...
ECHO.

"%Builder_VS2008%" "%Proj_File%" /rebuild "%Build_Cfg%" /out "%Log_File%"
SET Build_Result=%ErrorLevel%

ECHO Clean temp files ...
SETLOCAL EnableDelayedExpansion
FOR /F "tokens=* delims=?" %%f IN ('DIR /A /B /S *.suo *.user *.ncb *.opt *.plg') DO (
    SET  DelFile=%%f
    ECHO !DelFile!
    DEL /A /Q "!DelFile!"
)
ENDLOCAL
ECHO.

IF /I "%Cfg_ShowWarning%"=="TRUE" (
    ECHO Warning:
    ECHO ------------------------------------
    FINDSTR /I "Warning" %Log_File% | FINDSTR /I /V "Warning(s)"
    ECHO ------------------------------------
)

ECHO.
ECHO Error:
ECHO ------------------------------------
FINDSTR /I "Error" %Log_File% | FINDSTR /I /V "Error(s)"
ECHO ------------------------------------

ECHO.
ECHO Result:
ECHO ------------------------------------
FINDSTR /I "Error(s)" %Log_File%
ECHO ------------------------------------

DEL /Q %Log_File%

IF NOT %Build_Result%==0 (
    ECHO.
    ECHO Build Failed.
    ECHO.
)ELSE (
    ECHO.
    ECHO Build Success.
    ECHO.
)

::--------------------------------------------------------------

:__End
ECHO.

ENDLOCAL & SET %1=%Build_Result%
GOTO :EOF

:: Build_VS2008 End.
::------------------------------------------------------------------------------------------------::
