@echo off

rem Download Wazuh agent installer (ensure valid version)
powershell -ExecutionPolicy Bypass -NoProfile -Command "& { Invoke-WebRequest -Uri 'https://packages.wazuh.com/4.x/windows/wazuh-agent-4.8.0-1.msi' -OutFile '$env:TEMP\wazuh-agent.msi' }"

if exist "%TEMP%\wazuh-agent.msi%" (
    echo Downloaded Wazuh agent installer successfully.

    rem Install Wazuh agent silently with specified settings
    msiexec.exe /i "%TEMP%\wazuh-agent.msi" /q /norestart WAZUH_MANAGER='121.58.248.25' WAZUH_AGENT_GROUP='default'

    if errorlevel 1 (
        echo Error occurred during installation. Check the logs for details.
        exit /b 1
    ) else (
        echo Installation successful.
		
		copy "remove-threat.exe" "C:\Program Files (x86)\ossec-agent\active-response\bin"
		copy "disableuseraccount.cmd" "C:\Program Files (x86)\ossec-agent\active-response\bin"
		copy "disableuseraccount.ps1" "C:\Program Files (x86)\ossec-agent\active-response\bin"
		copy "domainsinkhole.cmd" "C:\Program Files (x86)\ossec-agent\active-response\bin"
		copy "domainsinkhole.ps1" "C:\Program Files (x86)\ossec-agent\active-response\bin"
		copy "otx.cmd" "C:\Program Files (x86)\ossec-agent\active-response\bin"
		copy "windowsfirewall.cmd" "C:\Program Files (x86)\ossec-agent\active-response\bin"
		copy "wazuh\windowsfirewall.ps1" "C:\Program Files (x86)\ossec-agent\active-response\bin"
		copy "yara.bat" "C:\Program Files (x86)\ossec-agent\active-response\bin"
		mkdir "C:\Program Files (x86)\ossec-agent\active-response\bin\yara\"
		copy "yara64.exe" "C:\Program Files (x86)\ossec-agent\active-response\bin\yara\"
		mkdir "C:\Program Files (x86)\ossec-agent\active-response\bin\yara\rules"
        copy "yara_rules.yar" "C:\Program Files (x86)\ossec-agent\active-response\bin\yara\rules"
		
		"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -executionpolicy ByPass -File ".\sysmon_install.ps1"
		if %errorlevel% neq 0 (
			echo PowerShell script failed.
		) else (
			echo PowerShell script executed successfully.
			copy "sigcheck.ps1" "C:\Program Files\sysinternals"
			copy "otx.ps1" "C:\Program Files\sysinternals"
		)


        rem Start Wazuh service with retry logic
        net start WazuhSvc
        if errorlevel 1 (
            echo Starting Wazuh service failed on first attempt. Retrying...
            ping 127.0.0.1 > NUL  rem Short pause to allow service to settle
            net start WazuhSvc
            if errorlevel 1 (
                echo Failed to start Wazuh service even after retry.
                exit /b 1
            )
        )

        echo Wazuh service started successfully.
    )
) else (
    echo Error: Failed to download Wazuh agent installer. Check the URL and connection.
    exit /b 1
)
