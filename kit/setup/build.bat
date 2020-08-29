::------------------------------------------------------------------------------------------------::

@ECHO OFF

CALL :__Build %*

GOTO :EOF

::------------------------------------------------------------------------------------------------::

:__Build <Project> <DevHome> <DstPath> <EnvType>
::
::      -- Use:
::      --   CALL :__Build Project DevHome [EnvType]
::      -- Args:
::      --   %1: Project name.
::      --   %2: DEV home.
::      --   %3: Tagret path.
::      --   %4: Environment type.
::
SETLOCAL

SET Project=%1
SET DevHome=%2
SET DstPath=%3
SET EnvType=%4
SET Builder=%DevHome%\make\windows\Build_VS2008.bat
SET Result=1

IF /I        "%Project%"==""    ECHO Please set the ^<project^> file!        & PAUSE & GOTO :__Exit
IF /I        "%DevHome%"==""    ECHO Please set the ^<depend^> path!         & PAUSE & GOTO :__Exit
IF /I        "%DstPath%"==""    ECHO Please set the ^<target^> path!         & PAUSE & GOTO :__Exit
IF NOT EXIST "%Project%"        ECHO Project file ^<%Project%^> not exists!  & PAUSE & GOTO :__Exit
IF NOT EXIST "%DevHome%"        ECHO DEV home path ^<%DevHome%^> not exists! & PAUSE & GOTO :__Exit

SET BeQuiet=1

IF /I "%EnvType%"=="Debug"      GOTO :__Start
IF /I "%EnvType%"=="Release"    GOTO :__Start

SET BeQuiet=0

::----------------------------------------------------------------------------::
:__Menu

CLS
ECHO. 
ECHO ================================================================
ECHO                选择目标环境：
ECHO                    [1] Windows x86 Debug
ECHO                    [2] Windows x86 Release
ECHO                    [0] Exit
ECHO.

SET EnvType=Debug
SET /A DoWhat=1
SET /P DoWhat=  请选择(默认为1): 
ECHO.

IF %DoWhat%==0 (
    CLS
    GOTO :__Exit
) ELSE IF %DoWhat%==1 (
    SET EnvType=Debug
) ELSE IF %DoWhat%==2 (
    SET EnvType=Release
) ELSE (
    GOTO :__Menu
)

CLS

::----------------------------------------------------------------------------::
:__Start

CALL %~dp0setenv.bat %DevHome% %DstPath% %EnvType%

CALL %Builder% Result %Project% Win32 %EnvType% ShowWarning

::----------------------------------------------------------------------------::

IF "%BeQuiet%"=="1" GOTO :__Exit
PAUSE

:__Exit

ENDLOCAL & GOTO :EOF

::------------------------------------------------------------------------------------------------::
