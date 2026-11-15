@echo off
setlocal
title MaxiskApp - installation du lanceur PC
set "D=%LOCALAPPDATA%\MaxiskApp"
if not exist "%D%" mkdir "%D%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$t=[IO.File]::ReadAllText('%~f0'); $i=$t.IndexOf('#'+'##PS1###'); [IO.File]::WriteAllText('%D%\lanceur.ps1', $t.Substring($i+9).TrimStart(), (New-Object Text.UTF8Encoding $true))"
if errorlevel 1 goto err
reg add "HKCU\Software\Classes\maxisk-run" /ve /d "URL:MaxiskApp lanceur" /f >nul || goto err
reg add "HKCU\Software\Classes\maxisk-run" /v "URL Protocol" /d "" /f >nul || goto err
reg add "HKCU\Software\Classes\maxisk-run\shell\open\command" /ve /d "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File \"%D%\lanceur.ps1\" \"%%1\"" /f >nul || goto err
echo.
echo  Lanceur installe. Tu peux fermer cette fenetre.
echo  (Pour le retirer : supprime la cle HKCU\Software\Classes\maxisk-run)
echo.
pause
exit /b 0
:err
echo.
echo  Erreur pendant l'installation.
pause
exit /b 1
###PS1###
# MaxiskApp - lanceur de programmes Windows
# Appelé par le lien maxisk-run:<chemin encodé>. Ne lance QUE des .exe situés
# dans C:\Program Files\ ou C:\Program Files (x86)\.
param([string]$u)

function Stop-Lanceur([string]$m) {
  (New-Object -ComObject WScript.Shell).Popup($m, 10, "MaxiskApp", 48) | Out-Null
  exit 1
}

$p = $u -replace '^maxisk-run:(//)?', ''
$p = [uri]::UnescapeDataString($p).Trim().Trim('"').TrimEnd('/')
if (-not $p) { Stop-Lanceur "Aucun programme indiqué." }
try { $full = [IO.Path]::GetFullPath($p) } catch { Stop-Lanceur "Chemin invalide :`n$p" }

$roots = @($env:ProgramFiles, ${env:ProgramFiles(x86)}) | Where-Object { $_ } | ForEach-Object { $_.TrimEnd('\') + '\' }
$ok = $roots | Where-Object { $full.StartsWith($_, [StringComparison]::OrdinalIgnoreCase) }
if (-not $ok) { Stop-Lanceur "Refusé : seuls les programmes de Program Files peuvent être lancés.`n$full" }
if ([IO.Path]::GetExtension($full) -ine '.exe') { Stop-Lanceur "Refusé : ce n'est pas un .exe.`n$full" }

$wa = $env:ProgramFiles.TrimEnd('\') + '\WindowsApps\'
if ($full.StartsWith($wa, [StringComparison]::OrdinalIgnoreCase)) {
  # Appli du Microsoft Store : on ne peut pas lancer l'exe directement, on passe par son identifiant.
  # Le nom du paquet est retrouvé sans tenir compte de la version (le chemin change à chaque mise à jour).
  $rel = $full.Substring($wa.Length)
  $parts = $rel.Split('\', 2)
  $name = $parts[0].Split('_')[0]
  $pkg = Get-AppxPackage -Name $name | Sort-Object Version -Descending | Select-Object -First 1
  if (-not $pkg) { Stop-Lanceur "Appli du Store introuvable : $name" }
  $apps = @((Get-AppxPackageManifest $pkg).Package.Applications.Application)
  $app = $apps | Where-Object { $_.Executable -ieq $parts[1] } | Select-Object -First 1
  if (-not $app) { $app = $apps | Select-Object -First 1 }
  Start-Process explorer.exe "shell:AppsFolder\$($pkg.PackageFamilyName)!$($app.Id)"
} else {
  if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { Stop-Lanceur "Programme introuvable :`n$full" }
  Start-Process -FilePath $full -WorkingDirectory (Split-Path $full)
}
