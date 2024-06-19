# Define URLs and output file names
$urls = @{
    "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" = "Microsoft.VCLibs.x64.14.00.Desktop.appx"
    "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx" = "Microsoft.UI.Xaml.2.8.x64.appx"
    "https://github.com/microsoft/terminal/releases/download/v1.20.11381.0/Microsoft.WindowsTerminal_1.20.11381.0_8wekyb3d8bbwe.msixbundle" = "Microsoft.WindowsTerminal_1.20.11381.0_8wekyb3d8bbwe.msixbundle"
    "https://aka.ms/getwinget" = "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
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

Write-Host "Starting the paralell Downloads"
foreach ($url in $urls.Keys) {
    $fileName = $urls[$url]
    $downloadTasks += [WebClientHelper]::DownloadFileTaskAsync($url, $fileName)
}

Write-Host "Waiting for completion..."
[System.Threading.Tasks.Task]::WaitAll($downloadTasks)

Write-Host "Install the Packages"
foreach ($file in $urls.Values) {
    Add-AppxPackage $file
}
wt.exe
