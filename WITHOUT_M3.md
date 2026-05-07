# Architektur-Analyse: Betrieb ohne Cortex-M3

Diese Dokumentation beschreibt die Vor- und Nachteile der Entfernung des Cortex-M3 (Gowin EMPU) aus dem VGA-zu-HDMI Projekt auf dem Tang Nano 4K.

## Aktueller Status
Momentan ist der Cortex-M3 in `src/top.v` instanziiert, wird aber für den primären Video-Pfad (VGA -> HDMI) **nicht** benötigt. Die Tiny Tapeout (TT) Module sind direkt mit der HDMI-Logik verbunden. Die APB-Bridge (`tt_m3_wrapper`) dient lediglich als optionales Interface für Firmware-Interaktionen.

## Vorteile ohne Cortex-M3 (RTL-only Flow)

1. **Vollständige Open-Source Toolchain Kompatibilität**:
   - `yosys` und `nextpnr-gowin` unterstützen die proprietären Gowin EMPU IP-Cores nicht oder nur eingeschränkt. Ein Verzicht ermöglicht einen stabilen Build-Prozess ohne kommerzielle IDE (Gowin EDA).
2. **Geringere Komplexität**:
   - Keine Notwendigkeit für Firmware-Management (C-Code, Linker-Skripte, Startup-Code).
   - Vereinfachtes Design ohne APB-Bus-Infrastruktur.
3. **Ressourceneffizienz**:
   - Einsparung von FPGA-Gattern, die sonst für die APB-Interconnects und Register-Bridges genutzt würden.
4. **Schnellere Iterationszyklen**:
   - Deutlich verkürzte Synthese- und Place-and-Route-Zeiten, da der massive M3-Block nicht verarbeitet werden muss.
5. **Portabilität**:
   - Das Design lässt sich leichter auf andere FPGAs portieren, die keinen integrierten M3-Kern besitzen.

## Nachteile ohne Cortex-M3

1. **Verlust der dynamischen Konfiguration**:
   - Ohne Firmware ist es schwierig, TT-Module zur Laufzeit zu steuern (z.B. Eingangsdaten über UART setzen oder Modi umschalten).
2. **Erschwerte Protokoll-Implementierung**:
   - Komplexe Funktionen wie HDMI-CEC, EDID-Parsing oder dynamische Audio-Generierung sind in C wesentlich einfacher umzusetzen als in reiner Hardware (RTL).
3. **Eingeschränktes Debugging**:
   - Die Möglichkeit, den internen Status des TT-Moduls über eine serielle Konsole (UART) auszulesen, entfällt.
4. **Interaktion mit Tiny Tapeout**:
   - Die M3-APB-Bridge erlaubt es, TT-Designs "virtuell" zu steuern. Ohne M3 müssen Eingabesignale (`ui_in`) fest verdrahtet oder über physische Pins des Tang Nano 4K zugeführt werden.

## Empfehlung

Für die **Kernfunktionalität** (VGA zu HDMI Brücke) ist der M3 **nicht erforderlich**. Es wird empfohlen, eine Architektur zu unterstützen, die den M3 als **optionales Modul** behandelt. Dies ermöglicht die Nutzung der vollen Open-Source Toolchain für die meisten Anwendungsfälle, während die APB-Erweiterung für fortgeschrittene "System-on-Chip" Szenarien erhalten bleibt.
