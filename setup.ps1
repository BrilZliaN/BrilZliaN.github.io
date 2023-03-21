$Localization = ConvertFrom-StringData -StringData @'
UnsupportedOSBitness                      = The script supports Windows 10 x64 only
UnsupportedOSBuild                        = \nThe script supports Windows 10 22H2+
UpdateWarning                             = \nWindows 10 cumulative update installed: {0}. Supported cumulative updates: 2728 and higher. Run Windows Update and try again
UnsupportedLanguageMode                   = \nThe PowerShell session in running in a limited language mode
LoggedInUserNotAdmin                      = \nThe logged-on user doesn't have admin rights
UnsupportedPowerShell                     = \nYou're trying to run script via PowerShell {0}.{1}. Run the script in the appropriate PowerShell version
UnsupportedHost                           = \nThe script doesn't support running via {0}
Win10TweakerWarning                       = \nProbably your OS was infected via the Win 10 Tweaker backdoor
TweakerWarning                            = \nThe Windows stability may have been compromised by using {0}. Just in case, reinstall Windows
bin                                       = \nThere are no files in the bin folder. Please, re-download the archive
RebootPending                             = \nThe PC is waiting to be restarted
UnsupportedRelease                        = \nA new version found
CustomizationWarning                      = \nHave you customized every function in the {0} preset file before running Sophia Script?
DefenderBroken                            = \nMicrosoft Defender broken or removed from the OS
UpdateDefender                            = \nMicrosoft Defender definitions are out-of-date. Run Windows Update and try again
ControlledFolderAccessDisabled            = Controlled folder access disabled
ScheduledTasks                            = Scheduled tasks
OneDriveUninstalling                      = Uninstalling OneDrive...
OneDriveInstalling                        = Installing OneDrive...
OneDriveDownloading                       = Downloading OneDrive... ~33 MB
OneDriveWarning                           = The "{0}" function will be applied only if the preset is configured to remove OneDrive (or the app was already removed), otherwise the backup functionality for the "Desktop" and "Pictures" folders in OneDrive breaks
WindowsFeaturesTitle                      = Windows features
OptionalFeaturesTitle                     = Optional features
EnableHardwareVT                          = Enable Virtualization in UEFI
UserShellFolderNotEmpty                   = Some files left in the "{0}" folder. Move them manually to a new location
RetrievingDrivesList                      = Retrieving drives list...
DriveSelect                               = Select the drive within the root of which the "{0}" folder will be created
CurrentUserFolderLocation                 = The current "{0}" folder location: "{1}"
UserFolderRequest                         = Would you like to change the location of the "{0}" folder?
UserFolderSelect                          = Select a folder for the "{0}" folder
UserDefaultFolder                         = Would you like to change the location of the "{0}" folder to the default value?
ReservedStorageIsInUse                    = This operation is not supported when reserved storage is in use\nPlease re-run the "{0}" function again after PC restart
ShortcutPinning                           = The "{0}" shortcut is being pinned to Start...
UninstallUWPForAll                        = For all users
UWPAppsTitle                              = UWP Apps
HEVCDownloading                           = Downloading HEVC Video Extensions from Device Manufacturer... ~2,8 MB
GraphicsPerformanceTitle                  = Graphics performance preference
GraphicsPerformanceRequest                = Would you like to set the graphics performance setting of an app of your choice to "High performance"?
ScheduledTaskPresented                    = The "{0}" function was already created as "{1}"
CleanupTaskNotificationTitle              = Windows clean up
CleanupTaskNotificationEvent              = Run task to clean up Windows unused files and updates?
CleanupTaskDescription                    = Cleaning up Windows unused files and updates using built-in Disk cleanup app
CleanupNotificationTaskDescription        = Pop-up notification reminder about cleaning up Windows unused files and updates
SoftwareDistributionTaskNotificationEvent = Windows update cache successfully deleted
TempTaskNotificationEvent                 = Temporary files folder successfully cleaned up
FolderTaskDescription                     = The {0} folder cleanup
EventViewerCustomViewName                 = Process Creation
EventViewerCustomViewDescription          = Process creation and command-line auditing events
RestartWarning                            = Make sure to restart your PC
ErrorsLine                                = Line
ErrorsMessage                             = Errors/Warnings
DialogBoxOpening                          = Displaying the dialog box...
Disable                                   = Disable
EXEFilesFilter                            = *.exe|*.exe|All Files (*.*)|*.*
FolderSelect                              = Select a folder
FilesWontBeMoved                          = Files will not be moved
Install                                   = Install
NoData                                    = Nothing to display
NoInternetConnection                      = No Internet connection
RestartFunction                           = Please re-run the "{0}" function
NoResponse                                = A connection could not be established with {0}
Restore                                   = Restore
Run                                       = Run
Skipped                                   = Skipped
GPOUpdate                                 = Updating GPO...
TelegramGroupTitle                        = Join our official Telegram group
TelegramChannelTitle                      = Join our official Telegram channel
DiscordChannelTitle                       = Join our official Discord channel
Uninstall                                 = Uninstall
'@

