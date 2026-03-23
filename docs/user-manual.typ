// FSCMS — User Manual
// Black Sphere Industries

#set document(title: "FSCMS — User Manual", author: "Black Sphere Industries")
#set page(paper: "a4", margin: (top: 2.5cm, bottom: 2.5cm, left: 2cm, right: 2cm))
#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.1")

// ── Title page ──
#align(center)[
  #v(4cm)
  #text(size: 28pt, weight: "bold")[FSCMS]
  #v(0.5cm)
  #text(size: 14pt, fill: rgb("#71717a"))[Filament Storage Climate Monitoring System]
  #v(2cm)
  #text(size: 16pt)[User Manual]
  #v(1cm)
  #line(length: 40%, stroke: 0.5pt + rgb("#f59e0b"))
  #v(1cm)
  #text(size: 11pt, fill: rgb("#71717a"))[
    Black Sphere Industries \
    Version 2.0 --- March 2026
  ]
]

#pagebreak()
#outline(title: "Table of Contents", indent: 1.5em)
#pagebreak()

= Introduction

FSCMS (Filament Storage Climate Monitoring System) is a Progressive Web App for real-time monitoring of temperature and humidity inside 3D printer filament storage containers. It connects directly to Xiaomi Mijia LYWSD03MMC Bluetooth Low Energy (BLE) sensors via the Web Bluetooth API, supporting both original Xiaomi firmware and custom ATC/PVVX firmware.

The application provides a comprehensive dashboard with live sensor tiles, historical charting, configurable humidity alerts, an integrated firmware flasher, and full BLE debug tooling --- all running entirely in the browser.

= Getting Started

== System Requirements

- *Browser:* Chrome, Edge, or Opera on desktop (Windows, macOS, Linux) or Android. Web Bluetooth is *not* supported in Firefox or Safari.
- *Bluetooth:* The host device must have a BLE-capable Bluetooth adapter.
- *Sensors:* One or more Xiaomi Mijia LYWSD03MMC sensors, ideally flashed with ATC/PVVX custom firmware for better BLE advertising support.

== First-Time Setup

+ Open the FSCMS application URL in a supported browser
+ Click *Add Sensor* in the header or the connect prompt
+ In the browser's Bluetooth pairing dialog, select your sensor (devices with `ATC_` prefix are auto-detected)
+ The sensor tile appears on the dashboard with live temperature, humidity, and battery readings

== BLE Receive Modes

FSCMS supports two BLE receive modes, toggled via the switch in the header:

/ POLL mode: Connects to the GATT server and polls for data via characteristic notifications. More reliable but holds an active connection.
/ ADV mode: Listens for BLE advertising packets. Lower power but requires custom firmware that broadcasts sensor data in advertisements.

= Features

== Dashboard

The dashboard tab displays a responsive grid of sensor tiles, each showing:
- *Temperature* with 0.1 degree C resolution
- *Humidity* percentage with color-coded status (normal, warning, critical)
- *Battery voltage and percentage* with configurable battery profiles
- *Connection status* indicator (green = connected, red = disconnected)
- *RSSI signal strength* (when available)

Tiles can be sorted alphabetically or by last-updated time using the sort dropdown.

== Historical Charts

The charts tab renders 24-hour rolling time-series charts for each sensor using Chart.js with date-fns adapters. Data is stored in IndexedDB for persistence across browser sessions.

Each chart shows temperature and humidity traces with proper time-axis formatting.

== Alert System

FSCMS includes a configurable alerting system:
- *Humidity thresholds:* Warning level (default 60%) and Critical level (default 80%), configurable in Settings
- *Battery monitoring:* Alerts at low (20%) and critical (10%) battery levels
- *Push notifications:* Uses the Notifications API for browser-level alerts
- *Alert history:* View past alerts via the bell icon in the header, with a badge showing unread count

An alert banner appears at the top of the page when any sensor enters a warning or critical state.

== Firmware Flasher

FSCMS includes a full-featured BLE firmware flasher for LYWSD03MMC sensors, available in two modes:

=== Simple Mode
One-click OTA (Over-The-Air) firmware update:
+ Select the target device from connected sensors
+ Drop or browse for a `.bin` firmware file
+ Review firmware file information
+ Click *Flash Firmware* to begin the Telink OTA process
+ A progress bar shows upload status

=== Advanced Mode
Full Telink Mi Flasher functionality with:
- *Device Connection:* Connect to any BLE device with name prefix filtering
- *Sensor Configuration:* Read/write advertising type (ATC1441, PVVX Custom, Mi-Like, BTHome v1/v2), advertising interval, measurement interval, TX power, temperature/humidity offsets
- *Options:* Show on LCD, BT5.0 Long Range, Low Power Measure, Temperature in Fahrenheit
- *Comfort Parameters:* Set temperature and humidity comfort ranges
- *Trigger Configuration:* Temperature and humidity thresholds with hysteresis, reed switch mode
- *Mi Authorization:* Manage Xiaomi bind keys, tokens, and device activation
- *Device Management:* Set device name, MAC address, and pin code
- *OTA Firmware Update:* Load firmware from local file or directly from GitHub releases
- *Flasher Log:* Real-time log output of all BLE operations

