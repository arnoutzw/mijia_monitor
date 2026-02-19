# FSCMS — Manual Test Cases

Since FSCMS relies on Web Bluetooth and physical BLE sensors, testing is primarily manual. This document lists all test scenarios.

## Prerequisites

- Chrome/Edge browser with Web Bluetooth support
- At least one Mijia LYWSD03MMC sensor (ATC custom firmware preferred)
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
- Click **Reconnect All** in the header
- Verify sequential connection with ~2s delay between each device
- Verify progress alerts ("Connecting 1/3: ATC_C4B249...")
- Click **Cancel** mid-batch → verify remaining devices are skipped

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
- Verify temperature displays rounded to 0.3°C steps (e.g., 21.0, 21.3, 21.6, 21.9)
- Check both dashboard cards and debug log

### 4.2 Humidity Rounding
- Verify humidity displays rounded to nearest 3% steps (e.g., 42, 45, 48, 51)
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
- Set warning threshold to a value below current humidity (Settings)
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

## 7. Battery Alerts

### 7.1 Low Battery Warning
- Use a sensor with battery below 20%
- Verify that after 5 consecutive frames below 20%, a "Low Battery Level Warning" alert fires
- Verify 1-hour cooldown before re-alerting for the same sensor

### 7.2 Critical Battery Warning
- Use a sensor with battery at or below 10%
- Verify immediate "Critical Battery Level Warning, Replace battery as soon as possible!" alert
- Verify push notification fires (if permission granted)
- Verify 1-hour cooldown before re-alerting

### 7.3 Counter Reset
- If battery goes back above 20%, verify the low-battery counter resets to 0

---

## 8. Battery Profiles

### 8.1 Profile Selection
- Open **Settings** → **Battery Profile**
- Verify four profiles displayed: Realtime, Balanced, Battery Saver, Ultra Saver
- Verify active profile is highlighted with amber border
- Select a different profile → verify it highlights and saves

### 8.2 Firmware Write
- Connect a sensor, then select a different battery profile
- Verify cmd 0x55 is written to the sensor (check BLE Performance Log)
- Verify status message shows "Profile applied to 1/1 sensor(s)"
- Verify firmware measure_interval, advertising_interval, and tx_power change

### 8.3 No Sensors Connected
- Disconnect all sensors, change battery profile
- Verify message: "Profile saved locally. Will apply to sensors when connected via Flasher."

### 8.4 Persistence
- Change battery profile, reload page
- Verify saved profile is restored from localStorage

### 8.5 Storage Throttle
- Select "Realtime" profile (10s storage rate) → verify IndexedDB entries every ~10s
- Switch to "Ultra Saver" (300s storage rate) → verify entries slow down
- Verify live dashboard card values still update on every notification regardless of throttle

---

## 9. BLE Mode Toggle

### 9.1 Poll to Advert
- Connect sensors in Poll mode
- Toggle the BLE mode switch in the header to Advert
- Verify `watchAdvertisements()` is started on connected devices (check BLE Performance Log)
- Verify GATT connections are disconnected to save battery
- Verify toggle turns amber and label shows "ADV"

### 9.2 Advert Data Reception
- In Advert mode, verify sensor cards still update with temperature/humidity/battery
- Verify advertisement format is detected (PVVX Custom, ATC1441, BTHome, Mi-Like)

### 9.3 Advert to Poll
- Toggle back to Poll mode
- Verify advertisement watching stops
- Verify toggle returns to zinc/gray state

### 9.4 No Devices Warning
- Without any paired devices, switch to Advert mode
- Verify warning: "No devices available for advertisement watching..."
- Verify mode reverts to Poll automatically

### 9.5 Persistence
- Switch to Advert mode, reload the page
- Verify mode is restored and scan resumes via `getDevices()` + `watchAdvertisements()`

---

## 10. Settings

### 10.1 Friendly Names
- Double-click sensor name on card → enter a custom name
- Verify name persists across page reloads
- Verify reconnect still works after renaming

### 10.2 Threshold Configuration
- Open settings, change warning/critical humidity thresholds
- Verify new thresholds are applied immediately
- Verify settings persist across reloads

### 10.3 Data Retention
- Change history retention days, verify old data is cleaned on next cleanup cycle

