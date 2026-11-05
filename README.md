# redes-movil-adb

**English** | [Español](README.es.md)

Choose from your PC which mobile networks your Android phone may use (**5G, 4G, 3G, 2G**) with a simple menu, **no root** and nothing installed on the phone.

```
  ==============================================
   MOBILE NETWORKS  (via ADB)
  ==============================================

  SIM slot 0  -  Carrier: Movistar
  Allowed networks : 5G + 4G
  Connected now    : LTE (override NR_NSA)
  4G signal (RSRP) : -95 dBm
  IMS (4G calls)   : volte

   1) 5G + 4G (no 3G or 2G)
   2) 5G + 4G + 2G (no 3G)
   3) 4G only
   4) 5G only
   5) 4G + 3G + 2G (no 5G)
   6) All (5G + 4G + 3G + 2G)
   7) 3G only
   8) 2G only

   E) Show status again
   S) Switch SIM slot (now: 0)
   Q) Quit
```

## What is it for?

As carriers shut down 3G, many phones in weak-coverage areas latch onto 4G/5G and, a few seconds later, **drop to 3G/H+ and lose mobile data**: what is left of 3G has so little spectrum that it barely works.

The settings on many phones (realme, OPPO, OnePlus, Samsung, Xiaomi…) do not offer "5G + 4G" or "4G only". The hidden `*#*#4636#*#*` menu is often blocked or does not keep the change, and network-forcing apps usually need root.

This script uses a standard Android command (`cmd phone set-allowed-network-types-for-users`) over ADB to set exactly which networks are allowed.

## Requirements

- **Windows** with PowerShell (included in Windows 10/11). The program is shown in Spanish if Windows is in Spanish, and in English otherwise.
- **Android 12 or later.**
- **ADB** ([Android SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools)). The script looks for it in PATH, in `Documents\platform-tools`, in the Android SDK, or in a `platform-tools` folder next to the script (option B).
- **USB debugging** enabled on the phone (Settings › About phone › tap "Build number" 7 times; then Developer options › USB debugging).

## Usage

First, connect the phone via USB, unlock it and accept the "Allow USB debugging?" prompt.

### Option A: run it without downloading anything

Open **PowerShell** (Windows key, type `powershell`, Enter) and paste:

```powershell
iex ([Text.Encoding]::UTF8.GetString((iwr -useb https://github.com/vkthor/redes-movil-adb/releases/latest/download/redes-movil.ps1).Content).TrimStart([char]0xFEFF))
```

It always runs the latest published release and saves nothing on the PC. ADB must be in PATH or in `Documents\platform-tools`.

Some antivirus programs may block this command, because downloading and running code straight in memory is a technique also used by malware. If that happens, use option B.

### Option B: download it

1. Go to [Releases](https://github.com/vkthor/redes-movil-adb/releases/latest) and download **`redes-movil.ps1`** and **`Redes-del-movil.cmd`**. Save them in the same folder.
2. If you do not have ADB, unzip `platform-tools` into that same folder.
3. Double-click **`Redes-del-movil.cmd`**.

Either way, pick an option from the menu. The script applies the change and checks that the phone kept it.

The recommended option to avoid drops to 3G is **1) 5G + 4G**. Calls will keep working over 4G if your line has **VoLTE** (the "IMS" line in the status shows it).

### Doing it by hand

```
adb shell cmd phone get-allowed-network-types-for-users -s 0
adb shell cmd phone set-allowed-network-types-for-users -s 0 11000001000000000000
```

The 20-digit number is a bit mask; each position is a network type (left to right: NR/5G, LTE_CA, …, GPRS). The mask for each profile is in the script.

## Limitations

- **Without VoLTE there are no calls** in the modes that remove 2G and 3G.
- **The manufacturer may undo the change** after a reboot, an update, or touching the network setting in Settings. If so, connect the phone again and reapply it.
- **The modem may reject some combinations.** If it does, the script warns you and restores the previous mode.
- **5G only** requires 5G SA (*standalone*) and a network that offers it, which is uncommon. On ColorOS (realme/OPPO/OnePlus) you first have to enable Developer options › 5G network mode › **NSA + SA**; the script checks this. Without VoNR there are no calls in this mode.
- **Dual SIM:** it works on slot 0 by default; press **S** to switch to the other one.
- **Several devices connected** (another phone, an emulator…): leave only the phone connected, or tell the script which one to use with `$env:ANDROID_SERIAL = '<serial>'` before running it (the serial is shown by `adb devices`).
- Tested on a realme GT7 (Android 16, ColorOS). It should work on other phones, but has not been tested on them.

## License

[GPL-3.0](LICENSE) © 2026 Víctor Cruz
