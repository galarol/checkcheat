# ============================================
#   ЧЕКЕР НА ЧИТЫ / ПОДОЗРИТЕЛЬНЫЙ СОФТ
# ============================================

$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "Проверка на читы"

# --- Список известных читов и подозрительных процессов ---
$cheatProcesses = @(
    "cheatengine", "cheatengine-x86_64", "cheatengine-i386",
    "x64dbg", "x32dbg", "ollydbg", "ida", "ida64",
    "processhacker", "processhacker2", "systeminformer",
    "wireshark", "fiddler", "httpdebugger",
    "artmoney", "gamehack", "gamehacker",
    "autohotkey", "ahk", "autohotkeyu64", "autohotkeyu32",
    "macro", "macromaker", "tinytask", "ghotkey",
    "wemod", "fling", "mrantifun",
    "lghub", "lghub_agent", "ghub",           # Logitech (макросы)
    "razer synapse", "synapse3", "rzsynapse",
    "corsair icue", "icue",
    "obs64", "obs32",                          # OBS (стрим)
    "fraps", "bandicam", "dxtory",
    "screenshot", "nvidia share",
    "vboxservice", "vmtoolsd", "vboxtray",     # Виртуалки
    "sandboxie", "sandboxiedcomlaunch",
    "psiphon", "proxifier", "openvpn", "wireguard",
    "frida", "frida-helper", "frida-server",
    "injector", "extreme injector", "xinject",
    "ldplayer", "nox", "bluestacks", "memu",   # Эмуляторы
    "gtav_injector", "r2modman",
    "ksdumper", "kdmapper", "eac", "be",
    "perfectaim", "aimbot", "triggerbot"
)

# --- Известные имена файлов читов ---
$cheatFiles = @(
    "*.ct",            # Cheat Engine Table
    "cheatengine*",
    "aimbot*", "triggerbot*", "wallhack*", "esp*",
    "injector*", "inject*.exe",
    "autoclicker*", "macro*.exe",
    "*.ahk",           # AutoHotkey скрипты
    "frida*"
)

# --- Подозрительные папки ---
$suspiciousPaths = @(
    "$env:TEMP",
    "$env:APPDATA",
    "$env:LOCALAPPDATA",
    "$env:USERPROFILE\Downloads"
)

function Write-Section {
    param([string]$Text)
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host " $Text" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
}

