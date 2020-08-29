::------------------------------------------------------------------------------------------------::

@ECHO OFF

CALL :__SetEnv %*

GOTO :EOF

::------------------------------------------------------------------------------------------------::

:__SetEnv <DevHome> <DstPath> <EnvType>
::
::      -- Set DEV Environment.
::      -- Use:
::      --   CALL :__SetEnv DevHome DstPath [EnvType]
::      -- Args:
::      --   %1: DEV home.
::      --   %2: Target path.
::      --   %3: Environment type.
::
SETLOCAL

SET DevHome=%1
SET DstPath=%2
SET EnvType=%3
SET ZipPath=%DevHome%\setup\zip

IF /I "%DevHome%"=="" ECHO Please set the ^<depend^> path! & PAUSE & GOTO :__Exit
IF /I "%DstPath%"=="" ECHO Please set the ^<target^> path! & PAUSE & GOTO :__Exit

IF NOT EXIST "%DevHome%" (
    ECHO DEV home path ^<%DevHome%^> not exists!
    PAUSE & GOTO :__Exit
)

IF NOT EXIST "%ZipPath%\unzip.exe" (
    ECHO "Path of 'unzip.exe' is not set, please set the <path> of 'unzip.exe':"
    SET /P ZipPath=
)
IF NOT EXIST "%ZipPath%\unzip.exe" (
    ECHO "Not found 'unzip.exe' in path <%ZipPath%>, press any key to exit!"
    PAUSE & GOTO :__Exit
)

SET BeQuiet=1

IF /I "%EnvType%"=="Debug"          SET EnvType=DLL_Debug
IF /I "%EnvType%"=="Release"        SET EnvType=DLL_Release
IF /I "%EnvType%"=="DLL_Debug"      GOTO :__Start
IF /I "%EnvType%"=="DLL_Release"    GOTO :__Start
IF /I "%EnvType%"=="LIB_Debug"      GOTO :__Start
IF /I "%EnvType%"=="LIB_Release"    GOTO :__Start

SET BeQuiet=0

::----------------------------------------------------------------------------::
:__Menu

CLS
ECHO. 
ECHO ================================================================
ECHO                选择目标环境：
ECHO                    [1] Windows x86 Debug
ECHO                    [2] Windows x86 Release
ECHO                    [3] Windows x86 Debug (Static LIB)
ECHO                    [4] Windows x86 Release (Static LIB)
ECHO                    [0] Exit
ECHO.

SET EnvType=DLL_Debug
SET /A DoWhat=1
SET /P DoWhat=  请选择(默认为1): 
ECHO.

IF %DoWhat%==0 (
    CLS
    GOTO :__Exit
) ELSE IF %DoWhat%==1 (
    SET EnvType=DLL_Debug
) ELSE IF %DoWhat%==2 (
    SET EnvType=DLL_Release
) ELSE IF %DoWhat%==3 (
    SET EnvType=LIB_Debug
) ELSE IF %DoWhat%==4 (
    SET EnvType=LIB_Release
) ELSE (
    GOTO :__Menu
)

CLS

::----------------------------------------------------------------------------::
:__Start

IF NOT EXIST %DstPath%\bin MKDIR %DstPath%\bin
IF NOT EXIST %DstPath%\lib MKDIR %DstPath%\lib
IF NOT EXIST %DstPath%\etc MKDIR %DstPath%\etc
IF NOT EXIST %DstPath%\log MKDIR %DstPath%\log
IF NOT EXIST %DstPath%\tmp MKDIR %DstPath%\tmp

ECHO.
ECHO Cleanup installed environment ...
ECHO.

::DEL /F /Q %DstPath%\lib\GC*.lib
::DEL /F /Q %DstPath%\bin\GC*.dll
::DEL /F /Q %DstPath%\lib\Any*.lib
::DEL /F /Q %DstPath%\bin\Any*.dll
::DEL /F /Q %DstPath%\bin\Any*.exe

ECHO.
ECHO Set ^<%EnvType%^> environment ...
ECHO ------------------------------------

IF /I "%EnvType%"=="DLL_Release" (
    IF EXIST %DevHome%\bin_windows\gcfl_win_x86.zip (
        %ZipPath%\unzip.exe -o %DevHome%\bin_windows\gcfl_win_x86.zip               -d %DstPath%
    )
    IF EXIST %DevHome%\bin_windows\any_win_x86.zip (
        %ZipPath%\unzip.exe -o %DevHome%\bin_windows\any_win_x86.zip                -d %DstPath%
    )
) ELSE IF /I "%EnvType%"=="DLL_Debug" (
    IF EXIST %DevHome%\bin_windows\gcfl_win_x86_dbg.zip (
        %ZipPath%\unzip.exe -o %DevHome%\bin_windows\gcfl_win_x86_dbg.zip           -d %DstPath%
    )
    IF EXIST %DevHome%\bin_windows\any_win_x86_dbg.zip (
        %ZipPath%\unzip.exe -o %DevHome%\bin_windows\any_win_x86_dbg.zip            -d %DstPath%
    )
) ELSE IF /I "%EnvType%"=="LIB_Release" (
    IF EXIST %DevHome%\bin_windows\gcfl_win_x86_static.zip (
        %ZipPath%\unzip.exe -o %DevHome%\bin_windows\gcfl_win_x86_static.zip        -d %DstPath%
    )
    IF EXIST %DevHome%\bin_windows\any_win_x86_static.zip (
        %ZipPath%\unzip.exe -o %DevHome%\bin_windows\any_win_x86_static.zip         -d %DstPath%
    )
) ELSE IF /I "%EnvType%"=="LIB_Debug" (
    IF EXIST %DevHome%\bin_windows\gcfl_win_x86_static_dbg.zip (
        %ZipPath%\unzip.exe -o %DevHome%\bin_windows\gcfl_win_x86_static_dbg.zip    -d %DstPath%
    )
    IF EXIST %DevHome%\bin_windows\any_win_x86_static_dbg.zip (
        %ZipPath%\unzip.exe -o %DevHome%\bin_windows\any_win_x86_static_dbg.zip     -d %DstPath%
    )
) ELSE (
    ECHO Invalid environment type.
    PAUSE
    GOTO :__Exit
)

%ZipPath%\unzip.exe -o %DevHome%\bin_windows\openssl_v*_win_x86.zip -d %DstPath%

IF EXIST %DevHome%\lib_windows XCOPY /E /F /Y /R /I /Q %DevHome%\lib_windows\*.lib %DstPath%\lib\ 2>NUL
IF EXIST %DevHome%\bin_windows XCOPY /E /F /Y /R /I /Q %DevHome%\bin_windows\*.dll %DstPath%\bin\ 2>NUL
IF EXIST %DevHome%\bin_windows XCOPY /E /F /Y /R /I /Q %DevHome%\bin_windows\*.exe %DstPath%\bin\ 2>NUL

ECHO.
ECHO ------------------------------------
ECHO Set ^<%EnvType%^> environment OK.
ECHO.

IF "%BeQuiet%"=="1" GOTO :__Exit
PAUSE

:__Exit

ENDLOCAL & GOTO :EOF

::------------------------------------------------------------------------------------------------::
