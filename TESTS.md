# FSCMS — Manual Test Cases

Since FSCMS relies on Web Bluetooth and physical BLE sensors, testing is primarily manual. This document lists all test scenarios.

## Prerequisites

- Chrome/Edge browser with Web Bluetooth support
- Enable `chrome://flags/#enable-web-bluetooth-new-permissions-backend` for full functionality
- At least one Mijia LYWSD03MMC sensor (ATC custom firmware preferred, SHT4x inside)
- Bluetooth enabled on test device

---

## 1. Sensor Connection

### 1.1 Auto Pair
- Click **Add Sensor** → **Auto Pair Nearby**
- Verify browser shows Bluetooth pairing dialog with ATC_ devices listed
- Select a sensor → verify card appears with live temp/humidity/battery
- Verify green connection indicator shows

### 1.2 Manual Pick
- Click **Add Sensor** → **Pick Single ATC Sensor**
- Verify only ATC_ prefixed devices appear in the picker
- Select one → verify connection and data flow

### 1.3 Incompatible Device
- If a non-LYWSD03MMC device is somehow selected, verify the "Incompatible device" alert fires
- Verify no card is created for unsupported devices

---

## 2. Reconnect

### 2.1 Single Reconnect
- Connect a sensor, then move it out of range or power cycle it
- Verify the card shows "Reconnect" button (not live data)
- Click **Reconnect** → verify browser BLE prompt appears and sensor reconnects
- Verify this works for sensors with custom friendly names

### 2.2 Batch Reconnect All
- Connect 2+ sensors, then disconnect them (e.g., reload the page)
- Click **Reconnect All** in the Add Sensor modal
- Verify sequential connection with ~2s delay between each device
- Verify progress alerts ("Connecting 1/3: ATC_C4B249...")
- Click **Cancel** mid-batch → verify remaining devices are skipped
- Requires `getDevices()` API — verify error message points to Chrome flag if unavailable

### 2.3 Saved Device Reconnect
- Pair a sensor, reload the page
- Verify saved-only card appears with Reconnect and Forget buttons
- Click **Reconnect** → verify it works via fresh `requestDevice({ name })`

---

## 3. Forget Device

### 3.1 Forget Confirmation
- Click **Forget** on any sensor card
- Verify red-bordered confirmation modal appears
- Verify warning text mentions permanent data deletion
- Click **Cancel** → verify sensor is still present

### 3.2 Forget Execution
- Click **Forget** → **Yes, Forget**
- Verify sensor card is removed
- Verify sensor is removed from localStorage (knownDevices, settings.names)
- Verify IndexedDB history for that sensor is deleted
- Verify debug panel no longer shows perf stats for that sensor

---

## 4. Data Display

### 4.1 Temperature Rounding
- Verify temperature displays rounded to 0.1°C steps (matches SHT4x ±0.2°C accuracy)
- Check both dashboard cards and debug log

### 4.2 Humidity Rounding
- Verify humidity displays rounded to nearest 1% steps (matches SHT4x ±1.8% RH accuracy)
- Check both dashboard cards and alert messages

### 4.3 Battery
- Verify battery percentage shows (0–100%)
- Verify voltage shows in card footer (e.g., 2.95V)

### 4.4 Last Update Timestamp
- Verify "Last update" time refreshes on each new reading
- Verify time format is readable (e.g., "2m ago" or timestamp)

---

## 5. Historical Charts

### 5.1 Chart Rendering
- Connect a sensor and wait for several readings
- Verify dual-axis chart appears (temperature left axis, humidity right axis)
- Verify chart updates with new data points

### 5.2 IndexedDB Persistence
- Connect sensor, collect some data
- Reload page → verify chart still shows historical data
- Verify data older than retention period is automatically cleaned up

---

## 6. Humidity Alerts

### 6.1 Warning Threshold
- Set warning threshold to a value below current humidity (Settings or per-device)
- Verify yellow alert banner appears
- Verify humidity text turns yellow on sensor card

### 6.2 Critical Threshold
- Set critical threshold below current humidity
- Verify red alert banner with "CRITICAL" prefix
- Verify browser notification fires (if permission granted)
- Verify card border turns red

### 6.3 Alert Cooldown
- Trigger an alert → verify no repeat notification within 30 minutes for same sensor
- A different sensor should still trigger independently

---

## 7. Temperature Alerts

### 7.1 Per-Device Temperature Warning
- Open device settings (gear icon) → set temperature warning threshold below current temp
- Verify yellow alert banner with temperature reading
- Verify temperature text turns yellow on sensor card

