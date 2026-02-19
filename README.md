# FilaMon — Filament Storage Monitor

A Progressive Web App (PWA) for monitoring temperature and humidity in 3D printer filament storage using Xiaomi Mijia LYWSD03MMC sensors with [ATC custom firmware](https://github.com/pvvx/ATC_MiThermometer).

**Live demo:** [arnoutzw.github.io/mijia_monitor](https://arnoutzw.github.io/mijia_monitor/)

## How It Works

```
[Mijia LYWSD03MMC sensors]
        │ BLE
        ▼
[Web Bluetooth API in browser]
        │
        ▼
[FilaMon PWA Dashboard]
```

The app connects directly to your sensors over Bluetooth Low Energy (BLE) using the Web Bluetooth API — no gateway, server, or MQTT broker needed. Just open the page, pair your sensors, and you're monitoring.

## Features

- **Direct BLE connection** to LYWSD03MMC sensors running ATC or original Mi firmware
- **Auto-detection** of ATC_ devices with manual and batch reconnect
- **Real-time dashboard** with temperature (°C) and humidity (%) per sensor
- **24-hour rolling charts** via Chart.js with dual-axis (temp + humidity)
- **Humidity alerts** with configurable warning/critical thresholds and browser notifications
- **Per-sensor polling rates** — choose from 5s, 30s, 1m, 5m, or 30m per sensor
- **OTA firmware flashing** — update sensor firmware directly from the browser (Telink TLSR825x)
- **Friendly sensor names** — assign custom labels, stored in localStorage
- **Forget device** — full wipe including IndexedDB history
- **BLE performance debug panel** — timing for every GATT operation, notification rates, color-coded console output
- **IndexedDB persistence** — historical data survives page reloads (auto-cleanup after 7 days)
- **PWA installable** — works offline, add to home screen on mobile or desktop
- **Dark theme** — zinc/amber terminal aesthetic, easy on the eyes for always-on displays

## Requirements

- A browser with Web Bluetooth support (Chrome, Edge, Opera — not Firefox or Safari)
- One or more Xiaomi Mijia LYWSD03MMC sensors, ideally flashed with [ATC custom firmware](https://github.com/pvvx/ATC_MiThermometer)
- Bluetooth enabled on your device

## Getting Started

1. Open [arnoutzw.github.io/mijia_monitor](https://arnoutzw.github.io/mijia_monitor/) in Chrome
2. Click **Add Sensor** → **Auto Pair Nearby** (scans for all `ATC_` devices) or **Pick Single ATC Sensor**
3. Accept the browser Bluetooth pairing prompt
4. Sensor card appears with live temperature, humidity, and battery data
5. Optionally set a friendly name by clicking the sensor name

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
icons/
  icon-192.svg  — App icon 192×192
  icon-512.svg  — App icon 512×512
```

## Tech Stack

- Vanilla JS (no framework, no build tools)
- [Tailwind CSS](https://tailwindcss.com/) via CDN
- [Chart.js](https://www.chartjs.org/) for historical charts
- [Lucide Icons](https://lucide.dev/) for UI icons
- IndexedDB for data persistence
- Web Bluetooth API for direct sensor communication

## License

MIT