function GetDownloadFolder
{
	Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
}

function DownloadFile
{
	param
	(
		[string]
		$Uri,

		[string]
		$File
	)

	try
	{
		# Check the internet connection
		$Parameters = @{
			Uri              = "https://www.google.com"
			Method           = "Head"
			DisableKeepAlive = $true
			UseBasicParsing  = $true
		}
		if (-not (Invoke-WebRequest @Parameters).StatusDescription)
		{
			return
		}
	}
	catch [System.Net.WebException]
	{
		Write-Warning -Message $Localization.NoInternetConnection
		Write-Error -Message $Localization.NoInternetConnection -ErrorAction SilentlyContinue
		Write-Error -Message ($Localization.RestartFunction -f $MyInvocation.Line.Trim()) -ErrorAction SilentlyContinue

		return
	}

    $DownloadsFolder = GetDownloadFolder
	$Parameters = @{
		Uri             = $Uri
		OutFile         = "$DownloadsFolder\$File"
		UseBasicParsing = $true
		Verbose         = $true
	}
	Invoke-WebRequest @Parameters
}

<#
	.SYNOPSIS
	"HEVC Video Extensions from Device Manufacturer" extension

	.PARAMETER Install
	Download and install the "HEVC Video Extensions from Device Manufacturer" extension

	.PARAMETER Manually
	Open Microsoft Store "HEVC Video Extensions from Device Manufacturer" page to install the extension manually

	.EXAMPLE
	HEVC -Install

	.EXAMPLE
	HEVC -Manually

	.LINK
	https://www.microsoft.com/store/productId/9n4wgh0z6vhq

	.NOTES
	The extension can be installed without Microsoft account

	.NOTES
	HEVC Video Extension is already installed in Windows 11 22H2 by default

	.NOTES
	Current user
#>
function HEVC
{
	param
	(
		[Parameter(
			Mandatory = $true,
			ParameterSetName = "Install"
		)]
		[switch]
		$Install,

		[Parameter(
			Mandatory = $true,
			ParameterSetName = "Manually"
		)]
		[switch]
		$Manually
	)

	# Check whether the extension is already installed
	if ((-not (Get-AppxPackage -Name Microsoft.Windows.Photos)) -or (Get-AppxPackage -Name Microsoft.HEVCVideoExtension))
	{
		return
	}

	try
	{
		# Check the internet connection
		$Parameters = @{
			Uri              = "https://www.google.com"
			Method           = "Head"
			DisableKeepAlive = $true
			UseBasicParsing  = $true
		}
		if (-not (Invoke-WebRequest @Parameters).StatusDescription)
		{
			return
		}
	}
	catch [System.Net.WebException]
	{
		Write-Warning -Message $Localization.NoInternetConnection
		Write-Error -Message $Localization.NoInternetConnection -ErrorAction SilentlyContinue
		Write-Error -Message ($Localization.RestartFunction -f $MyInvocation.Line.Trim()) -ErrorAction SilentlyContinue

		return
	}

	switch ($PSCmdlet.ParameterSetName)
	{
		"Install"
		{
			try
			{
				# Write-Output -Message "hello1"
				# Check whether https://store.rg-adguard.net is alive
				$Parameters = @{
					Uri              = "https://store.rg-adguard.net/api/GetFiles"
					Method           = "Head"
					DisableKeepAlive = $true
					UseBasicParsing  = $true
					Verbose          = $true
				}
				if (-not (Invoke-WebRequest @Parameters).StatusDescription)
				{
					return
				}

				$Body = @{
					type = "url"
					url  = "https://www.microsoft.com/store/productId/9n4wgh0z6vhq"
					ring = "Retail"
					lang = "en-US"
				}
				$Parameters = @{
					Uri             = "https://store.rg-adguard.net/api/GetFiles"
					Method          = "Post"
					ContentType     = "application/x-www-form-urlencoded"
					Body            = $Body
					UseBasicParsing = $true
					Verbose         = $true
				}
				$Raw = Invoke-WebRequest @Parameters
				# Parsing the page
				$Raw | Select-String -Pattern '<tr style.*<a href=\"(?<url>.*)"\s.*>(?<text>.*)<\/a>' -AllMatches | ForEach-Object -Process {$_.Matches} | ForEach-Object -Process {
					$TempURL = ($_.Groups | Select-Object -Index 1).Value
					$HEVCPackageName = ($_.Groups | Select-Object -Index 2).Value.Split("_") | Select-Object -Index 1
					$Ext = ($_.Groups | Select-Object -Index 2).Value.Split(".") | Select-Object -Last 1
					if ($Ext -eq "appxbundle") {
						# Installing "HEVC Video Extensions from Device Manufacturer"
						if ([System.Version]$HEVCPackageName -gt [System.Version](Get-AppxPackage -Name Microsoft.HEVCVideoExtension).Version)
						{
							Write-Information -MessageData "" -InformationAction Continue
							Write-Verbose -Message $Localization.HEVCDownloading -Verbose

							$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
							# Write-Output $DownloadsFolder\Microsoft.HEVCVideoExtension_8wekyb3d8bbwe.appxbundle
							$Parameters = @{
								Uri             = $TempURL
								OutFile         = "$DownloadsFolder\Microsoft.HEVCVideoExtension_8wekyb3d8bbwe.appxbundle"
								UseBasicParsing = $true
								Verbose         = $true
							}
							Invoke-WebRequest @Parameters

							Add-AppxPackage -Path "$DownloadsFolder\Microsoft.HEVCVideoExtension_8wekyb3d8bbwe.appxbundle" -Verbose
							Remove-Item -Path "$DownloadsFolder\Microsoft.HEVCVideoExtension_8wekyb3d8bbwe.appxbundle" -Force
						}
					}
				}
			}
			catch [System.Net.WebException]
			{
				Write-Warning -Message ($Localization.NoResponse -f "https://store.rg-adguard.net/api/GetFiles")
				Write-Error -Message ($Localization.NoResponse -f "https://store.rg-adguard.net/api/GetFiles") -ErrorAction SilentlyContinue

				Write-Error -Message ($Localization.RestartFunction -f $MyInvocation.Line.Trim()) -ErrorAction SilentlyContinue
			}
		}
		"Manually"
		{
			Start-Process -FilePath ms-windows-store://pdp/?ProductId=9n4wgh0z6vhq
		}
	}
}

