# Must have 7Zip and ASAR addin installed 
# Check Prerequisites
if (!(Test-Path $env:LOCALAPPDATA\slack\app-4*))
{
	if (!(Test-Path $env:LOCALAPPDATA\slack\app-3*))
	{
		if (!(Test-Path $env:LOCALAPPDATA\slack\app-2*))
		{
			[System.Windows.MessageBox]::Show('Slack version 2-4 not installed','Error: Exiting...')
			exit
		} else { $Slack_Major = 2 }
	} else { $Slack_Major = 3 }
} else { $Slack_Major = 4 }


# Get directories
$AppDirectory = Get-ChildItem -Directory -Path $env:LOCALAPPDATA\slack -Filter "app-$($Slack_Major).*" | Sort-Object LastAccessTime -Descending | Select-Object -First 1 -ExpandProperty Name
$SlackDirectory = $env:LOCALAPPDATA + "\slack\" + $AppDirectory + "\resources"

if ($Slack_Major -eq 4) {
	$7zipInstall = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip |  Select-Object -ExpandProperty InstallLocation

	# Check for 7z install
	if(!$7zipInstall)
	{
		[System.Windows.MessageBox]::Show('7zip not detected. Install 7zip and ASAR addin','Error: Exiting...')
		exit
	}

	# Check for ASAR 7z addin
	if (!(Test-Path 'C:\Program Files\7-Zip\Formats\Asar*'))
	{
		[System.Windows.MessageBox]::Show('ASAR addin must be installed. Download from: http://www.tc4shell.com/binary/Asar.zip','Error: Exiting...')
		exit
	}

	# Stop slack and Extract to temp directory
	Get-Process slack -ErrorAction SilentlyContinue | Stop-Process -PassThru
	& $7zipInstall\7z.exe x $SlackDirectory\app.asar "-o$SlackDirectory\app" -y

	$blackcss = Get-Content interjectCode.js
	Add-Content $SlackDirectory\app\dist\ssb-interop.bundle.js -Value $blackcss

	# Rename old archive
	Move-Item $SlackDirectory\app.asar $SlackDirectory\app.asar.original

	# Archive new asar
	& $7zipInstall\7z.exe a $SlackDirectory\app.asar $SlackDirectory\app
} else {
	if ($Slack_Major -lt 4) {
		$blackcss = Get-Content interjectCode.js
		Add-Content $SlackDirectory\app.asar.unpacked\src\static\index.js -Value $blackcss
		if ($Slack_Major -lt 3) {
			Add-Content $SlackDirectory\app.asar.unpacked\src\static\ssb-interop.js -Value $blackcss
		}
	}
}