---

## 11. Flasher Tab — Simple Mode

### 11.1 File Validation
- Open Flasher tab (default is Simple mode)
- Upload a valid ATC firmware .bin file → verify info panel shows size
- Upload a random non-firmware file → verify rejection with error message
- Upload a file >512KB → verify "File too large" error

### 11.2 Flash Process
- Start OTA with valid firmware on a connected sensor
- Verify progress bar advances
- Verify sensor reconnects after flash completes
- **Caution:** Only test with known-good firmware files

---

## 12. Flasher Tab — Advanced Mode

### 12.1 Mode Toggle
- Click "Advanced" toggle in the Flasher tab
- Verify Advanced panel shows with all sections: Device Connection, Sensor Config, Comfort Params, Triggers, Mi Auth, Device Management, Advanced OTA, Flasher Log

### 12.2 Device Connection
- Click Connect in Advanced mode → verify BLE pairing dialog
- Verify device info populates (name, MAC, hardware/software version)
- Click Disconnect → verify clean disconnect

### 12.3 Sensor Configuration
- Connect via Flasher → verify config auto-loads (adv type, intervals, TX power, offsets)
- Change measure interval → Write Config → verify config is written (check Flasher Log)
- Read config back → verify changes persisted on the device

### 12.4 Mi Authorization
- Click "Get Bind Key" → verify bind key is retrieved and displayed (cmd 0x44 response)
- Verify bind key hex string appears in the input field

### 12.5 Remote Firmware Load
- Click "Load from GitHub" → verify firmware binary loads from remote URL
- Verify file info shows after load

### 12.6 Flasher Log
- Verify all operations produce color-coded log entries (info, success, error)
- Verify log scrolls to latest entry automatically

---

## 13. About Tab

### 13.1 Content
- Open About tab → verify project overview, features list, tech stack grid, compatible devices, and credits are shown
- Verify build hash is displayed

---

## 14. Alert History Bell

### 14.1 Bell Badge
- Trigger any alert → verify bell icon in header shows a count badge
- Trigger more alerts → verify badge count increments

### 14.2 Alert Panel
- Click bell → verify alert history panel opens with timestamped entries
- Verify color coding (yellow for warning, red for critical)

---

## 15. Debug Panel

### 15.1 Panel Access
- Click the **Debug** button in the header
- Verify modal opens with connection stats, notification rates, and event log

### 15.2 Performance Metrics
- Connect a sensor, trigger some reads
- Verify timing entries appear with color coding (green <100ms, yellow, amber, red >2s)
- Verify notification rate stats (avg/min/max/count) per sensor

### 15.3 Export
- Click export in debug panel → verify log data can be copied/saved

### 15.4 Clear
- Click clear → verify all perf stats and log entries are wiped

---

## 16. PWA

### 16.1 Install Prompt
- Open in Chrome on desktop or Android
- Verify install prompt appears (or install option in browser menu)
- Install → verify app opens in standalone window

### 16.2 Offline Mode
- Install the PWA, then go offline (airplane mode / disable WiFi)
- Open the app → verify it loads from service worker cache
- Verify previously connected sensor data is still visible from IndexedDB

### 16.3 Responsive Layout
- Test at phone width (~375px) → verify single-column card layout
- Test at tablet width (~768px) → verify cards adjust
- Test at desktop width (~1200px) → verify multi-column grid

---

## 17. Edge Cases

### 17.1 No Bluetooth
- Open in a browser without Web Bluetooth (Firefox, Safari)
- Verify graceful error message, no JS crashes

### 17.2 Sensor Out of Range
- Connect sensor, then move it out of BLE range
- Verify disconnect is detected and card updates to show Reconnect button

### 17.3 Multiple Sensors
- Connect 3 sensors simultaneously
- Verify all cards render, charts work independently, no cross-sensor data contamination

### 17.4 Rapid Connect/Disconnect
- Connect and disconnect the same sensor several times quickly
- Verify no duplicate cards or ghost entries

### 17.5 Notification Throttling
- In Realtime profile, verify live card updates on every firmware push (~4s)
- In Ultra Saver profile, verify card still updates live but IndexedDB stores only every ~5 min