### 7.2 Per-Device Temperature Critical
- Set temperature critical threshold below current temp
- Verify red alert banner with "CRITICAL" prefix
- Verify push notification fires
- Verify separate cooldown from humidity alerts (`sensorId_temp` key)

### 7.3 No Global Default
- Verify that temperature alerts only fire when explicitly configured per-device
- With no per-device temp thresholds set, no temp alerts should fire

---

## 8. Battery Alerts

### 8.1 Low Battery Warning
- Use a sensor with battery below 20%
- Verify that after 5 consecutive frames below 20%, a "Low Battery Level Warning" alert fires
- Verify 1-hour cooldown before re-alerting for the same sensor

### 8.2 Critical Battery Warning
- Use a sensor with battery at or below 10%
- Verify immediate "Critical Battery Level Warning, Replace battery as soon as possible!" alert
- Verify push notification fires (if permission granted)
- Verify 1-hour cooldown before re-alerting

### 8.3 Counter Reset
- If battery goes back above 20%, verify the low-battery counter resets to 0

---

## 9. Battery Profiles (Dashboard)

### 9.1 Profile Selection
- Verify battery profile dropdown on Dashboard toolbar (right side, battery icon)
- Verify four profiles: Realtime, Balanced, Battery Saver, Ultra Saver
- Select a different profile → verify status message

### 9.2 Firmware Write
- Connect a sensor, then select a different battery profile from dropdown
- Verify cmd 0x55 is written to the sensor (check BLE Performance Log)
- Verify status message shows "Profile applied to X/Y sensor(s)"
- Verify firmware measure_interval, advertising_interval, and tx_power change

### 9.3 No Sensors Connected
- Disconnect all sensors, change battery profile
- Verify message: "Profile saved. Connect sensors to apply."

### 9.4 Auto-Apply on Connect
- Set battery profile to "Battery Saver", then connect a new sensor
- Verify profile is automatically written after connection (check debug log for "Auto-applied")

### 9.5 Per-Device Override
- Open device settings (gear icon) → select a device-specific battery profile
- Change the global profile → verify this sensor is **skipped** (not overwritten)
- Verify the per-device profile is auto-applied on reconnect instead of global

### 9.6 Persistence
- Change battery profile, reload page
- Verify saved profile is restored from localStorage

### 9.7 Storage Throttle
- Select "Realtime" profile (10s storage rate) → verify IndexedDB entries every ~10s
- Switch to "Ultra Saver" (300s storage rate) → verify entries slow down
- Verify live dashboard card values still update on every notification regardless of throttle
- Per-device throttle respects per-device battery profile if set

---

## 10. Per-Device Settings

### 10.1 Open Modal
- Click the gear icon on any connected sensor tile
- Verify modal opens showing device name, humidity/temperature thresholds, battery profile dropdown

### 10.2 Humidity Thresholds
- Set per-device humidity warning to 40% and critical to 60%
- Verify card border color changes based on per-device thresholds (not global)
- Verify alerts use per-device thresholds

### 10.3 Temperature Thresholds
- Set per-device temperature warning to 25°C, critical to 35°C
- Verify temperature text turns yellow/red on card when exceeded
- Verify alert fires with correct threshold value in message

### 10.4 Battery Profile Override
- Select "Ultra Saver" for one specific device
- Verify that device gets Ultra Saver written on connect
- Verify other devices still use the global profile
- Verify notification throttle uses per-device storageRate for that sensor

### 10.5 Reset to Global
- Click "Reset to Global" in device settings modal
- Verify per-device overrides are cleared
- Verify sensor falls back to global thresholds and profile

### 10.6 Persistence
- Set per-device thresholds, reload page
- Verify settings persist in `settings.deviceSettings[sensorId]`

### 10.7 Saved-Only Devices
- Click gear icon on a saved-only (disconnected) tile
- Verify modal opens and thresholds can be configured for when it reconnects

---

## 11. Disconnect Per-Device

### 11.1 Disconnect Button
- Verify bluetooth-off icon appears on each connected sensor tile (next to gear icon)
- Click it → verify sensor disconnects immediately
- Verify card shows "Reconnect" button, LIVE badge disappears
- Verify success alert: "Disconnected [sensor name]"

### 11.2 No Button When Disconnected
- Verify disconnect icon only shows for connected (LIVE) sensors, not saved-only tiles

---

## 12. Tile Sorting

### 12.1 Sort Dropdown
- Verify sort dropdown on Dashboard toolbar (left side, arrow icon)
- Options: "A → Z" and "Last Updated"

