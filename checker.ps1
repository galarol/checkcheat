#Requires -Version 5.1
<#
    CHECK SCRIPTS LAUNCHER — PowerShell Edition
    Аналог bat-версии: скачивает и запускает 1.ps1 и 2.ps1
#>

# ----------------------------------------------------------------------------
# Параметры
# ----------------------------------------------------------------------------
$URL1 = "https://raw.githubusercontent.com/galarol/checkcheat/main/1.ps1"
$URL2 = "https://raw.githubusercontent.com/galarol/checkcheat/main/2.ps1"
$OUT1 = Join-Path $PSScriptRoot "script1.ps1"
$OUT2 = Join-Path $PSScriptRoot "script2.ps1"

# ----------------------------------------------------------------------------
# Кодировка консоли
# ----------------------------------------------------------------------------
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding            = [System.Text.Encoding]::UTF8

# ----------------------------------------------------------------------------
# Проверка прав администратора
# ----------------------------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[!] Требуются права администратора. Перезапуск..." -ForegroundColor Red
    Start-Process powershell -Verb RunAs -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`""
    )
    exit
}

# ----------------------------------------------------------------------------
# Функции оформления
# ----------------------------------------------------------------------------

function Write-Typewriter {
    param(
        [string]$Text,
        [int]$DelayMs = 12,
        [ConsoleColor]$Color = [ConsoleColor]::Green
    )
    $old = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    foreach ($ch in $Text.ToCharArray()) {
        Write-Host -NoNewline $ch
        Start-Sleep -Milliseconds $DelayMs
    }
    Write-Host ""
    $Host.UI.RawUI.ForegroundColor = $old
}

function Write-ProgressBar {
    param(
        [int]$Length = 58,
        [int]$DelayMs = 15,
        [ConsoleColor]$Color = [ConsoleColor]::Green
    )
    $old = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    for ($i = 1; $i -le $Length; $i++) {
        Write-Host -NoNewline ("[" + ("#" * $i) + "]")
        Start-Sleep -Milliseconds $DelayMs
        Write-Host -NoNewline ("`r" + (" " * ($Length * 2 + 4)) + "`r")
    }
    Write-Host ("[" + ("#" * $Length) + "]")
    $Host.UI.RawUI.ForegroundColor = $old
}

function Set-SmoothColor {
    param([ConsoleColor]$Color, [int]$DelayMs = 80)
    $Host.UI.RawUI.ForegroundColor = $Color
    Start-Sleep -Milliseconds $DelayMs
}

function Write-Banner {
    param([string]$Text, [ConsoleColor]$Color = [ConsoleColor]::Green)
    $old = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Host ("#" * 76)
    Write-Host ("#" + (" " * 74) + "#")
    Write-Host ("#" + (" " * 74) + "#")
    Write-Host ("#" + (" " * 74) + "#")
    Write-Host ("#" + (" " * 74) + "#")
    Write-Host ("#" + (" " * 74) + "#")
    Write-Host ("#" * 76)
    $Host.UI.RawUI.ForegroundColor = $old
}

# ----------------------------------------------------------------------------
# Заголовок
# ----------------------------------------------------------------------------
Clear-Host
Write-Host ""
Write-Host ""
Write-Typewriter "############################################################################"
Write-Typewriter "#                                                                          #"
Write-Typewriter "#     ####    ###   #   #  #####   ####    ###   #   #                   #"
Write-Typewriter "#    #    #  #   #  ## ##  #      #    #  #   #  #  #                    #"
Write-Typewriter "#    #       #####  # # #  ####   #       #####  ###                     #"
Write-Typewriter "#    #    #  #   #  #   #  #      #    #  #   #  #  #                    #"
Write-Typewriter "#     ####   #   #  #   #  #####   ####   #   #  #   #                   #"
Write-Typewriter "#                                                                          #"
Write-Typewriter "############################################################################"
Write-Host ""
Write-Host ""

Set-SmoothColor -Color Cyan
Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
Write-Host "~                                                                          ~"
Write-Host "~                          П О Д Г О Т О В К А                             ~"
Write-Host "~                                                                          ~"
Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
Write-Host ""
Write-Typewriter "[....] Инициализация окружения..."
Write-Host ""
Write-ProgressBar
Write-Host ""
Write-Host "[OK] Инициализация завершена." -ForegroundColor Green
Write-Host ""
Start-Sleep -Milliseconds 800
Set-SmoothColor -Color Green
Write-Host ""

# ----------------------------------------------------------------------------
# Скачивание
# ----------------------------------------------------------------------------
Set-SmoothColor -Color Cyan
Write-Host ""
Write-Host ""
Write-Host ("=" * 76)
Write-Host ("=" * 76)
Write-Host ("=" * 20 + "   С К А Ч И В А Н И Е   " + "=" * 27)
Write-Host ("=" * 76)
Write-Host ("=" * 76)
Write-Host ""
Write-Host ""

Write-Host ("#" * 76)
Write-Host "#                                                                          #"
Write-Host "#             СКАЧИВАНИЕ:  script1.ps1  и  script2.ps1                     #"
Write-Host "#                                                                          #"
Write-Host ("#" * 76)
Write-Host ""
Write-Host ""

Write-Typewriter "[....] Начинаем скачивание ..."
Write-Typewriter "[....] Пожалуйста, подождите ..."
Write-Host ""
Write-ProgressBar
Write-Host ""

$ErrorActionPreference = "Stop"
try {
    Invoke-WebRequest -Uri $URL1 -OutFile $OUT1 -UseBasicParsing
    Write-Host "[OK] Скачан: $OUT1" -ForegroundColor Green
}
catch {
    Write-Host "[ERR] Не удалось скачать $URL1 : $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

try {
    Invoke-WebRequest -Uri $URL2 -OutFile $OUT2 -UseBasicParsing
    Write-Host "[OK] Скачан: $OUT2" -ForegroundColor Green
}
catch {
    Write-Host "[ERR] Не удалось скачать $URL2 : $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[DONE] Скачивание завершено." -ForegroundColor Green
Write-Host ""

Set-SmoothColor -Color Yellow
Write-Host ("#" * 76)
Write-Host "#                                                                          #"
Write-Host "#                 П Р О В Е Р К А   Р Е З У Л Ь Т А Т А                    #"
Write-Host "#                                                                          #"
Write-Host ("#" * 76)
Write-Host ""
Write-Typewriter "[....] Проверяем результат..."
Write-Host ""
Write-ProgressBar
Write-Host ""
Write-Host "[OK] Все файлы успешно скачаны." -ForegroundColor Green
Write-Host ""
Write-Host ("[" + ("#" * 58) + "] 100%")
Write-Host " Скачивание завершено."
Write-Host ""
Start-Sleep -Milliseconds 800

# ----------------------------------------------------------------------------
# Запуск скриптов
# ----------------------------------------------------------------------------
Set-SmoothColor -Color Cyan
Write-Host ""
Write-Host ""
Write-Host ("=" * 76)
Write-Host ("=" * 76)
Write-Host ("=" * 20 + "   З А П У С К   " + "=" * 33)
Write-Host ("=" * 76)
Write-Host ("=" * 76)
Write-Host ""
Write-Host ""

# ---------- Первый скрипт ----------
Set-SmoothColor -Color Yellow
Write-Host ("#" * 76)
Write-Host "#                                                                          #"
Write-Host "#                                                                          #"
Write-Host "#           [ 1 / 2 ]     З А П У С К    script1.ps1                       #"
Write-Host "#                                                                          #"
Write-Host "#                                                                          #"
Write-Host ("#" * 76)
Write-Host ""
Write-Typewriter "[....] Подготовка к запуску script1.ps1 ..."
Write-Typewriter "[....] Запускаем ..."
Write-Host ""
Write-ProgressBar
Write-Host ""

Set-SmoothColor -Color Green
$code1 = Get-Content -Raw -Encoding UTF8 $OUT1
Invoke-Expression $code1
if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {
    Write-Host "[!] script1.ps1 завершился с ошибкой ($LASTEXITCODE)" -ForegroundColor Red
}

Write-Host ""
Write-Host ("." * 76)
Write-Host ".                                                                          ."
Write-Host ".                  script1.ps1  —   З А В Е Р Ш Ё Н                         ."
Write-Host ".                                                                          ."
Write-Host ("." * 76)
Write-Host ""
Start-Sleep -Milliseconds 800

# ---------- Второй скрипт ----------
Set-SmoothColor -Color Yellow
Write-Host ("#" * 76)
Write-Host "#                                                                          #"
Write-Host "#                                                                          #"
Write-Host "#           [ 2 / 2 ]     З А П У С К    script2.ps1                       #"
Write-Host "#                                                                          #"
Write-Host "#                                                                          #"
Write-Host ("#" * 76)
Write-Host ""
Write-Typewriter "[....] Подготовка к запуску script2.ps1 ..."
Write-Typewriter "[....] Запускаем ..."
Write-Host ""
Write-ProgressBar
Write-Host ""

Set-SmoothColor -Color Green
$code2 = Get-Content -Raw -Encoding UTF8 $OUT2
Invoke-Expression $code2
if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {
    Write-Host "[!] script2.ps1 завершился с ошибкой ($LASTEXITCODE)" -ForegroundColor Red
}

Write-Host ""
Write-Host ("." * 76)
Write-Host ".                                                                          ."
Write-Host ".                  script2.ps1  —   З А В Е Р Ш Ё Н                         ."
Write-Host ".                                                                          ."
Write-Host ("." * 76)
Write-Host ""
Start-Sleep -Milliseconds 800

# ----------------------------------------------------------------------------
# Финал
# ----------------------------------------------------------------------------
Set-SmoothColor -Color Green
Write-Host ""
Write-Host ""
Write-Host ("=" * 76)
Write-Host ("=" * 76)
Write-Host ("=" * 20 + "   В С Ё   З А В Е Р Ш Е Н О   " + "=" * 19)
Write-Host ("=" * 76)
Write-Host ("=" * 76)
Write-Host ""
Write-Host ""
Write-Host ("#" * 76)
Write-Host "#                                                                          #"
Write-Host "#                                                                          #"
Write-Host "#                 ####   ####   ####   ####   ####                        #"
Write-Host "#                 #      #  #   #  #   #  #   #                           #"
Write-Host "#                 ###    ####   ####   ####   ###                         #"
Write-Host "#                 #      #  #   #      #  #   #                           #"
Write-Host "#                 ####   #  #   #      ####   ####                        #"
Write-Host "#                                                                          #"
Write-Host "#                                                                          #"
Write-Host ("#" * 76)
Write-Host ""
Write-Host ("[" + ("#" * 58) + "] 100%")
Write-Host ""
Write-Host ("*" * 76)
Write-Host "*                                                                          *"
Write-Host "*                                                                          *"
Write-Host "*              С П А С И Б О   З А   Р А Б О Т У !                         *"
Write-Host "*                                                                          *"
Write-Host "*                                                                          *"
Write-Host ("*" * 76)
Write-Host ""
Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
Write-Host "~                                                                        ~"
Write-Host "~                     Р А Б О Т А   З А В Е Р Ш Е Н А                    ~"
Write-Host "~                                                                        ~"
Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
Write-Host ""
Write-Host ("#" * 76)
Write-Host "###                    К О Н Е Ц   С К Р И П Т А                          ###"
Write-Host ("#" * 76)
Write-Host ""
Write-Host ("#" * 76)
Write-Host ("#" * 76)
Write-Host ("#" * 76)
Write-Host ""
Write-Host "Нажми Enter для выхода..."
[void][System.Console]::ReadLine()