== Multi-Sensor Support

- Connect multiple sensors simultaneously
- *Batch Reconnect:* Reconnect all previously saved devices with one click
- *Persistent memory:* Device pairings are saved to localStorage and auto-reconnect on page load
- *Friendly names:* Assign custom names to sensors in Settings

== BLE Debug Panel

Accessible via the *Debug* button in the header, the debug panel provides:
- Full BLE event logging with timestamps
- Latency tracking for notification round-trips
- Notification rate monitoring
- Connection diagnostics
- Exportable debug logs

== Data Management

In the Settings tab:
- Configure history retention period (1--90 days)
- Export raw BLE frames to CSV
- Export historical data to CSV
- Clear all stored data

= User Interface

== Header
The sticky header contains:
- Traffic-light dots (BSI branding)
- App title with version number
- Connection status indicator dot
- BLE mode toggle (POLL/ADV)
- Alert history button with unread badge
- Reconnect All button
- Debug panel button
- Add Sensor button

== Tabs
Five main tabs organize the application:
+ *Dashboard* --- Live sensor tile grid with sort and battery profile controls
+ *Charts* --- Historical time-series visualizations per sensor
+ *Flasher* --- Firmware update tools (Simple and Advanced modes)
+ *Settings* --- Humidity thresholds, sensor names, data management
+ *About* --- Application overview, features summary, and tech stack

= Workflows

== Monitoring Workflow

+ Add one or more sensors via the Dashboard
+ Monitor live temperature and humidity on sensor tiles
+ If humidity exceeds the configured threshold, alerts are triggered
+ Switch to the Charts tab to inspect historical trends
+ Export data to CSV for external analysis

== Firmware Update Workflow

+ Navigate to the Flasher tab
+ In Simple mode: select the target device and firmware file, then flash
+ In Advanced mode: connect to a device, configure settings as needed, load firmware from file or GitHub, and flash
+ Monitor progress via the progress bar and flasher log

== Configuring Alert Thresholds

+ Go to the Settings tab
+ Set the Warning level (default 60%) and Critical level (default 80%)
+ Alerts are triggered immediately when any connected sensor exceeds these thresholds

= Architecture

This section presents the software architecture of FSCMS using UML diagrams.

== Architecture Overview

#figure(
  image("uml-architecture.svg", width: 100%),
  caption: [Component architecture of the FSCMS application.]
)

== Class Diagram

#figure(
  image("uml-class-diagram.svg", width: 100%),
  caption: [Class diagram showing the main data structures and modules.]
)

== Main Sequence

#figure(
  image("uml-seq-main.svg", width: 100%),
  caption: [Sequence diagram for sensor connection and data polling.]
)

== Secondary Sequences

#figure(
  image("uml-seq-secondary.svg", width: 100%),
  caption: [Sequence diagrams for flasher, alerts, and configuration operations.]
)

== State Diagram

#figure(
  image("uml-states.svg", width: 100%),
  caption: [State machine diagram showing sensor connection states.]
)

= Configuration

== Browser Permissions
FSCMS requires the following browser permissions:
- *Bluetooth:* Required for sensor communication
- *Notifications:* Optional, for push alert delivery
- *Clipboard:* Optional, for copying debug logs

== Data Storage
- *IndexedDB:* Stores historical sensor readings (temperature, humidity, battery)
- *localStorage:* Stores device pairings, sensor names, alert thresholds, battery profiles, and settings

== PWA Installation
Install FSCMS as a PWA for a standalone app experience. The service worker caches all assets for offline access (though BLE connectivity still requires the browser's Bluetooth stack).

= Troubleshooting

== Common Issues

/ Sensor not found in pairing dialog: Ensure the sensor is powered on and within BLE range (~10 m). If using ATC firmware, verify the device broadcasts with the expected name prefix (default `ATC_`).
/ "Web Bluetooth not supported" warning: Switch to Chrome, Edge, or Opera. Firefox and Safari do not support the Web Bluetooth API.
/ Data not persisting: Check that your browser allows IndexedDB and localStorage. Private/incognito mode may restrict storage.
/ Firmware flash fails: Ensure the sensor stays within BLE range during the entire OTA process. Do not navigate away from the page during flashing.
/ High humidity alert triggered incorrectly: Verify the sensor placement --- ensure the sensor is inside the filament storage container, not outside where ambient humidity may differ.
/ Battery percentage shows "N/A": Battery reporting depends on the firmware. Original Xiaomi firmware may not expose battery data via BLE advertising.
