# GDN Indoor Navigation

A Flutter mobile application for real-time indoor positioning and navigation inside the GDN building at VIT. The device scans nearby WiFi access points, sends RSSI readings to a local ML server, and plots the predicted position on an interactive floor plan.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

---

## How It Works

```
Phone scans WiFi (every 1s)
        ↓
RSSI readings (BSSID + signal strength)
        ↓
POST to local ML server  →  ML model predicts (x, y)
        ↓
Coordinate transform  →  floor plan pixel position
        ↓
Blue dot plotted on GDN map
```

---

## Features

- **On-device WiFi scanning** — reads RSSI from all visible access points every second via a native Android `MethodChannel`, no external hardware required
- **ML-based positioning** — sends readings to a local Python server running a trained model, receives `(x, y)` coordinates back
- **Live position dot** — pulsing blue marker on the floor plan that updates in real time
- **Dijkstra pathfinding** — select a destination room and get the shortest path drawn on the map
- **Arrival detection** — dialog shown when you reach your destination
- **Demo mode** — cycles through known room positions for testing without a server

---

## Architecture

```
lib/
├── main.dart                          # App entry, Provider setup
├── screens/
│   └── indoor_navigation_screen.dart  # Main UI — map + destination picker + status bar
├── services/
│   ├── wifi_positioning_service.dart  # WiFi scan → ML server → mapped position
│   ├── indoor_map_service.dart        # Loads graph JSON, runs Dijkstra
│   └── location_api_service.dart      # Legacy: polls a fixed API endpoint (kept for reference)
├── models/
│   └── indoor_node.dart               # Node data model (id, x, y, type, name)
└── widgets/
    ├── indoor_map_widget.dart         # Floor plan renderer + PathPainter
    └── destination_reached_dialog.dart

android/app/src/main/kotlin/.../
└── MainActivity.kt                    # Native WiFi scanner via WifiManager

assets/maps/
├── gdn_ground_floor.png               # Floor plan image
└── gdn_ground_floor_graph.json        # 185 nodes + 282 edges
```

---

## Coordinate System

IoT/ML coordinates are mapped to floor plan pixels using a linear transform calibrated across 16 GDN rooms (RMSE: 6px X, 2.4px Y):

```
pixelX = x × 10.1549 + 9.3826
pixelY = y × (−10.1914) + 1181.5126
```

---

## Setup

### Prerequisites
- Flutter SDK `>=3.8.0`
- Android device (API 21+) with WiFi
- Local ML server running at a known IP

### Run

```bash
git clone https://github.com/ShriHarsh05/pathfinder.git
cd pathfinder
flutter pub get
flutter run
```

### Configure the ML server URL

Open `lib/services/wifi_positioning_service.dart` and update:

```dart
static const String _serverUrl = 'http://<your-server-ip>:5000/locate';
```

The server should accept:
```json
POST /locate
{ "readings": [{ "bssid": "xx:xx:xx:xx:xx:xx", "ssid": "...", "rssi": -65 }] }
```
And respond with:
```json
{ "x": 57.3, "y": 42.1 }
```

### Demo mode (no server needed)

In `lib/services/wifi_positioning_service.dart`:
```dart
static const bool demoMode = true;
```
The dot will walk through all GDN rooms automatically.

---

## Android Permissions

Declared in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES" />
```

Location permission is requested at runtime on first launch (required by Android 6+ to read WiFi scan results).

---

## Map Annotation

The `map_annotator.py` script was used to build the navigation graph:

```bash
pip install opencv-python networkx
python map_annotator.py
```

It produces `gdn_ground_floor_graph.json` with nodes (rooms + path waypoints) and weighted edges used by Dijkstra.

---

## Branches

| Branch | Description |
|--------|-------------|
| `main` | Original full-featured app (outdoor GPS, AR, Google Maps) |
| `feature/wifi-indoor-positioning` | This branch — stripped to indoor only, on-device WiFi scanning |

---

## Support

For issues or questions: shriharshkotecha.sk@gmail.com