function GetLocaleCode
{
	$SystemLocale = Get-WinSystemLocale
	$SystemLocaleCode = $SystemLocale[0].LCID
	$SystemLocaleCode
}

function InstallApp
{
	param
	(
		[string]
		$Uri,

		[string]
		$File,
		
		[string]
		$Arguments
	)
	$DownloadsFolder = GetDownloadFolder
	DownloadFile $Uri $File
    Start-Process -FilePath "$DownloadsFolder\$File" -Args $Arguments -Verb RunAs -Wait -Verbose
	Remove-Item -Path "$DownloadsFolder\$File" -Force
}

function InstallMsi
{
	param
	(
		[string]
		$Uri,

		[string]
		$File
	)
	$DownloadsFolder = GetDownloadFolder
	DownloadFile $Uri $File
	Start-Process msiexec.exe -ArgumentList '/I $DownloadsFolder\$File /quiet' -Wait -Verbose
	Remove-Item -Path "$DownloadsFolder\$File" -Force
}

function InstallChrome
{
	InstallApp "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" "chrome_installer.exe" "/silent /install"
}

function Install7Zip
{
	$Version = "2201"
	InstallApp "https://www.7-zip.org/a/7z$Version-x64.exe" "7z$Version-x64.exe" "/S"
}

function InstallVLC
{
	$Version = "3.0.18"
	$LocaleCode = GetLocaleCode
	# Write-Output $LocaleCode
	InstallApp "https://get.videolan.org/vlc/$Version/win64/vlc-$Version-win64.exe" "vlc-$Version-win64.exe" "/S /L=$LocaleCode"
}

function InstallNotepadPlusPlus
{
	$Version = "8.5"
	InstallApp "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v$Version/npp.$Version.Installer.x64.exe" "npp.$Version.Installer.x64.exe" "/S"
}

function InstallJDK8
{
	$Version = "8u362+9"
	InstallMsi "https://download.bell-sw.com/java/$Version/bellsoft-jdk$Version-windows-amd64-full.msi" "bellsoft-jdk$Version-windows-amd64-full.msi"
}

function InstallJDK17
{
	$Version = "17.0.6+10"
	InstallMsi "https://download.bell-sw.com/java/$Version/bellsoft-jdk$Version-windows-amd64-full.msi" "bellsoft-jdk$Version-windows-amd64-full.msi"
}

function InstallDiscord
{
	InstallApp "https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win&arch=x86" "DiscordSetup.exe" "-s"
}

function InstallShareX
{
	$Version = "15.0.0"
	InstallApp "https://github.com/ShareX/ShareX/releases/download/v$Version/ShareX-$Version-setup.exe" "ShareX-$Version-setup.exe" "/VERYSILENT /NORUN"
}

function InstallOBS
{
	$Version = "29.0.2"
	InstallApp "https://github.com/obsproject/obs-studio/releases/download/$Version/OBS-Studio-$Version-Full-Installer-x64.exe" "OBS-Studio-$Version-Full-Installer-x64.exe" "/S"
}

function InstallTransmission
{
	$Version = "4.0.2"
	InstallMsi "https://github.com/transmission/transmission/releases/download/$Version/transmission-$Version-x64.msi" "transmission-$Version-x64.msi"
}

# Install everything:
HEVC -Install
InstallChrome
Install7Zip
InstallVLC
InstallNotepadPlusPlus
InstallJDK8
InstallJDK17
InstallDiscord
InstallShareX
InstallOBS
InstallTransmission
