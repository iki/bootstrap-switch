@echo off
::|
::|LESS to SCSS conversion
::|
::|Usage: less2scss <input >output
::|       less2scss source [target] [source-dir] [target-dir] [prefix]
::|
::|Rules: https://github.com/jlong/sass-twitter-bootstrap#sass-conversion-quick-tips
::|
::|Requires GNU SED, e.g. from MSys, MSysGit or GnuWin32.
::|
::|  See http://mingw.org/wiki/msys, or http://msysgit.googlecode.com,
::|  or http://gnuwin32.sourceforge.net/packages/sed.htm.
::|

setlocal enableextensions

if "%~1"=="--help" call :usage %0 && exit /b || exit /b 1

call :init && call :less2scss %* && exit /b || exit /b 1

:init
  set rules=""
  set rules="%rules:"=%s/@\([A-Za-z_][A-Za-z0-9_]*\)/\$\1/g;"
  ::    @VAR  ->  $VAR
  set rules="%rules:"=%s/^\( *$[A-Za-z_][A-Za-z0-9_]*:.*\);$/\1 !default;/g;"
  ::    @VAR: VALUE;  ->  $VAR: VALUE !default;
  set rules="%rules:"=%s/\.\([A-Za-z_][-A-Za-z0-9_]* *(.*) *{\)/@mixin \1/g;"
  ::    .MIXIN(ARGS) {  ->  @mixin MIXIN(ARGS) {
  set rules="%rules:"=%s/#\(gradient\|grid\|font\) *> *\.\([A-Za-z_][-A-Za-z0-9_]* *(.*)\)/@include \1-\2/g;"
  ::    #gradient|grid|font > .MIXIN(ARGS)  ->  @include gradient|grid|font-MIXIN(ARGS)
  set rules="%rules:"=%s/\.\([A-Za-z_][-A-Za-z0-9_]* *(.*)\)/@include \1/g;"
  ::    .MIXIN(ARGS)  ->  @include MIXIN(ARGS)
  set rules="%rules:"=%s/\bfadein\((.*)\)/fade-in\1/g;"
  ::    fadein(ARGS)  ->  fade-in(ARGS)
  set rules="%rules:"=%s/\bspin\((.*)\)/adjust-hue\1/g;"
  ::    spin(ARGS)  ->  adjust-hue(ARGS)
  set rules="%rules:"=%s/\t/  /g;"
  ::    TAB  ->  2 SPACES
  exit /b %errorlevel%

:less2scss
  setlocal

  if "%~1"=="" sed %rules% && exit /b || exit /b 1

  set source=%~1
  set target=%~2
  set source_dir=%~3
  set target_dir=%~4
  set prefix=%~5

  if not exist "%source%" echo "Invalid less input file: '%source%'" >&2 && exit /b 1 || exit /b 1

  if defined target goto :l2s_target
    :: set target="%~3%~nx1"
    call :eval set target^=%%source:%source_dir%=%target_dir%%% || exit /b 1
    if not defined target exit /b 1
    set target=%target:.less=.scss%
    if defined prefix call :insert_prefix target "%target%" "%prefix%" || exit /b 1
    :l2s_target

  if "%source%"== "%target%" echo "Target other than source is required: '%source%'" >&2 && exit /b 1 || exit /b 1

  echo === less2scss ^< "%source%" ^> "%target%" >&2

  call :create_parent_dir "%target%" || exit /b 1

  sed %rules% < "%source%" > "%target%"

  exit /b %errorlevel%


:create_parent_dir
if not exist "%~dp1" md "%~dp1"
exit /b %errorlevel%

:eval
%*
exit /b %errorlevel%

:insert_prefix
set %1=%~dp2%~3%~nx2
exit /b %errorlevel%

:usage
  if "%~1"=="" echo Script file is required: usage %* >&2 && exit /b 2 || exit /b 1
  setlocal
  for %%v in (%*) do if not "%%~v"=="%~1" set %%~v
  for /f "usebackq delims=| tokens=1*" %%l in ("%~1") do if "%%~l"=="::" call :eval echo.%%~m
  exit /b %errorlevel%
