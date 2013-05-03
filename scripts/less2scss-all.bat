@echo off

set source_dir=static\less
set target_dir=static\sass

set main=bootstrapSwitch.less
set deps=deps\*.less

cd "%~dp0.."

for %%f in (%source_dir%\%main%) do call "%~dp0less2scss" "%%~f" "" "%source_dir%" "%target_dir%" || exit /b 1
for %%f in (%source_dir%\%deps%) do call "%~dp0less2scss" "%%~f" "" "%source_dir%" "%target_dir%" _ || exit /b 1

cp -uv static\stylesheets\bootstrapSwitch.css static\stylesheets\bootstrapSwitch.scss || exit /b 1
