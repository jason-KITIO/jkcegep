$filePath = "c:\Users\cid\Documents\cegep\Copy\https___www.cegepsl.qc.ca_\www.cegepsl.qc.ca\index.html"

$content = Get-Content $filePath -Raw

$content = $content -replace '(?s)<header.*?</header>', '<header>bonjour</header>'
$content = $content -replace '(?s)<footer.*?</footer>', '<footer>bye</footer>'

Set-Content $filePath -Value $content -Encoding UTF8

Write-Host "Done!"
