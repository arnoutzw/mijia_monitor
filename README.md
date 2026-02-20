# FSCMS — Filament Storage Climate Monitoring System

A Progressive Web App (PWA) for monitoring temperature and humidity in 3D printer filament storage using Xiaomi Mijia LYWSD03MMC sensors (SHT4x inside) with [ATC custom firmware](https://github.com/pvvx/ATC_MiThermometer).

**Live:** [arnoutzw.github.io/mijia_monitor](https://arnoutzw.github.io/mijia_monitor/)

## How It Works

```
[Mijia LYWSD03MMC + SHT4x sensor]
        │ BLE (Poll or Advertisement)
        ▼
[Web Bluetooth API in Chrome]
        │
        ▼
[FSCMS PWA Dashboard]
        │
        ▼
[IndexedDB: history + raw frames]
        │
        ▼
[CSV Export]
```

The app connects directly to your sensors over Bluetooth Low Energy (BLE) using the Web Bluetooth API — no gateway, server, or MQTT broker needed. Just open the page, pair your sensors, and you're monitoring.

Two BLE modes are supported: **Poll** (active GATT connection with notification subscriptions) and **Advertisement** (passive scanning via `watchAdvertisements()`, lower power). Advertisement mode requires enabling `chrome://flags/#enable-web-bluetooth-new-permissions-backend`.

## Features

- **Direct BLE connection** to LYWSD03MMC sensors running ATC custom or Mi firmware
- **Dual BLE modes** — Poll (connected notifications) and Advertisement (passive scan, lower battery drain)
- **Auto-detection** of ATC_ devices with manual, single, and batch reconnect
- **Real-time dashboard** with temperature (0.1°C) and humidity (1% RH) per sensor — aligned with SHT4x accuracy
- **24-hour rolling charts** via Chart.js with dual-axis (temp + humidity)
- **Per-device settings** — individual humidity/temperature thresholds and battery profile per sensor, with global fallback
- **Temperature and humidity alerts** with configurable warning/critical thresholds, browser notifications, and alert history
- **Battery profiles** — Realtime, Balanced, Battery Saver, Ultra Saver — writes firmware config (measure_interval, advertising_interval, tx_power) via cmd 0x55
- **Auto-apply battery profile** on sensor connect
- **Frame logging** — every received BLE frame stored in IndexedDB with raw hex, interpreted values, and timestamp
- **CSV export** — export raw frames or throttled history for analysis
- **Tile sorting** — sort sensor cards alphabetically or by last updated
- **Per-device disconnect** — disconnect individual sensors from the dashboard
- **OTA firmware flashing** — update sensor firmware directly from the browser (Telink TLSR825x), simple and advanced modes
- **Friendly sensor names** — assign custom labels, stored in localStorage
- **Forget device** — full wipe including IndexedDB history and frames
- **BLE performance debug panel** — timing for every GATT operation, notification rates, color-coded console output, exportable logs
- **BLE capability check** — startup warning if Chrome flags are missing
- **IndexedDB persistence** — historical data and frames survive page reloads (auto-cleanup based on retention setting)
- **PWA installable** — works offline, add to home screen on mobile or desktop
- **Dark theme** — zinc/amber terminal aesthetic, easy on the eyes for always-on displays

## Requirements

- Chrome or Edge with Web Bluetooth support (not Firefox or Safari)
- Recommended: enable `chrome://flags/#enable-web-bluetooth-new-permissions-backend` for batch reconnect and advertisement mode
- One or more Xiaomi Mijia LYWSD03MMC sensors, ideally flashed with [ATC custom firmware](https://github.com/pvvx/ATC_MiThermometer)
- Bluetooth enabled on your device

## Getting Started

1. Open [arnoutzw.github.io/mijia_monitor](https://arnoutzw.github.io/mijia_monitor/) in Chrome
2. Click **Add Sensor** → **Auto Pair Nearby** (scans for all `ATC_` devices) or **Pick Single ATC Sensor**
3. Accept the browser Bluetooth pairing prompt
4. Sensor card appears with live temperature, humidity, and battery data
5. Optionally set a friendly name by double-clicking the sensor name
6. Configure per-device thresholds via the gear icon on each tile
7. Choose a battery profile from the Dashboard dropdown to optimize battery life
8. Export data anytime from Settings → Data Management

## Battery Profiles

| Profile | Measure Interval | Adv Interval | TX Power | Storage Rate |
|---------|-----------------|-------------|----------|-------------|
| Realtime | 4s | 2.5s | +7 dBm | 10s |
| Balanced | 30s | 5s | +5 dBm | 30s |
| Battery Saver | 120s | 10s | +3 dBm | 120s |
| Ultra Saver | 255s | 20s | 0 dBm | 300s |

Profiles are written to sensor firmware via cmd 0x55 and automatically applied when a sensor connects.

## Self-Hosting

No build step required — it's a single HTML file with CDN dependencies.

```bash
git clone https://github.com/arnoutzw/mijia_monitor.git
cd mijia_monitor
# Serve with any static file server, e.g.:
python3 -m http.server 8080
```

Open `http://localhost:8080` in Chrome. The service worker requires HTTPS for PWA install (GitHub Pages handles this automatically).

## Project Structure

```
index.html      — Full SPA (HTML + CSS + JS, single file)
manifest.json   — PWA manifest (standalone, installable)
sw.js           — Service worker (cache-first offline)
TESTS.md        — Manual test plan (24 sections)
icons/
  icon-192.svg  — App icon 192×192
  icon-512.svg  — App icon 512×512
.nojekyll       — Bypass Jekyll on GitHub Pages
```

## Tech Stack

- Vanilla JS (no framework, no build tools)
- [Tailwind CSS](https://tailwindcss.com/) via CDN
- [Chart.js](https://www.chartjs.org/) for historical charts
- [Lucide Icons](https://lucide.dev/) for UI icons
- IndexedDB for data persistence (v2: history + frames stores)
- Web Bluetooth API for direct sensor communication
- Web Bluetooth `watchAdvertisements()` for passive BLE scanning

## License

MIT
