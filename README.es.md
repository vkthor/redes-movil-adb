# redes-movil-adb

[English](README.md) | **Español**

Elige desde tu PC qué redes móviles puede usar tu Android (**5G, 4G, 3G, 2G**) con un menú sencillo, **sin root** y sin instalar nada en el móvil.

```
  ==============================================
   REDES DEL MÓVIL  (vía ADB)
  ==============================================

  SIM ranura 0  -  Operador: Movistar
  Redes permitidas : 5G + 4G
  Conectado ahora  : LTE (override NR_NSA)
  Señal 4G (RSRP)  : -95 dBm
  IMS (llamadas 4G): volte

   1) 5G + 4G (sin 3G ni 2G)
   2) 5G + 4G + 2G (sin 3G)
   3) Sólo 4G
   4) Sólo 5G
   5) 4G + 3G + 2G (sin 5G)
   6) Todas (5G + 4G + 3G + 2G)
   7) Sólo 3G
   8) Sólo 2G

   E) Ver estado otra vez
   S) Cambiar ranura SIM (ahora: 0)
   Q) Salir
```

## ¿Para qué sirve?

Con el apagado progresivo del 3G, en zonas de poca cobertura muchos móviles se enganchan a 4G/5G y, a los pocos segundos, **bajan a 3G/H+ y se quedan sin datos**: el 3G que queda tiene tan poco espectro que apenas funciona.

Los Ajustes de muchos móviles (Realme, OPPO, OnePlus, Samsung, Xiaomi…) no permiten elegir «5G + 4G» o «sólo 4G». El menú oculto `*#*#4636#*#*` suele estar bloqueado o no guarda el cambio, y las apps para forzar red normalmente piden root.

Este script usa un comando estándar de Android (`cmd phone set-allowed-network-types-for-users`) a través de ADB para fijar exactamente qué redes se permiten.

## Requisitos

- **Windows** con PowerShell (incluido en Windows 10/11). El programa sale en español si Windows está en español y en inglés en cualquier otro caso.
- **Android 12 o superior.**
- **ADB** ([Android SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools)). El script lo busca en el PATH, en `Documentos\platform-tools`, en el SDK de Android o en una carpeta `platform-tools` junto al script (opción B).
- **Depuración USB** activada en el móvil (Ajustes › Información del teléfono › pulsa 7 veces en «Número de compilación»; después, Opciones de desarrollador › Depuración USB).

## Uso

Antes de nada, conecta el móvil por USB, desbloquéalo y acepta el aviso «¿Permitir depuración USB?».

### Opción A: ejecutarlo sin descargar nada

Abre **PowerShell** (tecla Windows, escribe `powershell`, Enter) y pega:

```powershell
iex ([Text.Encoding]::UTF8.GetString((iwr -useb https://github.com/vkthor/redes-movil-adb/releases/latest/download/redes-movil.ps1).Content).TrimStart([char]0xFEFF))
```

Ejecuta siempre la última versión publicada, sin guardar nada en el PC. Necesitas tener ADB en el PATH o en `Documentos\platform-tools`.

Algunos antivirus pueden bloquear esta orden, porque descargar y ejecutar código directamente en memoria es una técnica que también usa el malware. Si te pasa, usa la opción B.

### Opción B: descargarlo

1. Entra en [Releases](https://github.com/vkthor/redes-movil-adb/releases/latest) y descarga **`redes-movil.ps1`** y **`Redes-del-movil.cmd`**. Guárdalos en la misma carpeta.
2. Si no tienes ADB, descomprime `platform-tools` dentro de esa misma carpeta.
3. Haz doble clic en **`Redes-del-movil.cmd`**.

En los dos casos, elige una opción del menú. El script aplica el cambio y comprueba que el móvil lo ha guardado.

La opción recomendada para evitar las caídas a 3G es **1) 5G + 4G**. Las llamadas seguirán funcionando por 4G si tu línea tiene **VoLTE** (la línea «IMS» del estado lo indica).

### Hacerlo a mano

```
adb shell cmd phone get-allowed-network-types-for-users -s 0
adb shell cmd phone set-allowed-network-types-for-users -s 0 11000001000000000000
```

El número de 20 cifras es una máscara de bits; cada posición es un tipo de red (de izquierda a derecha: NR/5G, LTE_CA, …, GPRS). Consulta las máscaras de cada perfil en el script.

## Limitaciones

- **Sin VoLTE no hay llamadas** en los modos que quitan 2G y 3G.
- **El fabricante puede deshacer el cambio** al reiniciar, actualizar o tocar el ajuste de red en Ajustes. Si pasa, vuelve a conectar el móvil y aplícalo otra vez.
- **El módem puede rechazar algunas combinaciones.** Si lo hace, el script avisa y deja el modo anterior.
- **Sólo 5G** exige 5G SA (*standalone*) y una red que lo ofrezca, cosa poco habitual. En ColorOS (Realme/OPPO/OnePlus) hay que activar antes Opciones de desarrollador › Modo de red 5G › **NSA + SA**; el script lo comprueba. Sin VoNR, en este modo no hay llamadas.
- **Doble SIM:** por defecto actúa sobre la ranura 0; pulsa **S** para cambiar a la otra.
- **Varios dispositivos conectados** (otro móvil, un emulador…): deja conectado sólo el móvil, o indica al script cuál usar con `$env:ANDROID_SERIAL = '<número de serie>'` antes de ejecutarlo (el número de serie lo muestra `adb devices`).
- Probado en un Realme GT7 (Android 16, ColorOS). En otros móviles debería funcionar, pero no está probado.

## Licencia

[GPL-3.0](LICENSE) © 2026 Víctor Cruz
