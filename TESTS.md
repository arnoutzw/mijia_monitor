# FilaMon — Manual Test Cases

Since FilaMon relies on Web Bluetooth and physical BLE sensors, testing is primarily manual. This document lists all test scenarios.

## Prerequisites

- Chrome/Edge browser with Web Bluetooth support
- At least one Mijia LYWSD03MMC sensor (ATC firmware preferred)
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
- Verify sensor is removed from localStorage (knownDevices, settings.names, settings.pollRates)
- Verify IndexedDB history for that sensor is deleted
- Verify debug panel no longer shows perf stats for that sensor

---

## 4. Data Display

### 4.1 Temperature Rounding
- Verify temperature displays rounded to 0.1°C (e.g., 23.4°, not 23.42°)
- Check both dashboard cards and debug log

### 4.2 Humidity Rounding
- Verify humidity displays rounded to nearest 0.5% (e.g., 45.0%, 45.5%, 46.0%)
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
- Verify data older than 7 days is automatically cleaned up

---

## 6. Alerts

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

## 7. Polling Rates

### 7.1 Rate Selection
- On a connected sensor card, find the polling rate dropdown (timer icon)
- Change rate from default to 30s
- Verify readings slow down accordingly (check debug panel timing)

### 7.2 Per-Sensor Independence
- Set Sensor A to 5s and Sensor B to 5m
- Verify A gets frequent updates while B updates slowly

### 7.3 Persistence
- Change polling rate, reload page, reconnect
- Verify the saved rate is restored from localStorage

---

## 8. Settings

### 8.1 Friendly Names
- Click sensor name on card → enter a custom name
- Verify name persists across page reloads
- Verify reconnect still works after renaming

### 8.2 Threshold Configuration
- Open settings, change warning/critical humidity thresholds
- Verify new thresholds are applied immediately
- Verify settings persist across reloads

---

## 9. OTA Firmware Flash

### 9.1 File Validation
- Click the flash icon on a connected sensor card
- Upload a valid ATC firmware .bin file → verify info panel shows size, format
- Upload a random non-firmware file → verify rejection with error message
- Upload a file >512KB → verify "File too large" error

### 9.2 Flash Process
- Start OTA with valid firmware
- Verify progress bar advances
- Verify sensor reconnects after flash completes
- **Caution:** Only test with known-good firmware files

---

## 10. Debug Panel

### 10.1 Panel Access
- Click the **Debug** button in the header
- Verify modal opens with connection stats, notification rates, and event log

### 10.2 Performance Metrics
- Connect a sensor, trigger some reads
- Verify timing entries appear with color coding (green <100ms, yellow, amber, red >2s)
- Verify notification rate stats (avg/min/max/count) per sensor

### 10.3 Export
- Click export in debug panel → verify log data can be copied/saved

### 10.4 Clear
- Click clear → verify all perf stats and log entries are wiped

---

## 11. PWA

### 11.1 Install Prompt
- Open in Chrome on desktop or Android
- Verify install prompt appears (or install option in browser menu)
- Install → verify app opens in standalone window

### 11.2 Offline Mode
- Install the PWA, then go offline (airplane mode / disable WiFi)
- Open the app → verify it loads from service worker cache
- Verify previously connected sensor data is still visible from IndexedDB

### 11.3 Responsive Layout
- Test at phone width (~375px) → verify single-column card layout
- Test at tablet width (~768px) → verify cards adjust
- Test at desktop width (~1200px) → verify multi-column grid

---

## 12. Edge Cases

### 12.1 No Bluetooth
- Open in a browser without Web Bluetooth (Firefox, Safari)
- Verify graceful error message, no JS crashes

### 12.2 Sensor Out of Range
- Connect sensor, then move it out of BLE range
- Verify disconnect is detected and card updates to show Reconnect button

### 12.3 Multiple Sensors
- Connect 3 sensors simultaneously
- Verify all cards render, charts work independently, no cross-sensor data contamination

### 12.4 Rapid Connect/Disconnect
- Connect and disconnect the same sensor several times quickly
- Verify no duplicate cards or ghost entries
