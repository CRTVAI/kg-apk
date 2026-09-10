$p = "C:\Users\rahma\AppData\Local\Pub\Cache\hosted\pub.dev\file_picker-5.5.0\android\build.gradle"
$c = Get-Content -Raw -Path $p
$c = $c -replace 'compileSdkVersion 33', 'compileSdkVersion 36'
[System.IO.File]::WriteAllText($p, $c)
Write-Host "Patched. First 25 lines:"
Get-Content $p | Select-Object -First 25
