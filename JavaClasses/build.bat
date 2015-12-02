@echo off
if '%1'=='?' goto Usage
if '%1'=='/?' goto Usage
if /I '%1'=='h' goto Usage
if /I '%1'=='/h' goto Usage

REM ----------------------------------------------------------------------------
REM -- VARIABLES
REM ----------------------------------------------------------------------------

if x%ANDROID% == x set ANDROID=D:\sdk\asdk
set ANDROID_PLATFORM=%ANDROID%\platforms\android-17
set DX_PATH=%ANDROID%\build-tools\21.1.2
set DX_LIB=%DX_PATH%\lib
set EMBO_DEX=D:\cb9\lib\android\debug\classes.dex
set JAVA_PATH="C:\Program Files\Java\jdk1.7.0_71\bin"
set OUT_PATH=..\classes

REM ----------------------------------------------------------------------------
REM -- Vars check
REM ----------------------------------------------------------------------------
setlocal
echo Configuring...
if not exist %ANDROID%/nul (
  echo ERROR: Please set ANDROID variable!
  goto Exit
)
if not exist %ANDROID_PLATFORM%/nul (
  echo ERROR: Please correct ANDROID_PLATFORM variable
  goto Exit
)
if not exist %DX_PATH%/nul (
  echo ERROR: Please correct DX_PATH variable to point Android build tools
  goto Exit
)
if not exist %DX_LIB%/nul (
  echo ERROR: Please correct DX_LIB variable to point Android build LIB dir
  goto Exit
)
if not exist %EMBO_DEX% (
  echo ERROR: Please correct EMBO_DEX variable to point BDS classes.dex file
  goto Exit
)
if not exist %JAVA_PATH%/javac.exe (
  echo ERROR: Please correct JAVA_PATH variable to point JAVAC.EXE
  goto Exit
)
if not exist %OUT_PATH%\nul mkdir %OUT_PATH% 2> nul

REM ----------------------------------------------------------------------------
REM -- Internal options
REM ----------------------------------------------------------------------------
set PROJ_DIR=%CD%
set VERBOSE=0

if /I '%1' == 'V' set VERBOSE=1
if /I '%1' == '/V' set VERBOSE=1

REM ----------------------------------------------------------------------------
REM -- Actions
REM ----------------------------------------------------------------------------
echo Compiling the Java Sources...

mkdir output 2> nul
mkdir output\classes 2> nul

if x%VERBOSE% == x1 SET VERBOSE_FLAG=-verbose
%JAVA_PATH%\javac %VERBOSE_FLAG% -Xlint:deprecation -cp %ANDROID_PLATFORM%\android.jar -d output\classes ^
src\com\dpfaragir\DPFActivity.java ^
src\com\dpfaragir\DPFTextView.java ^
src\com\dpfaragir\DPFUtils.java ^
src\com\dpfaragir\DPFVideoView.java ^
src\com\dpfaragir\http\DPFHTTP.java ^
src\com\dpfaragir\http\DPFOnHTTPListener.java ^
src\com\dpfaragir\webview\DPFOnWebViewListener.java ^
src\com\dpfaragir\webview\DPFWebClient.java ^
src\com\dpfaragir\webview\DPFWebView.java ^
src\com\dpfaragir\listview\DPFListView.java ^
src\com\dpfaragir\listview\DPFOnListViewListener.java ^
src\com\dpfaragir\Animation\DPFOnAnimationListener.java ^
src\com\dpfaragir\Animation\DPFAnimation.java
if NOT x%ERRORLEVEL%==x0 (
  echo ERROR: error compiling java sources. Try to set verbose mode.
  goto Usage
)

echo Creating jar containing the new classes...

mkdir output\jar 2> nul

if x%VERBOSE% == x1 SET VERBOSE_FLAG=v
%JAVA_PATH%\jar c%VERBOSE_FLAG%f output\jar\test_classes.jar -C output\classes com
if NOT x%ERRORLEVEL%==x0 (
  echo ERROR: error creating JAR. Try to set verbose mode.
  goto Usage
)

echo Converting from jar to dex...
mkdir output\dex 2> nul
if x%VERBOSE% == x1 SET VERBOSE_FLAG=--verbose
call %DX_LIB%\dx.jar --dex %VERBOSE_FLAG% --output=%PROJ_DIR%\output\dex\test_classes.dex --positions=lines %PROJ_DIR%\output\jar\test_classes.jar

echo Merging dex files...
%JAVA_PATH%\java -cp %DX_LIB%\dx.jar com.android.dx.merge.DexMerger %PROJ_DIR%\output\dex\classes.dex %PROJ_DIR%\output\dex\test_classes.dex %EMBO_DEX%

del output\classes\com\dpfaragir\*.class
rmdir output\classes\com\dpfaragir /s /q
rmdir output\classes\com /s /q
rmdir output\classes /s /q
del output\dex\test_classes.dex
del output\jar\test_classes.jar
rmdir output\jar /s /q

echo Copy created classes to "%OUT_PATH%\classes.dex"
copy /Y output\dex\classes.dex %OUT_PATH%\classes.dex

echo All done!
echo Do not forget to read "Install.txt" to usage instructions
echo Good luck :)
goto Exit

:Usage
echo ----------------------------------------------------------------------------
echo USAGE: BUILD.BAT [/]OPTIONS
echo   Where OPTIONS are:
echo      v - be verbose
echo      h - display help screen
echo Before usage you need to correct variables at start of file in VARIABLES section.
echo You need to set:
echo   1. Correct variables to point correct paths in your environment
echo   2. Set correct path to JAVAC.EXE
echo ----------------------------------------------------------------------------

:Exit
endlocal
