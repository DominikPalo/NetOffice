@echo off
setlocal EnableDelayedExpansion

set _version=1.8.0
set _suffix=alpha01
::  goIT Solutions, s.r.o. certificate
set _certificate=goIT Solutions, s.r.o.
set _thumbprint=AC6DBFFB1BF8B62281DEB8641023A66CDDC5DB57

mkdir out

xcopy /s /e /y Documentation out\Documentation\
xcopy /s /e /y Examples out\Examples\
xcopy /s /e /y Tutorials out\Tutorials\
xcopy /s /e /y Source out\Source\

msbuild Source\NetOffice.sln /t:Restore;Build;Pack /p:IncludeSource=true /p:Configuration=Release /p:VersionSuffix="%_suffix%" /p:PackageOutputPath="%CD%\out" /v:m
nuget.exe sign "out\*.nupkg" -CertificateFingerprint "%_thumbprint%" -HashAlgorithm SHA256 -Timestamper http://timestamp.comodoca.com -TimestampHashAlgorithm SHA256 -Overwrite -OutputDirectory out -NonInteractive -ForceEnglishOutput

del /s /q Source\ClientApplication\bin\Release\ClientApplication.*
del /s /q Source\ClientApplication\bin\Release\stdole.dll

xcopy /y Source\ClientApplication\bin\Release "out\Assemblies\Any CPU\"
signtool.exe sign /v /fd sha256 /td sha256 /sha1 "%_thumbprint%" /tr http://timestamp.comodoca.com/rfc3161 "out\Assemblies\Any CPU\*.dll"

rem del /s /q Source\ClientApplication\bin\Release\ClientApplication.*
rem del /s /q Source\ClientApplication\bin\Release\*\stdole.dll

xcopy /y /s /i /e Source\ClientApplication\bin\Release "out\Assemblies\"

xcopy /y "Breaking Changes.txt" out\
xcopy /y BugFixes.txt out\
xcopy /y ChangeLog.txt out\
xcopy /y LICENSE.txt out\

pushd out
7z a -tzip ..\NetOffice_v%_version%-%_suffix%.zip .
popd
