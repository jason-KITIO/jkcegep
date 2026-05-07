$folder = "$PSScriptRoot"
$pattern = '<i data-lucide="chevron-down" aria-hidden="true"></i>'
$files = Get-ChildItem -Path $folder -Recurse -Filter "*.html"
$count = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    if ($content -match [regex]::Escape($pattern)) {
        $content = $content.Replace($pattern, "")
        Set-Content $file.FullName -Value $content -Encoding UTF8 -NoNewline
        Write-Host "Modifié: $($file.FullName)"
        $count++
    }
}

Write-Host "`n$count fichier(s) modifié(s)."
