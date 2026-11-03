# Instalador del Centro de Estudio (Windows)
# Que hace:
#   1. Instala Python 3.12 si no lo tienes (con winget).
#   2. Crea un entorno aparte en %LOCALAPPDATA%\CentroEstudio (fuera de Drive,
#      para no sincronizar gigas de librerias).
#   3. Instala faster-whisper (transcripcion local, sin internet despues de instalar).
#   4. Crea una tarea programada de Windows que revisa 00_Bandeja cada 15 minutos.
#
# Como ejecutarlo (en PowerShell, dentro de esta carpeta):
#   powershell -ExecutionPolicy Bypass -File .\instalar.ps1
#
# Para desinstalar la tarea programada:
#   Unregister-ScheduledTask -TaskName "CentroEstudio-Transcribir" -Confirm:$false

$ErrorActionPreference = "Stop"
$Aqui = $PSScriptRoot
$Script = Join-Path $Aqui "transcribir.py"
$Entorno = Join-Path $env:LOCALAPPDATA "CentroEstudio\venv"
$NombreTarea = "CentroEstudio-Transcribir"

Write-Host ""
Write-Host "=== Centro de Estudio: instalacion ===" -ForegroundColor Cyan
Write-Host "Carpeta de scripts: $Aqui"

# 1. Python
function Buscar-Python {
    $py = Get-Command py -ErrorAction SilentlyContinue
    if ($py) {
        try { & py -3.12 --version *> $null; if ($LASTEXITCODE -eq 0) { return @("py", "-3.12") } } catch {}
        try { & py -3 --version *> $null; if ($LASTEXITCODE -eq 0) { return @("py", "-3") } } catch {}
    }
    $python = Get-Command python -ErrorAction SilentlyContinue
    if ($python -and $python.Source -notlike "*WindowsApps*") { return @($python.Source) }
    return $null
}

$Python = Buscar-Python
if (-not $Python) {
    Write-Host "[1/4] Instalando Python 3.12 con winget..." -ForegroundColor Yellow
    winget install -e --id Python.Python.3.12 --scope user --accept-package-agreements --accept-source-agreements
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")
    $Python = Buscar-Python
    if (-not $Python) {
        Write-Host "No encontre Python despues de instalarlo. Cierra PowerShell, abrelo de nuevo y vuelve a ejecutar este script." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[1/4] Python ya esta instalado." -ForegroundColor Green
}

# 2. Entorno
if (-not (Test-Path (Join-Path $Entorno "Scripts\python.exe"))) {
    Write-Host "[2/4] Creando entorno en $Entorno ..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path (Split-Path $Entorno) | Out-Null
    $exe = $Python[0]; $args0 = @(); if ($Python.Length -gt 1) { $args0 = $Python[1..($Python.Length-1)] }
    & $exe @args0 -m venv $Entorno
} else {
    Write-Host "[2/4] Entorno ya existe." -ForegroundColor Green
}
$Py = Join-Path $Entorno "Scripts\python.exe"
$PyW = Join-Path $Entorno "Scripts\pythonw.exe"

# 3. faster-whisper
Write-Host "[3/4] Instalando faster-whisper (puede tardar unos minutos)..." -ForegroundColor Yellow
& $Py -m pip install --upgrade pip --quiet
& $Py -m pip install --upgrade faster-whisper --quiet
if ($LASTEXITCODE -ne 0) { Write-Host "Fallo la instalacion de faster-whisper." -ForegroundColor Red; exit 1 }

# 4. Tarea programada
Write-Host "[4/4] Creando tarea programada '$NombreTarea' (cada 15 min)..." -ForegroundColor Yellow
$Accion = New-ScheduledTaskAction -Execute $PyW -Argument "`"$Script`"" -WorkingDirectory $Aqui
$Disparador = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes 15) -RepetitionDuration (New-TimeSpan -Days 3650)
$Ajustes = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Hours 4) -MultipleInstances IgnoreNew
Register-ScheduledTask -TaskName $NombreTarea -Action $Accion -Trigger $Disparador -Settings $Ajustes `
    -Description "Transcribe audios de 00_Bandeja del Centro de Estudio" -Force | Out-Null

# Acceso directo para transcribir a mano
$Bat = Join-Path $Aqui "transcribir-ahora.bat"
Set-Content -Path $Bat -Encoding ASCII -Value @"
@echo off
echo Transcribiendo audios de 00_Bandeja...
"$Py" "$Script"
echo.
echo Listo. Revisa la carpeta 01_Transcripciones.
pause
"@

Write-Host ""
Write-Host "=== Instalacion completa ===" -ForegroundColor Cyan
Write-Host "- Deja audios (mp3, m4a, wav, ogg...) en 00_Bandeja."
Write-Host "- Cada 15 minutos se transcriben solos a 01_Transcripciones."
Write-Host "- Para hacerlo al instante: doble clic en transcribir-ahora.bat"
Write-Host "- La primera vez se descarga el modelo de voz (~500 MB)."
Write-Host "- Historial en: $(Join-Path $Aqui 'registro.log')"