function Write-OK   { param($m) Write-Host "[OK]   $m" -ForegroundColor Green }
function Write-Warn { param($m) Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Write-Fail { param($m) Write-Host "[CHEAT]$m" -ForegroundColor Red }
function Write-Info { param($m) Write-Host "[INFO] $m" -ForegroundColor Gray }

$foundCheats = @()

# ============================================
# 1. Проверка запущенных процессов
# ============================================
Write-Section "1. ПРОВЕРКА ПРОЦЕССОВ"

$running = Get-Process | Select-Object -ExpandProperty ProcessName -Unique
$hits = $running | Where-Object { $p = $_; $cheatProcesses | Where-Object { $p -like "*$_*" } }

if ($hits) {
    foreach ($h in $hits) {
        Write-Fail "Обнаружен подозрительный процесс: $h"
        $foundCheats += "Процесс: $h"
    }
} else {
    Write-OK "Подозрительных процессов не найдено"
}

# ============================================
# 2. Проверка автозагрузки
# ============================================
Write-Section "2. ПРОВЕРКА АВТОЗАГРУЗКИ"

$startupKeys = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($key in $startupKeys) {
    if (Test-Path $key) {
        $items = Get-ItemProperty $key
        foreach ($item in $items.PSObject.Properties) {
            if ($item.Name -notmatch "^PS") {
                $name = $item.Name
                $val  = $item.Value
                if ($cheatProcesses | Where-Object { $name -like "*$_*" -or $val -like "*$_*" }) {
                    Write-Fail "Автозагрузка: $name -> $val"
                    $foundCheats += "Автозагрузка: $name"
                }
            }
        }
    }
}
Write-OK "Автозагрузка проверена"

# ============================================
# 3. Поиск файлов читов в пользовательских папках
# ============================================
Write-Section "3. ПОИСК ФАЙЛОВ ЧИТОВ"

foreach ($path in $suspiciousPaths) {
    if (-not (Test-Path $path)) { continue }
    foreach ($pattern in $cheatFiles) {
        $files = Get-ChildItem -Path $path -Filter $pattern -Recurse -ErrorAction SilentlyContinue -Depth 3
        foreach ($f in $files) {
            Write-Fail "Найден файл: $($f.FullName)"
            $foundCheats += "Файл: $($f.FullName)"
        }
    }
}
if ($foundCheats.Count -eq 0) {
    Write-OK "Подозрительных файлов не найдено"
}

# ============================================
# 4. Проверка недавно изменённых DLL/EXE
# ============================================
Write-Section "4. НЕДАВНО ИЗМЕНЁННЫЕ ФАЙЛЫ (7 дней)"

$recent = Get-ChildItem -Path "$env:USERPROFILE" -Include *.exe,*.dll,*.ahk -Recurse `
    -ErrorAction SilentlyContinue -Depth 3 |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) } |
    Select-Object -First 20

if ($recent) {
    Write-Warn "Недавно изменённые файлы (проверь вручную):"
    $recent | ForEach-Object { Write-Info "  $($_.FullName)  [$($_.LastWriteTime)]" }
} else {
    Write-OK "Недавно изменённых подозрительных файлов нет"
}

# ============================================
# 5. Проверка служб и драйверов
# ============================================
Write-Section "5. ПОДОЗРИТЕЛЬНЫЕ СЛУЖБЫ"

$services = Get-Service | Where-Object { $_.Status -eq "Running" }
foreach ($s in $services) {
    if ($cheatProcesses | Where-Object { $s.Name -like "*$_*" -or $s.DisplayName -like "*$_*" }) {
        Write-Fail "Служба: $($s.Name) / $($s.DisplayName)"
        $foundCheats += "Служба: $($s.Name)"
    }
}
Write-OK "Службы проверены"

# ============================================
# 6. Проверка сетевых подключений
# ============================================
Write-Section "6. АКТИВНЫЕ СЕТЕВЫЕ ПОДКЛЮЧЕНИЯ"

$conns = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue |
    Select-Object -Unique RemoteAddress, RemotePort |
    Where-Object { $_.RemoteAddress -notmatch "^(127\.|::1|0\.0\.0\.0)" }

if ($conns) {
    Write-Info "Активные соединения:"
    $conns | ForEach-Object { Write-Info "  $($_.RemoteAddress):$($_.RemotePort)" }
}

# ============================================
# ИТОГ
# ============================================
Write-Section "ИТОГОВЫЙ РЕЗУЛЬТАТ"

if ($foundCheats.Count -gt 0) {
    Write-Host ""
    Write-Host "  !!! ОБНАРУЖЕНЫ ПОДОЗРИТЕЛЬНЫЕ ОБЪЕКТЫ !!!" -ForegroundColor Red -BackgroundColor Black
    Write-Host ""
    $foundCheats | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host ""
    Write-Host "  Рекомендуется закрыть их перед игрой." -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "  ✔ ЧИСТО! Подозрительного софта не найдено." -ForegroundColor Green
    Write-Host ""
}

# Лог-файл
$logPath = Join-Path $PSScriptRoot "check_log_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"
@"
=== ОТЧЁТ ПРОВЕРКИ ===
Дата: $(Get-Date)
Пользователь: $env:USERNAME
Компьютер: $env:COMPUTERNAME
Найдено подозрительного: $($foundCheats.Count)
$($foundCheats -join "`n")
"@ | Out-File -FilePath $logPath -Encoding UTF8

Write-Info "Лог сохранён: $logPath"