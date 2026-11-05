# redes-movil.ps1 - Choose which mobile networks (5G/4G/3G/2G) an Android phone may use, via ADB
#                   Elige qué redes móviles (5G/4G/3G/2G) puede usar un móvil Android, vía ADB
# Version 1.0.0
# Copyright (C) 2026 Víctor Cruz
#
# This program is free software: you can redistribute it and/or modify it under the terms
# of the GNU General Public License, version 3 (GPL-3.0). It comes WITHOUT ANY WARRANTY.
# See the LICENSE file.
#
# Requires Android 12 or later, USB debugging enabled and this PC authorised.
# No root, nothing installed on the phone.
#
# It can run from a downloaded copy (Redes-del-movil.cmd) or straight from the web with
# "| iex" (see README), so everything lives inside a function and "exit" is never used.
#
# Language follows the Windows display language (Spanish, otherwise English).
# To force it:  $env:REDES_MOVIL_LANG = 'es'   (or 'en')

function Start-RedesMovil {

[Console]::OutputEncoding = [Text.Encoding]::UTF8

# --- Language / Idioma ---
$lang = if ($env:REDES_MOVIL_LANG -in 'es','en') { $env:REDES_MOVIL_LANG }
        elseif ((Get-UICulture).TwoLetterISOLanguageName -eq 'es') { 'es' } else { 'en' }

$textos = @{
    es = @{
        Title      = 'Redes del móvil (ADB)'
        Header     = 'REDES DEL MÓVIL  (vía ADB)'
        NoAdb1     = 'No encuentro adb.exe (Android SDK Platform-Tools).'
        NoAdb2     = 'Descárgalo de https://developer.android.com/tools/releases/platform-tools'
        NoAdb3     = 'y descomprime la carpeta "platform-tools" junto a este script (o añádela al PATH).'
        PressExit  = 'Enter para salir'
        Unauth     = 'El móvil no ha autorizado este PC: desbloquéalo y acepta el aviso de Depuración USB.'
        NoDevice   = 'No hay móvil disponible. Conéctalo por USB, activa Depuración USB y acepta la huella de este PC.'
        OldAndroid = 'Este móvil tiene Android con API {0}. Hace falta Android 12 (API 31) o superior.'
        Slot       = 'SIM ranura {0}  -  Operador: {1}'
        Allowed    = 'Redes permitidas : {0}'
        Now        = 'Conectado ahora  : {0}'
        Rsrp       = 'Señal 4G (RSRP)  : {0}'
        Ims        = 'IMS (llamadas 4G): {0}'
        Mode5g     = 'Modo 5G (desarr.): {0}'
        ModeOther  = 'Auto/NSA (valor {0})'
        Unknown    = 'desconocido'
        Nothing    = '(nada reconocible)'
        NeedSa1    = 'Para Sólo 5G primero activa en Opciones de desarrollador > Modo de red 5G: "NSA + SA" (ColorOS).'
        NeedSa2    = 'Si no, el módem rechaza el cambio.'
        Warning    = 'Aviso: {0}'
        Rejected   = 'El módem ha RECHAZADO este modo. Vuelvo a dejar el anterior...'
        Restored   = 'Restaurado: {0}'
        Reply      = 'Respuesta: {0}'
        Applied    = 'Aplicado: {0}'
        Mismatch   = 'El móvil no ha guardado exactamente «{0}».'
        NoPrev     = 'No he podido leer el modo actual del móvil ({0}). No cambio nada, para no dejarlo sin redes.'
        Multi      = 'Hay más de un dispositivo conectado. Deja conectado sólo el móvil o indica cuál con: $env:ANDROID_SERIAL = ''<número de serie>'''
        NowAllows  = 'El móvil ahora permite: {0}'
        Wait       = '(Puede tardar unos segundos en volver a registrarse en la red.)'
        MenuE      = 'E) Ver estado otra vez'
        MenuS      = 'S) Cambiar ranura SIM (ahora: {0})'
        MenuQ      = 'Q) Salir'
        Choose     = 'Elige'
        Back       = 'Enter para volver al menú'
        Invalid    = 'Opción no válida.'
        P1 = '5G + 4G (sin 3G ni 2G)';     W1 = 'Donde sólo haya 2G/3G no tendrás cobertura. Las llamadas necesitan VoLTE.'
        P2 = '5G + 4G + 2G (sin 3G)';      W2 = 'Puede bajar a 2G: llamadas sí, datos casi inútiles.'
        P3 = 'Sólo 4G';                    W3 = 'Sin 5G ni 2G/3G.'
        P4 = 'Sólo 5G';                    W4 = 'Sólo funciona con 5G SA (standalone). Sin VoNR no hay llamadas, y casi no hay cobertura SA.'
        P5 = '4G + 3G + 2G (sin 5G)';      W5 = ''
        P6 = 'Todas (5G + 4G + 3G + 2G)';  W6 = ''
        P7 = 'Sólo 3G';                    W7 = 'Los operadores están apagando el 3G: datos lentos o inexistentes.'
        P8 = 'Sólo 2G';                    W8 = 'Llamadas y SMS; datos (EDGE) prácticamente inútiles.'
    }
    en = @{
        Title      = 'Mobile networks (ADB)'
        Header     = 'MOBILE NETWORKS  (via ADB)'
        NoAdb1     = 'adb.exe not found (Android SDK Platform-Tools).'
        NoAdb2     = 'Download it from https://developer.android.com/tools/releases/platform-tools'
        NoAdb3     = 'and unzip the "platform-tools" folder next to this script (or add it to PATH).'
        PressExit  = 'Press Enter to exit'
        Unauth     = 'The phone has not authorised this PC: unlock it and accept the USB debugging prompt.'
        NoDevice   = 'No phone available. Connect it via USB, enable USB debugging and accept this PC''s fingerprint.'
        OldAndroid = 'This phone runs Android API {0}. Android 12 (API 31) or later is required.'
        Slot       = 'SIM slot {0}  -  Carrier: {1}'
        Allowed    = 'Allowed networks : {0}'
        Now        = 'Connected now    : {0}'
        Rsrp       = '4G signal (RSRP) : {0}'
        Ims        = 'IMS (4G calls)   : {0}'
        Mode5g     = '5G mode (dev.)   : {0}'
        ModeOther  = 'Auto/NSA (value {0})'
        Unknown    = 'unknown'
        Nothing    = '(nothing recognised)'
        NeedSa1    = 'For 5G only, first set Developer options > 5G network mode: "NSA + SA" (ColorOS).'
        NeedSa2    = 'Otherwise the modem rejects the change.'
        Warning    = 'Warning: {0}'
        Rejected   = 'The modem REJECTED this mode. Restoring the previous one...'
        Restored   = 'Restored: {0}'
        Reply      = 'Reply: {0}'
        Applied    = 'Applied: {0}'
        Mismatch   = 'The phone did not keep exactly "{0}".'
        NoPrev     = 'Could not read the phone''s current mode ({0}). Changing nothing, so it is not left without networks.'
        Multi      = 'More than one device is connected. Leave only the phone connected or pick one with: $env:ANDROID_SERIAL = ''<serial number>'''
        NowAllows  = 'The phone now allows: {0}'
        Wait       = '(It may take a few seconds to register on the network again.)'
        MenuE      = 'E) Show status again'
        MenuS      = 'S) Switch SIM slot (now: {0})'
        MenuQ      = 'Q) Quit'
        Choose     = 'Choose'
        Back       = 'Press Enter to return to the menu'
        Invalid    = 'Invalid option.'
        P1 = '5G + 4G (no 3G or 2G)';      W1 = 'Where only 2G/3G is available you will have no coverage. Calls need VoLTE.'
        P2 = '5G + 4G + 2G (no 3G)';       W2 = 'May drop to 2G: calls work, data almost useless.'
        P3 = '4G only';                    W3 = 'No 5G, 3G or 2G.'
        P4 = '5G only';                    W4 = 'Only works with 5G SA (standalone). Without VoNR there are no calls, and SA coverage is rare.'
        P5 = '4G + 3G + 2G (no 5G)';       W5 = ''
        P6 = 'All (5G + 4G + 3G + 2G)';    W6 = ''
        P7 = '3G only';                    W7 = 'Carriers are shutting down 3G: data slow or non-existent.'
        P8 = '2G only';                    W8 = 'Calls and SMS; data (EDGE) practically useless.'
    }
}
$T = $textos[$lang]
function Tx([string]$key) { $args2 = $args; if ($args2.Count) { return ($T[$key] -f $args2) } else { return $T[$key] } }

$Host.UI.RawUI.WindowTitle = $T.Title

# --- Find adb / Localizar adb ---
$adb = $null
foreach ($c in @("$env:USERPROFILE\Documents\platform-tools\adb.exe",
                 "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
                 $(if ($PSScriptRoot) { Join-Path $PSScriptRoot 'platform-tools\adb.exe' }))) {
    if (-not $c) { continue }
    if (Test-Path $c) { $adb = $c; break }
}
if (-not $adb) { $g = Get-Command adb.exe -ErrorAction SilentlyContinue; if ($g) { $adb = $g.Source } }
if (-not $adb) {
    Write-Host $T.NoAdb1 -ForegroundColor Red
    Write-Host $T.NoAdb2
    Write-Host $T.NoAdb3
    Read-Host $T.PressExit | Out-Null
    return
}

# --- Profiles: 20-bit binary mask (NR, LTE_CA, ..., GPRS) ---
# Bits: NR=19 LTE_CA=18 GSM=15 HSPA+=14 LTE=12 HSPA=9 HSUPA=8 HSDPA=7 UMTS=2 EDGE=1 GPRS=0 (+ CDMA)
$MaskSolo5G = '10000000000000000000'
$masks = [ordered]@{
    '1' = '11000001000000000000'
    '2' = '11001001000000000011'
    '3' = '01000001000000000000'
    '4' = $MaskSolo5G
    '5' = '01001111101111111111'
    '6' = '11001111101111111111'
    '7' = '00000100001110000100'
    '8' = '00001000000000000011'
}
$slot = 0

function Adb([string]$cmd) { (& $adb shell $cmd 2>&1 | Out-String).Trim() }

function Version-OK {
    $sdk = 0; [int]::TryParse((Adb 'getprop ro.build.version.sdk'), [ref]$sdk) | Out-Null
    if ($sdk -gt 0 -and $sdk -lt 31) { Write-Host "  $(Tx OldAndroid $sdk)" -ForegroundColor Red; return $false }
    return $true
}

function Comprobar-Movil {
    $d = & $adb devices 2>&1 | Out-String
    if ($d -notmatch "`tdevice") {
        Write-Host ''
        if ($d -match "`tunauthorized") { Write-Host $T.Unauth -ForegroundColor Red }
        else { Write-Host $T.NoDevice -ForegroundColor Red }
        Write-Host $d
        return $false
    }
    # With several devices, "adb shell" fails unless ANDROID_SERIAL says which one to use.
    if ([regex]::Matches($d, "`tdevice\b").Count -gt 1 -and -not $env:ANDROID_SERIAL) {
        Write-Host ''
        Write-Host $T.Multi -ForegroundColor Red
        Write-Host $d
        return $false
    }
    return $true
}

function Traducir([string]$lista) {
    $g = @()
    if ($lista -match '\bNR\b')                { $g += '5G' }
    if ($lista -match '\bLTE\b')               { $g += '4G' }
    if ($lista -match 'UMTS|HSDPA|HSUPA|HSPA') { $g += '3G' }
    if ($lista -match 'GSM|GPRS|EDGE')         { $g += '2G' }
    if ($g.Count -eq 0) { return "$($T.Nothing) $lista" }
    return ($g -join ' + ')
}

# ColorOS (realme/OPPO/OnePlus) only: Developer options > 5G network mode. $null elsewhere.
function Modo5G {
    $l = Adb 'settings list system'
    # Prefer the setting of the selected slot; fall back to any slot.
    if ($l -match "user_nr_mode$slot=(-?\d+)" -or $l -match 'user_nr_mode\d+=(-?\d+)') { if ($Matches[1] -eq '3') { return 'SA' } else { return $Matches[1] } }
    return $null
}

function Estado {
    if (-not (Comprobar-Movil)) { return }
    $perm = Adb "cmd phone get-allowed-network-types-for-users -s $slot"
    $reg  = Adb 'dumpsys telephony.registry'
    $red  = if ($reg -match 'mTelephonyDisplayInfo=TelephonyDisplayInfo \{network=([^,]+), overrideNetwork=([^,]+)') { "$($Matches[1]) (override $($Matches[2]))" } else { '?' }
    $op   = if ($reg -match 'mOperatorAlphaLong=([^,]+)') { $Matches[1] } else { '?' }
    $rsrp = if ($reg -match 'CellSignalStrengthLte: rssi=\S+ rsrp=(-?\d+)') { "$($Matches[1]) dBm" } else { '?' }
    $ims  = Adb "getprop gsm.ims.type$slot"
    Write-Host ''
    Write-Host "  $(Tx Slot $slot $op)" -ForegroundColor Cyan
    Write-Host "  $(Tx Allowed (Traducir $perm))" -ForegroundColor Yellow
    Write-Host "  $(Tx Now $red)"
    Write-Host "  $(Tx Rsrp $rsrp)"
    Write-Host "  $(Tx Ims $(if ($ims) { $ims } else { $T.Unknown }))"
    $m5 = Modo5G
    if ($m5) { Write-Host "  $(Tx Mode5g $(if ($m5 -eq 'SA') { 'NSA + SA' } else { Tx ModeOther $m5 }))" }
}

$bitsNombre = @{ 'GPRS'=0;'EDGE'=1;'UMTS'=2;'CDMA'=3;'CDMA - EvDo rev. 0'=4;'CDMA - EvDo rev. A'=5;'CDMA - 1xRTT'=6;'HSDPA'=7;'HSUPA'=8;'HSPA'=9;'IDEN'=10;'CDMA - EvDo rev. B'=11;'LTE'=12;'CDMA - eHRPD'=13;'HSPA+'=14;'GSM'=15;'TD_SCDMA'=16;'IWLAN'=17;'LTE_CA'=18;'NR'=19 }
function Lista-a-Mask([string]$lista) {
    $v = 0
    foreach ($n in $lista -split '\|') { $n = $n.Trim(); if ($bitsNombre.ContainsKey($n)) { $v = $v -bor (1 -shl $bitsNombre[$n]) } }
    return [Convert]::ToString($v,2).PadLeft(20,'0')
}

function Aplicar([string]$k) {
    if (-not (Comprobar-Movil)) { return }
    if (-not (Version-OK)) { return }
    $mask = $masks[$k]
    $m5 = Modo5G
    if ($mask -eq $MaskSolo5G -and $m5 -and $m5 -ne 'SA') {
        Write-Host "  $($T.NeedSa1)" -ForegroundColor Red
        Write-Host "  $($T.NeedSa2)" -ForegroundColor Red
        return
    }
    # Read the current mode first: if it cannot be read, change nothing, because restoring an
    # all-zero mask after a rejection would leave the phone with no networks at all.
    $antesTxt = Adb "cmd phone get-allowed-network-types-for-users -s $slot"
    $antes = Lista-a-Mask $antesTxt
    if ($antes -notmatch '1') {
        Write-Host "  $(Tx NoPrev $antesTxt)" -ForegroundColor Red
        return
    }
    $aviso = $T["W$k"]
    if ($aviso) { Write-Host "  $(Tx Warning $aviso)" -ForegroundColor DarkYellow }
    $r = Adb "cmd phone set-allowed-network-types-for-users -s $slot $mask"
    if ($r -match 'failed') {
        Write-Host "  $($T.Rejected)" -ForegroundColor Red
        Adb "cmd phone set-allowed-network-types-for-users -s $slot $antes" | Out-Null
        Start-Sleep -Seconds 3
        Write-Host "  $(Tx Restored (Traducir (Adb "cmd phone get-allowed-network-types-for-users -s $slot")))" -ForegroundColor Yellow
        return
    } elseif ($r) { Write-Host "  $(Tx Reply $r)" -ForegroundColor DarkGray }
    Start-Sleep -Seconds 4
    $perm = Adb "cmd phone get-allowed-network-types-for-users -s $slot"
    if ((Lista-a-Mask $perm) -eq $mask) {
        Write-Host "  $(Tx Applied $T["P$k"])" -ForegroundColor Green
    } else {
        Write-Host "  $(Tx Mismatch $T["P$k"])" -ForegroundColor Red
    }
    Write-Host "  $(Tx NowAllows (Traducir $perm))" -ForegroundColor Yellow
    Write-Host "  $($T.Wait)"
}

while ($true) {
    Clear-Host
    Write-Host '  ==============================================' -ForegroundColor Yellow
    Write-Host "   $($T.Header)" -ForegroundColor Yellow
    Write-Host '  ==============================================' -ForegroundColor Yellow
    Estado
    Write-Host ''
    foreach ($k in $masks.Keys) { Write-Host ("   {0}) {1}" -f $k, $T["P$k"]) }
    Write-Host ''
    Write-Host "   $($T.MenuE)"
    Write-Host "   $(Tx MenuS $slot)"
    Write-Host "   $($T.MenuQ)"
    Write-Host ''
    $op = "$(Read-Host "  $($T.Choose)")".Trim().ToUpper()
    if ($op -eq 'Q') { break }
    elseif ($op -eq 'E') { continue }
    elseif ($op -eq 'S') { $slot = if ($slot -eq 0) { 1 } else { 0 }; continue }
    elseif ($masks.Contains($op)) { Aplicar $op; Read-Host "  $($T.Back)" | Out-Null }
    else { Write-Host "  $($T.Invalid)" -ForegroundColor Red; Start-Sleep 1 }
}

}

# Run inside a script block so these variables do not leak into the user's session with "| iex",
# and give the window title and console encoding back when leaving (even with Ctrl+C).
& {
    $tituloPrevio = $Host.UI.RawUI.WindowTitle
    $codifPrevia  = [Console]::OutputEncoding
    try { Start-RedesMovil }
    finally {
        $Host.UI.RawUI.WindowTitle = $tituloPrevio
        [Console]::OutputEncoding  = $codifPrevia
    }
}
