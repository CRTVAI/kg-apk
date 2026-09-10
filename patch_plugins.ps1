# Patch all Flutter plugin build.gradle files in the pub cache that hardcode
# compileSdkVersion < 34. Required because AGP 8.x enforces that transitive
# AndroidX deps (core 1.13+, lifecycle 2.7+, etc.) need compileSdk >= 34.

$pluginRoot = "C:\Users\rahma\AppData\Local\Pub\Cache\hosted\pub.dev"
$gradleFiles = Get-ChildItem -Path $pluginRoot -Recurse -Filter "build.gradle" -ErrorAction SilentlyContinue

$patched = @()
foreach ($file in $gradleFiles) {
    $content = Get-Content -Raw -Path $file.FullName
    $changed = $false

    foreach ($old in @('compileSdkVersion 31', 'compileSdkVersion 32', 'compileSdkVersion 33')) {
        if ($content -match [regex]::Escape($old)) {
            $content = $content -replace [regex]::Escape($old), 'compileSdkVersion 36'
            $changed = $true
        }
    }

    if ($changed) {
        [System.IO.File]::WriteAllText($file.FullName, $content)
        $patched += $file.FullName
        Write-Host "Patched: $($file.FullName)"
    }
}

Write-Host ""
Write-Host "Total patched: $($patched.Count)"
