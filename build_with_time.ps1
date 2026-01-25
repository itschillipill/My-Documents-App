$pubspec = "pubspec.yaml"

$content = Get-Content $pubspec

# Unix timestamp в минутах
$buildNumber = [int](([DateTimeOffset]::UtcNow.ToUnixTimeSeconds()) / 60)

$content = $content -replace 'version:\s*([0-9\.]+)\+\d+', "version: `$1+$buildNumber"

Set-Content $pubspec $content

Write-Host "Updated build number to $buildNumber"

flutter build apk --target-platform=android-arm64