### 12.2 Alphabetical Sort
- Select "A → Z" → verify tiles are sorted by display name (friendly name if set)
- Rename a sensor → verify sort updates

### 12.3 Last Updated Sort
- Select "Last Updated" → verify most recently updated sensor appears first
- Saved-only (no timestamp) tiles should sort to the bottom

### 12.4 Persistence
- Change sort mode, reload → verify sort preference persists

---

## 13. Frame Logging (IndexedDB)

### 13.1 Every Frame Stored
- Connect a sensor, verify frames appear in IndexedDB `frames` store
- Every BLE notification should create a frame entry (unthrottled)
- Verify frame contains: sensor, name, time, source, raw hex, temp, humi, voltage, batt

### 13.2 Source Types
- In Poll mode, verify `custom_0x33` and/or `mi_temp` source types
- In Advert mode, verify `adv_pvvx`, `adv_atc1441`, `adv_bthome`, or `adv_milike` sources

### 13.3 Raw Hex
- Verify `raw` field contains space-separated hex bytes (e.g., "33 b4 0b 09 08 ...")
- Verify hex matches the actual BLE frame content

### 13.4 Retention Cleanup
- Verify frames older than retention days are cleaned on startup
- Change retention to 1 day → reload → verify old frames are purged

### 13.5 Clear All
- Click "Clear All Data" in Settings → verify both `history` and `frames` stores are emptied

---

## 14. CSV Export

### 14.1 Export Frames CSV
- Collect some data, then go to Settings → Data Management → **Export Frames CSV**
- Verify CSV file downloads with name `fscms_frames_YYYY-MM-DD.csv`
- Open CSV → verify columns: timestamp, iso_time, sensor_id, sensor_name, source, temp_c, humidity_pct, voltage_mv, battery_pct, raw_hex
- Verify data is sorted by timestamp ascending
- Verify raw_hex is quoted (no CSV parsing issues with spaces)

### 14.2 Export History CSV
- Click **Export History CSV**
- Verify CSV downloads with name `fscms_history_YYYY-MM-DD.csv`
- Verify columns: timestamp, iso_time, sensor_id, sensor_name, temp_c, humidity_pct, battery_pct
- Verify history has fewer rows than frames (throttled vs unthrottled)

### 14.3 No Data
- Clear all data, then click Export → verify warning "No frames recorded yet."

### 14.4 Large Dataset
- Let sensors run for several hours, then export
- Verify export completes and file is valid CSV (open in spreadsheet app)

---

## 15. BLE Mode Toggle

### 15.1 Poll to Advert
- Connect sensors in Poll mode
- Toggle the BLE mode switch in the header to Advert
- Verify `watchAdvertisements()` is started on connected devices (check BLE Performance Log)
- Verify GATT connections are disconnected to save battery
- Verify toggle turns amber and label shows "ADV"

### 15.2 Advert Data Reception
- In Advert mode, verify sensor cards still update with temperature/humidity/battery
- Verify advertisement format is detected (PVVX Custom, ATC1441, BTHome, Mi-Like)
- Verify frames are logged with correct `adv_*` source type

### 15.3 Advert to Poll
- Toggle back to Poll mode
- Verify advertisement watching stops
- Verify toggle returns to zinc/gray state

### 15.4 No Devices Warning
- Without any paired devices, switch to Advert mode
- Verify warning: "No devices available for advertisement watching..."
- Verify mode reverts to Poll automatically

### 15.5 Missing Chrome Flags
- Without `enable-web-bluetooth-new-permissions-backend` flag, try Advert mode
- Verify error message mentions specific Chrome flag to enable

### 15.6 Persistence
- Switch to Advert mode, reload the page
- Verify mode is restored and scan resumes via `getDevices()` + `watchAdvertisements()`

---

## 16. BLE Capability Check

### 16.1 Startup Warning
- Open FSCMS without `enable-web-bluetooth-new-permissions-backend` Chrome flag
- Verify warning banner on startup about missing Chrome flag
- Verify debug log shows BLE caps: `getDevices=false, watchAdvertisements=false`

### 16.2 All Flags Enabled
- Enable the Chrome flag, reload
- Verify no warning banner on startup
- Verify debug log shows `getDevices=true`

---

## 17. Settings

### 17.1 Friendly Names
- Double-click sensor name on card → enter a custom name
- Verify name persists across page reloads
- Verify reconnect still works after renaming

### 17.2 Global Threshold Configuration
- Open Settings, change warning/critical humidity thresholds
- Verify new thresholds are applied immediately to sensors without per-device overrides
- Verify sensors with per-device overrides are unaffected
- Verify settings persist across reloads

