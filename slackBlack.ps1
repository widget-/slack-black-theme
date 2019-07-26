# Created by: Anthony Northrup
# Based on: https://github.com/tarantulae/slack-black-theme-4.0PS
#    Originally linked: https://github.com/widget-/slack-black-theme/issues/98#issuecomment-512283114
# Extended by: Nockiro

# Modify the interjectCode.js for the theme
# Current snippet from: https://github.com/Nockiro/slack-black-theme/blob/master/interjectCode.js

# Required for MessageBox
Add-Type -AssemblyName System.Windows.Forms

# Ensure Slack version 4 or later is installed
$SlackRoot = $env:LOCALAPPDATA + "\slack"
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

$AppVersion = Get-ChildItem -Directory -Path $SlackRoot -Filter "app-$($Slack_Major)*" | Sort-Object LastAccessTime -Descending | Select-Object -First 1 -ExpandProperty Name
$SlackResources = $SlackRoot + "\" + $AppVersion + "\resources"

# Locate 7-Zip
$7zipRoot = Get-ItemProperty HKLM:\Software\7-Zip | Select-Object -ExpandProperty Path
if (!$7zipRoot)
{
	$7zipRoot = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip |  Select-Object -ExpandProperty InstallLocation
}
if (!$7zipRoot -or !(Test-Path "$7zipRoot\7z.exe"))
{
	[System.Windows.Forms.MessageBox]::Show("7-Zip not detected", "Error: Exiting...");
	exit
}

# Ensure the ASAR add-in is installed
if (!(Test-Path "$7zipRoot\Formats\Asar*"))
{
	[System.Windows.Forms.MessageBox]::Show("ASAR add-in must be installed. Download from: http://www.tc4shell.com/en/7zip/asar/", "Error: Exiting...")
	exit
}

# Stop Slack
Get-Process slack -ErrorAction SilentlyContinue | Stop-Process -PassThru

# Already have a backup? Might want to restore
if ((Test-Path "$SlackResources\app.asar.backup") -or (Test-Path "$SlackResources\app.asar.unpacked\src\static\index.js.backup") -or (Test-Path "$SlackResources\app.asar.unpacked\src\static\ssb-interop.backup"))
{
	$result = [System.Windows.Forms.MessageBox]::Show("A backup of the app already exists, do you want to remove the custom theme and restore to the previous version?", "Remove custom theme?", [System.Windows.Forms.MessageBoxButtons]::YesNoCancel, [System.Windows.Forms.MessageBoxIcon]::Question)
	if ($result -eq [System.Windows.Forms.DialogResult]::Yes)
	{
		if ($Slack_Major -gt 1) {
			echo "Restoring for Slack 2+.."		
			Move-Item -Force $SlackResources\app.asar.unpacked\src\static\index.js.backup $SlackResources\app.asar.unpacked\src\static\index.js

			if ($Slack_Major -gt 2) {			
				echo "Restoring for Slack 3.."		
				Move-Item -Force $SlackResources\app.asar.unpacked\src\static\ssb-interop.js.backup $SlackResources\app.asar.unpacked\src\static\ssb-interop.js
			}
		} else {
			# Restore the backup
			Move-Item -Force $SlackResources\app.asar.backup $SlackResources\app.asar
		}
	

		# Start slack again
		& $SlackRoot\slack.exe

		# Prevent further execution
		exit
	}
	elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel)
	{
		exit
	}
}


# Get interject content from file
$customThemeJS = Get-Content interjectCode.js

# Copy the archive to a temp folder
$tempDir = "C:\temp\SlackBlackTheme_Temp"
if (!(Test-Path $tempDir))
{
	New-Item -Path $tempDir -ItemType Directory
}

$oldLocation = Get-Location
Set-Location $tempDir

if ($Slack_Major -eq 4) {
	Copy-Item $SlackResources\app.asar .

	# Extract ssb-interop
	& $7zipRoot\7z.exe e app.asar -odist dist\ssb-interop.bundle.js -y

	# Append the custom JS code as instructed: https://github.com/Nockiro/slack-black-theme
	Add-Content dist\ssb-interop.bundle.js -Value $customThemeJS

	# Backup already exists?
	$updateFiles = $TRUE
	if (Test-Path "$SlackResources\app.asar.backup")
	{
		$updateFiles = $FALSE
		$result = [System.Windows.Forms.MessageBox]::Show("A backup of the app already exists, do you want to overwrite?", "Warning: Backup exists", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
		if ($result -eq [System.Windows.Forms.DialogResult]::Yes)
		{
			$updateFiles = $TRUE
		}
	}

	# Actually update the files
	if ($updateFiles)
	{
		# Update the modified files in the archive
		& $7zipRoot\7z.exe u app.asar dist\ssb-interop.bundle.js
		
		# Backup the old archive
		Copy-Item $SlackResources\app.asar $SlackResources\app.asar.backup
		
		# Copy the new archive
		Copy-Item app.asar $SlackResources
	}
} else {
	
	# Backup already exists?
	$updateFiles = $TRUE
	if ((Test-Path "$SlackResources\app.asar.unpacked\src\static\index.js.backup") -or (Test-Path "$SlackResources\app.asar.unpacked\src\static\ssb-interop.backup"))
	{
		$updateFiles = $FALSE
		$result = [System.Windows.Forms.MessageBox]::Show("A backup of the app already exists, do you want to overwrite?", "Warning: Backup exists", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
		if ($result -eq [System.Windows.Forms.DialogResult]::Yes)
		{
			$updateFiles = $TRUE
		}
	}
	
	Copy-Item $SlackResources\app.asar.unpacked\src\static\index.js .
	Copy-Item $SlackResources\app.asar.unpacked\src\static\ssb-interop.js .
	if ($updateFiles) {
		if ($Slack_Major -gt 1) {
			echo "Adding code for slack 2+"
			Add-Content $SlackResources\app.asar.unpacked\src\static\index.js -Value $customThemeJS
			
			# Backup old index file
			Copy-Item .\index.js $SlackResources\app.asar.unpacked\src\static\index.js.backup
			if ($Slack_Major -gt 2) {			
				echo "Adding code for slack 3"
				Add-Content $SlackResources\app.asar.unpacked\src\static\ssb-interop.js -Value $customThemeJS
				
				#Backup old ssb-interop file
				Copy-Item .\ssb-interop.js $SlackResources\app.asar.unpacked\src\static\ssb-interop.js.backup
			}
		}
	}
}

# Remove the temp files
Set-Location $oldLocation
Remove-Item -Recurse -Path $tempDir

# Start slack again
& $SlackRoot\slack.exe
