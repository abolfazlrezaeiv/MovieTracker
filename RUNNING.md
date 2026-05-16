# Running MovieTracker

How to build and run the app on the iOS Simulator or a physical device.

## Prerequisites

- macOS with **Xcode** installed
- **Apple ID** added in Xcode → **Settings → Accounts** (free account works for your own device)
- For a physical device: USB cable, device unlocked, **Trust This Computer** accepted
- iOS 16+: enable **Developer Mode** on the device (**Settings → Privacy & Security → Developer Mode**)

## Project details

| Item | Value |
|------|--------|
| Scheme | `MovieTracker` |
| Bundle ID | `come.movie.MovieTracker` |
| Project file | `MovieTracker.xcodeproj` |

---

## Option 1: Xcode (recommended)

1. Open `MovieTracker.xcodeproj` in Xcode.
2. Select a run destination in the toolbar:
   - **Simulator** — e.g. iPhone 16
   - **Device** — e.g. Cake
3. Press **⌘R** (Run).

Xcode builds, installs, and launches the app in one step.

### First run on a physical device

If the app does not open:

1. On the device: **Settings → General → VPN & Device Management**
2. Trust your developer certificate
3. Run again from Xcode (**⌘R**)

### Signing

**MovieTracker** target → **Signing & Capabilities** → enable **Automatically manage signing** and choose your **Team**.

---

## Option 2: Command line

All commands assume you are in the project directory:

```bash
cd "/Users/abolfazlrezaei/Documents/Swift project/MovieTracker"
```

### List devices and simulators

```bash
xcrun xctrace list devices
```

Example physical device:

```text
Cake (26.4.2) (00008110-001A65CC3E11A01E)
```

Use either the **name** or **id** in `-destination` below.

---

### Simulator

**Build and run:**

```bash
xcodebuild -scheme MovieTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build

# Install + launch (after a successful build)
APP="$HOME/Library/Developer/Xcode/DerivedData/MovieTracker-arfrqgnqanuseqcssixdbcfqzula/Build/Products/Debug-iphonesimulator/MovieTracker.app"
xcrun simctl boot "iPhone 16" 2>/dev/null || true
xcrun simctl install booted "$APP"
xcrun simctl launch booted come.movie.MovieTracker
```

> **Note:** The DerivedData folder name (`MovieTracker-arfrqgnqanuseqcssixdbcfqzula`) is stable for this machine but may differ elsewhere. To resolve the app path dynamically:
>
> ```bash
> APP=$(find ~/Library/Developer/Xcode/DerivedData/MovieTracker-*/Build/Products/Debug-iphonesimulator -maxdepth 1 -name 'MovieTracker.app' | head -1)
> ```

---

### Physical device (e.g. Cake)

**1. Build**

```bash
xcodebuild -scheme MovieTracker \
  -destination 'platform=iOS,id=00008110-001A65CC3E11A01E' \
  -allowProvisioningUpdates \
  build
```

Or by device name:

```bash
xcodebuild -scheme MovieTracker \
  -destination 'platform=iOS,name=Cake' \
  -allowProvisioningUpdates \
  build
```

**2. Install** — must point to **`MovieTracker.app`**, not the project folder:

```bash
APP="$HOME/Library/Developer/Xcode/DerivedData/MovieTracker-arfrqgnqanuseqcssixdbcfqzula/Build/Products/Debug-iphoneos/MovieTracker.app"

xcrun devicectl device install app \
  --device 00008110-001A65CC3E11A01E \
  "$APP"
```

**3. Launch**

```bash
xcrun devicectl device process launch \
  --device 00008110-001A65CC3E11A01E \
  come.movie.MovieTracker
```

**One-liner (build + install + launch)**

```bash
cd "/Users/abolfazlrezaei/Documents/Swift project/MovieTracker" && \
xcodebuild -scheme MovieTracker \
  -destination 'platform=iOS,id=00008110-001A65CC3E11A01E' \
  -allowProvisioningUpdates build && \
APP="$HOME/Library/Developer/Xcode/DerivedData/MovieTracker-arfrqgnqanuseqcssixdbcfqzula/Build/Products/Debug-iphoneos/MovieTracker.app" && \
xcrun devicectl device install app --device 00008110-001A65CC3E11A01E "$APP" && \
xcrun devicectl device process launch --device 00008110-001A65CC3E11A01E come.movie.MovieTracker
```

Verify the `.app` exists before installing:

```bash
ls "$HOME/Library/Developer/Xcode/DerivedData/MovieTracker-arfrqgnqanuseqcssixdbcfqzula/Build/Products/Debug-iphoneos/MovieTracker.app"
```

---

## Troubleshooting

### Install error: “not of a type that CoreDevice recognizes”

You passed a **directory** (e.g. the project root) instead of **`MovieTracker.app`**. Use the full path ending in `.app` (see install step above).

### App closes immediately on launch (SwiftData migration)

After changing the `FavoriteMovie` model, an old database on the device can fail to migrate. The app resets the store automatically when needed. If problems persist:

1. Delete **MovieTracker** from the device
2. Build and install again from Xcode (**⌘R**)

### “Failed to instantiate the default view controller for Main”

`Main.storyboard` must have an **Initial View Controller** set (tab bar). This is configured in the project; use the latest `Main.storyboard` if you see this warning on an old build.

### Device not listed

- Unlock the device and trust the Mac
- Enable **Developer Mode** on the device
- Re-run: `xcrun xctrace list devices`

### `find` returned empty for `MovieTracker.app`

Use `-maxdepth 1` when searching under `Debug-iphoneos`, or set `APP` to the explicit DerivedData path from a successful **BUILD SUCCEEDED** output.

---

## Wireless debugging (optional)

1. Connect the device once via USB and run successfully from Xcode.
2. **Window → Devices and Simulators** → select the device → **Connect via network**.
3. Choose the same device from the Xcode run destination menu over Wi‑Fi.