### 17.3 Data Retention
- Change history retention days, verify old data (both history and frames) is cleaned on next startup

---

## 18. Flasher Tab — Simple Mode

### 18.1 File Validation
- Open Flasher tab (default is Simple mode)
- Upload a valid ATC firmware .bin file → verify info panel shows size
- Upload a random non-firmware file → verify rejection with error message
- Upload a file >512KB → verify "File too large" error

### 18.2 Flash Process
- Start OTA with valid firmware on a connected sensor
- Verify progress bar advances
- Verify sensor reconnects after flash completes
- **Caution:** Only test with known-good firmware files

---

## 19. Flasher Tab — Advanced Mode

### 19.1 Mode Toggle
- Click "Advanced" toggle in the Flasher tab
- Verify Advanced panel shows with all sections: Device Connection, Sensor Config, Comfort Params, Triggers, Mi Auth, Device Management, Advanced OTA, Flasher Log

### 19.2 Device Connection
- Click Connect in Advanced mode → verify BLE pairing dialog
- Verify device info populates (name, MAC, hardware/software version)
- Click Disconnect → verify clean disconnect

### 19.3 Sensor Configuration
- Connect via Flasher → verify config auto-loads (adv type, intervals, TX power, offsets)
- Change measure interval → Write Config → verify config is written (check Flasher Log)
- Read config back → verify changes persisted on the device

### 19.4 Mi Authorization
- Click "Get Bind Key" → verify bind key is retrieved and displayed (cmd 0x44 response)
- Verify bind key hex string appears in the input field

### 19.5 Remote Firmware Load
- Click "Load from GitHub" → verify firmware binary loads from remote URL
- Verify file info shows after load

### 19.6 Flasher Log
- Verify all operations produce color-coded log entries (info, success, error)
- Verify log scrolls to latest entry automatically

---

## 20. About Tab

### 20.1 Content
- Open About tab → verify project overview, features list, tech stack grid, compatible devices, and credits are shown
- Verify build hash is displayed

---

## 21. Alert History Bell

### 21.1 Bell Badge
- Trigger any alert → verify bell icon in header shows a count badge
- Trigger more alerts → verify badge count increments

### 21.2 Alert Panel
- Click bell → verify alert history panel opens with timestamped entries
- Verify color coding (yellow for warning, red for critical)

---

## 22. Debug Panel

### 22.1 Panel Access
- Click the **Debug** button in the header
- Verify modal opens with connection stats, notification rates, and event log

### 22.2 Performance Metrics
- Connect a sensor, trigger some reads
- Verify timing entries appear with color coding (green <100ms, yellow, amber, red >2s)
- Verify notification rate stats (avg/min/max/count) per sensor

### 22.3 Export
- Click export in debug panel → verify log data can be copied/saved

### 22.4 Clear
- Click clear → verify all perf stats and log entries are wiped

---

## 23. PWA

### 23.1 Install Prompt
- Open in Chrome on desktop or Android
- Verify install prompt appears (or install option in browser menu)
- Install → verify app opens in standalone window

### 23.2 Offline Mode
- Install the PWA, then go offline (airplane mode / disable WiFi)
- Open the app → verify it loads from service worker cache
- Verify previously connected sensor data is still visible from IndexedDB

### 23.3 Responsive Layout
- Test at phone width (~375px) → verify single-column card layout
- Test at tablet width (~768px) → verify cards adjust
- Test at desktop width (~1200px) → verify multi-column grid

---

## 24. Edge Cases

### 24.1 No Bluetooth
- Open in a browser without Web Bluetooth (Firefox, Safari)
- Verify graceful error message, no JS crashes

### 24.2 Sensor Out of Range
- Connect sensor, then move it out of BLE range
- Verify disconnect is detected and card updates to show Reconnect button

### 24.3 Multiple Sensors
- Connect 3 sensors simultaneously
- Verify all cards render, charts work independently, no cross-sensor data contamination

### 24.4 Rapid Connect/Disconnect
- Connect and disconnect the same sensor several times quickly
- Verify no duplicate cards or ghost entries

### 24.5 Notification Throttling
- In Realtime profile, verify live card updates on every firmware push (~4s)
- In Ultra Saver profile, verify card still updates live but IndexedDB stores only every ~5 min
- Verify frames store captures every notification regardless of throttle

### 24.6 IndexedDB v2 Migration
- If upgrading from v1 database (no frames store), verify upgrade creates frames store without data loss in history store
