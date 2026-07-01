:: Simple script to run Windows Firewall Block
:: The script executes a powershell script and appends output.
@ECHO OFF
ECHO.

"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -executionpolicy ByPass -File "C:\Program Files (x86)\ossec-agent\active-response\bin\windowsfirewall.ps1"

:Exit
