$architecture = $Env:PROCESSOR_ARCHITECTURE

if ($architecture -eq "AMD64") {
    Write-Host "Architecture: x64 (AMD64)"
} elseif ($architecture -eq "ARM64") {
    Write-Host "Architecture: ARM64"
} else {
    Write-Host "Unknown architecture: $architecture"
}

# List of URLs with a secondary property for filename
$urls = @{
    "AMD64" = @(
        @{ Url = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"; FileName = "Microsoft.VCLibs.x64.14.00.Desktop.appx" },
        @{ Url = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx"; FileName = "Microsoft.UI.Xaml.2.8.x64.appx" },
        @{ Url = "https://github.com/microsoft/terminal/releases/download/v1.20.11381.0/Microsoft.WindowsTerminal_1.20.11381.0_8wekyb3d8bbwe.msixbundle"; FileName = "Microsoft.WindowsTerminal_1.20.11381.0_8wekyb3d8bbwe.msixbundle" },
        @{ Url = "https://aka.ms/getwinget"; FileName = "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" }
    )
    "ARM64" = @(
        @{ Url = "https://aka.ms/Microsoft.VCLibs.arm64.14.00.Desktop.appx"; FileName = "Microsoft.VCLibs.arm64.14.00.Desktop.appx" },
        @{ Url = "https://globalcdn.nuget.org/packages/microsoft.ui.xaml.2.8.6.nupkg"; FileName = "microsoft.ui.xaml.2.8.6.zip" },
        @{ Url = "https://github.com/microsoft/terminal/releases/download/v1.20.11381.0/Microsoft.WindowsTerminal_1.20.11381.0_8wekyb3d8bbwe.msixbundle"; FileName = "Microsoft.WindowsTerminal_1.20.11381.0_8wekyb3d8bbwe.msixbundle" },
        @{ Url = "https://aka.ms/getwinget"; FileName = "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" }
    )
}

# List of file paths to the downloaded package files
$packagePaths = @{
    "AMD64" = @(
        "Microsoft.VCLibs.x64.14.00.Desktop.appx",
        "Microsoft.UI.Xaml.2.8.x64.appx",
        "Microsoft.WindowsTerminal_1.20.11381.0_8wekyb3d8bbwe.msixbundle",
        "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    )
    "ARM64" = @(
        "Microsoft.VCLibs.arm64.14.00.Desktop.appx",
        "microsoft.ui.xaml.2.8.6\tools\AppX\arm64\Release\Microsoft.UI.Xaml.2.8.appx",
        "Microsoft.WindowsTerminal_1.20.11381.0_8wekyb3d8bbwe.msixbundle",
        "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    )
}

# Create a list to hold the download tasks
$downloadTasks = @()

# Load the WebClient type
Add-Type @"
using System;
using System.Net;
using System.Threading.Tasks;

public class WebClientHelper
{
    public static Task DownloadFileTaskAsync(string address, string fileName)
    {
        using (WebClient webClient = new WebClient())
        {
            return webClient.DownloadFileTaskAsync(new Uri(address), fileName);
        }
    }
}
"@

Write-Host "Starting the parallel Downloads"
# Download each file
foreach ($url in $urls[$architecture]) {
    $downloadTasks += [WebClientHelper]::DownloadFileTaskAsync($url.Url, $url.FileName)
}

Write-Host "Waiting for completion..."
[System.Threading.Tasks.Task]::WaitAll($downloadTasks)

# Expand UI.XAML package
Expand-Archive -Path "microsoft.ui.xaml.2.8.6.zip" -DestinationPath "microsoft.ui.xaml.2.8.6"

Write-Host "Install the Packages"
foreach ($file in $packagePaths[$architecture]) {
    Add-AppxPackage $file
}

Write-Host "Downloads and installation completed successfully."
wt.exe -p "Windows Terminal"
