# GarminColoreDataFields

Color-coded Garmin Edge data fields for riders who want the important numbers to be readable at a glance.

Instead of showing only a value, each field paints its entire background based on the current zone or range. That makes heart rate, power, cadence, and grade easier to read when your eyes should be on the road.

## Data Fields

| Field | Project | Shows | Background color |
| --- | --- | --- | --- |
| Color BG HR | `hr-zone-field` | Current heart rate | Garmin biking heart-rate zone |
| Color BG PWR | `power-zone-field` | Rolling 3-second power | Garmin cycling power zone |
| Color BG CAD | `cad-zone-field` | Current cadence | Custom cadence range |
| Color BG GRADE | `grade-zone-field` | Estimated road grade | Garmin-like climb gradient palette |
| PWR HR CAD Graph | `metric-graph-field` | Configurable rolling power, heart-rate, and cadence graph | Transparent background with overlaid colored traces |

Each field is a separate Connect IQ data field, so you can place them independently in your Garmin Edge activity profiles.

`PWR HR CAD Graph` is designed for the large box in a `3-B Fields` layout. It draws power, heart rate, and cadence on the same transparent graph. Each trace can be enabled independently and has configurable minimum, maximum, and offset settings. The history setting controls how many seconds each horizontal pixel represents: 1, 2, 3, or 5 seconds per pixel.

For a sideloaded `.prg`, change the graph settings on the Edge itself. Open the activity profile's data screens, select the graph field's settings, then press the Edge menu button when prompted. Garmin Connect and Garmin Express do not expose settings for manually sideloaded apps.

The default graph settings are:

| Trace | Color | Minimum | Maximum | Offset |
| --- | --- | --- | --- | --- |
| Power | Blue | 0 W | 500 W | 0 |
| Heart rate | Red | 80 bpm | 200 bpm | 0 |
| Cadence | Green | 50 rpm | 120 rpm | +30 |

## Colors

Open [color-palette.html](color-palette.html) locally to see the palette.

### HR and Power Zones

| Range | Color |
| --- | --- |
| No data / below zone 1 | White |
| Zone 1 | Blue |
| Zone 2 | Green |
| Zone 3 | Yellow |
| Zone 4 | Orange |
| Zone 5+ | Red |

### Cadence

| Cadence | Color |
| --- | --- |
| 0-70 rpm | Blue |
| 70-80 rpm | Yellow |
| 80-95 rpm | Green |
| 95-105 rpm | Orange |
| 105+ rpm | Red |

### Grade

Garmin does not appear to publish an exact live-grade color threshold table for Connect IQ. This project uses a Garmin-like ClimbPro-style palette:

| Grade | Color |
| --- | --- |
| Downhill below -1% | Blue |
| -1% to 3% | White |
| 3-6% | Green |
| 6-9% | Yellow |
| 9-12% | Orange |
| 12-15% | Red |
| 15%+ | Dark red |

`Color BG GRADE` estimates grade from altitude change over distance because Connect IQ does not expose a simple native `currentGrade` value through `Activity.Info`.

## Device Support

The manifests currently target:

- Edge 530
- Edge 540 / 540 Solar
- Edge 550
- Edge 840 / 840 Solar
- Edge 850
- Edge 1040 / 1040 Solar
- Edge 1050

`Color BG PWR` requires newer Connect IQ support because it uses `UserProfile.getPowerZones()`. If Garmin does not return a cycling power-zone array, the field falls back to the configured cycling FTP and standard 7-zone cycling percentages. If your device does not support the required APIs, build/use the HR, cadence, and grade fields instead or adjust the manifest and implementation for your model.

## Build

Install:

- Garmin Connect IQ SDK
- Garmin Monkey C extension for VS Code
- Device support packages for your Edge model

Create a Garmin developer key. You can use the VS Code command:

```text
Monkey C: Generate Developer Key
```

Or use the included Java helper:

```powershell
javac tools\GenerateDeveloperKey.java
java -cp tools GenerateDeveloperKey developer_key.der
```

Then build the fields:

```powershell
New-Item -ItemType Directory -Force bin | Out-Null

Push-Location hr-zone-field
monkeyc -f monkey.jungle -o "..\bin\Color BG HR.prg" -y ..\developer_key.der
Pop-Location

Push-Location power-zone-field
monkeyc -f monkey.jungle -o "..\bin\Color BG PWR.prg" -y ..\developer_key.der
Pop-Location

Push-Location cad-zone-field
monkeyc -f monkey.jungle -o "..\bin\Color BG CAD.prg" -y ..\developer_key.der
Pop-Location

Push-Location grade-zone-field
monkeyc -f monkey.jungle -o "..\bin\Color BG GRADE.prg" -y ..\developer_key.der
Pop-Location

Push-Location metric-graph-field
monkeyc -f monkey.jungle -o "..\bin\PWR HR CAD Graph.prg" -y ..\developer_key.der
Pop-Location
```

If `monkeyc` is not on your `PATH`, use the full path to `monkeyc.bat` inside your Connect IQ SDK `bin` folder.

## Download Release Builds

Prebuilt `.prg` sideload builds are attached to GitHub Releases when available. Download the fields you want from the latest release, then copy them to your Edge as described below.

These release binaries are unofficial sideload builds. They are not distributed through the Garmin Connect IQ Store, and device/firmware sideload behavior may vary.

## Install On Your Edge

1. Connect your Edge by USB.
2. Open the device storage in File Explorer.
3. Copy the built `.prg` files from `bin/` to:

```text
Garmin/Apps
```

4. Safely eject the device.
5. Restart or unplug the Edge and let it process the apps.
6. Add the fields from your activity profile data-screen settings under Connect IQ fields.

## Privacy

These fields run locally on your Garmin Edge. They do not make network requests, collect personal data, or send ride data anywhere.

## Repository Hygiene

The `.gitignore` excludes compiled apps, generated build files, local notes, and private signing keys. Do not commit your `developer_key.der`.

## Notes

This is an independent project and is not affiliated with, endorsed by, or supported by Garmin.
