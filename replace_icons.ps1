# replace_icons.ps1
# Remplace tous les <i class="lucide..."><svg>...</svg></i> par <i data-lucide="nom"></i>
# et ajoute le CDN Lucide dans chaque fichier HTML

$rootPath = ".\www.cegepsl.qc.ca"
$files = Get-ChildItem -Path $rootPath -Filter "*.html" -Recurse

# Mapping : fragment unique du contenu SVG -> nom d'icone Lucide
$iconMap = @(
    @{ Fragment = 'polyline points="6 9 12 15 18 9"';                                          Name = "chevron-down" }
    @{ Fragment = 'x2="5" y2="12"/><polyline points="12 19 5 12 12 5"';                        Name = "arrow-left" }
    @{ Fragment = 'x2="19" y2="12"/><polyline points="12 5 19 12 12 19"';                      Name = "arrow-right" }
    @{ Fragment = 'cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"';       Name = "search" }
    @{ Fragment = 'x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"';      Name = "x" }
    @{ Fragment = 'M22 10v6M2 10l10-5 10 5-10 5z';                                             Name = "graduation-cap" }
    @{ Fragment = 'M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2';                               Name = "users" }
    @{ Fragment = 'rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2"'; Name = "calendar" }
    @{ Fragment = 'cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"';               Name = "clock" }
    @{ Fragment = 'M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z';      Name = "facebook" }
    @{ Fragment = 'rx="5" ry="5"/><path d="M16 11.37A4 4 0 1 1 12.63 8';                      Name = "instagram" }
    @{ Fragment = 'M22.54 6.42a2.78 2.78 0 0 0-1.95-1.96';                                    Name = "youtube" }
    @{ Fragment = 'M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2';                               Name = "linkedin" }
    @{ Fragment = 'x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"';      Name = "arrow-right" }
)

$cdnScript  = '<script src="https://unpkg.com/lucide@latest/dist/umd/lucide.min.js"></script>'
$initScript = '<script>lucide.createIcons();</script>'

# Regex qui capture : <i class="lucide[^"]*" aria-hidden="true"><svg...>CONTENU</svg></i>
$iTagRegex = [regex]'(?s)<i class="lucide([^"]*)" aria-hidden="true"><svg[^>]*>(.*?)</svg></i>'

$count = 0
$total = $files.Count
$i = 0

foreach ($file in $files) {
    $i++
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $modified = $false

    $newContent = $iTagRegex.Replace($content, {
        param($match)
        $extraClass = $match.Groups[1].Value.Trim()   # ex: " search-btn__open" ou ""
        $svgInner   = $match.Groups[2].Value

        # Trouver le nom de l'icone selon le fragment
        $iconName = $null
        foreach ($icon in $iconMap) {
            if ($svgInner.Contains($icon.Fragment)) {
                $iconName = $icon.Name
                break
            }
        }

        if ($iconName) {
            $script:modified = $true
            if ($extraClass -ne "") {
                return "<i data-lucide=`"$iconName`" class=`"$extraClass`" aria-hidden=`"true`"></i>"
            } else {
                return "<i data-lucide=`"$iconName`" aria-hidden=`"true`"></i>"
            }
        } else {
            # Icone inconnue : on garde l'original
            return $match.Value
        }
    })

    if ($modified) {
        # Ajouter CDN si pas déjà présent
        if (-not $newContent.Contains('unpkg.com/lucide')) {
            $newContent = $newContent -replace '</head>', "$cdnScript`n</head>"
            $newContent = $newContent -replace '</body>', "$initScript`n</body>"
        }
        [System.IO.File]::WriteAllText($file.FullName, $newContent, [System.Text.Encoding]::UTF8)
        $count++
    }

    if ($i % 200 -eq 0) {
        Write-Host "Progression : $i / $total fichiers traités ($count modifiés)..."
    }
}

Write-Host ""
Write-Host "Terminé ! $count fichiers modifiés sur $total fichiers HTML."
