set REG_KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\
set REG_WOW_KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\

setlocal ENABLEDELAYEDEXPANSION

rem OS bittness detection is taken from:
rem https://docs.microsoft.com/en-us/archive/blogs/david.wang/howto-detect-process-bitness

IF /I "%PROCESSOR_ARCHITECTURE%" == "amd64" (
  echo OS is 64bit
  echo Collecting 64bit packages info
  CALL :print_uninstall_from %REG_KEY% 64bit
  echo Collecting 32bit packages info.
  CALL :print_uninstall_from %REG_WOW_KEY% 32bit
) ELSE (
  IF /I "%PROCESSOR_ARCHITEW6432%" == "amd64" (
    echo OS is 64bit running 32bit
    echo Collecting 32bit packages info.
    CALL :print_uninstall_from %REG_KEY% 32bit
  ) ELSE (
    echo OS is 32bit
    echo Collecting 32bit packages info.
    CALL :print_uninstall_from %REG_KEY% 32bit
  )
)

goto :after_print_uninstall_from

:print_uninstall_from
SETLOCAL
SET arg1=%1
SET arg2=%2
FOR /F "usebackq delims=" %%a IN (`reg query %arg1%`) DO (
  rem echo %%a
  set display_name=
  FOR /F "usebackq delims=" %%a IN (`reg query "%%a" /v DisplayName 2^> nul ^| findstr DisplayName`) DO (
    rem echo %%a
    FOR /F "usebackq tokens=3,*" %%a IN (`echo %%a`) DO (
      set display_name=%%a %%b
    )
  )

  set display_version=
  FOR /F "usebackq delims=" %%a IN (`reg query "%%a" /v DisplayVersion 2^> nul ^| findstr DisplayVersion`) DO (
    rem echo %%a
    rem set display_version=%%a
    FOR /F "usebackq tokens=3,*" %%a IN (`echo %%a`) DO (
      set display_version=%%a %%b
    )
  )

  IF NOT [!display_name!] == [] (
    echo|set /p="Package (%arg2%): !display_name! "
    IF NOT [!display_version!] == [] (
      rem echo set /p =" a "
      echo|set /p =Version: !display_version!
    )
    echo:
  )
  rem echo|set /p="."
)

rem echo .

ENDLOCAL
EXIT /b

:after_print_uninstall_from
