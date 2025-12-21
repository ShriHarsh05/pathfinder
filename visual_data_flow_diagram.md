# Pathfinder Indoor Navigation - Visual Data Flow Diagram

## ASCII Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           PATHFINDER INDOOR NAVIGATION SYSTEM                       │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                INPUT SOURCES                                        │
├─────────────────┬─────────────────┬─────────────────┬─────────────────┬─────────────┤
│   GPS Signals   │  Device Camera  │ Compass Sensor  │ 2D Floor Plan   │ User Input  │
│   (Satellites)  │   (AR Mode)     │ (Orientation)   │   (Building)    │(Destination)│
└─────────┬───────┴─────────┬───────┴─────────┬───────┴─────────┬───────┴─────────┬───┘
          │                 │                 │                 │                 │
          ▼                 ▼                 ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              PROCESSING LAYER                                      │
├─────────────────┬─────────────────┬─────────────────┬─────────────────┬─────────────┤
│  Geolocator     │  Camera Service │ Flutter Compass │ map_annotator.py│ SearchField │
│   Service       │   (AR Feed)     │   (Direction)   │  + OpenCV +     │ (Autocomplete)│
│ (GPS Tracking)  │                 │                 │   NetworkX      │             │
└─────────┬───────┴─────────┬───────┴─────────┬───────┴─────────┬───────┴─────────┬───┘
          │                 │                 │                 │                 │
          ▼                 ▼                 ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                               CORE SERVICES                                        │
├─────────────────┬─────────────────┬─────────────────┬─────────────────┬─────────────┤
│ Location Service│ Indoor Map      │    AR Service   │  Google Maps    │Mode Transition│
│                 │    Service      │                 │     API         │  Controller  │
│ • Real-time GPS │ • Load JSON     │ • Camera overlay│ • Route calc    │ • Geofence   │
│ • Proximity     │ • 185 nodes     │ • Direction     │ • Map tiles     │ • 25m radius │
│   detection     │ • 282 edges     │   arrows        │ • Polylines     │ • Auto switch│
└─────────┬───────┴─────────┬───────┴─────────┬───────┴─────────┬───────┴─────────┬───┘
          │                 │                 │                 │                 │
          ▼                 ▼                 ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                            NAVIGATION MODULES                                      │
├─────────────────┬─────────────────┬─────────────────┬─────────────────┬─────────────┤
│ Outdoor Module  │  Indoor Module  │ Pathfinding     │ AR Visualization│ Data Models │
│                 │                 │                 │                 │             │
│ • GPS guidance  │ • Graph-based   │ • Dijkstra      │ • Live camera   │ • Destination│
│ • Google Maps   │   navigation    │   algorithm     │ • Direction     │ • IndoorNode │
│ • Route display │ • Room finding  │ • 0.239ms avg   │   overlays      │ • Path data │
└─────────┬───────┴─────────┬───────┴─────────┬───────┴─────────┬───────┴─────────┬───┘
          │                 │                 │                 │                 │
          ▼                 ▼                 ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              USER INTERFACE                                        │
├─────────────────┬─────────────────┬─────────────────┬─────────────────┬─────────────┤
│   Home Screen   │   Map Widget    │Indoor Map Widget│  AR Navigation  │   Dialogs   │
│                 │                 │                 │      View       │             │
│ • Destination   │ • Google Maps   │ • 2D floor plan │ • Camera feed   │ • Arrival   │
│   selection     │ • GPS tracking  │ • Path overlay  │ • AR arrows     │ • Reached   │
│ • Mode toggle   │ • Route display │ • Node markers  │ • Compass align │ • Navigation│
└─────────────────┴─────────────────┴─────────────────┴─────────────────┴─────────────┘
```

## System Flow Process

```
USER JOURNEY FLOW:
═══════════════════

1. APP STARTUP
   ┌─────────────────┐
   │ User opens app  │
   └─────────┬───────┘
             ▼
   ┌─────────────────┐    ┌──────────────────┐
   │ Load JSON graph │───▶│ 185 nodes loaded │
   │ (55.9 KB file)  │    │ 282 edges ready  │
   └─────────────────┘    └──────────────────┘

2. DESTINATION SELECTION
   ┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
   │ User types      │───▶│ SearchField      │───▶│ Destination     │
   │ destination     │    │ autocomplete     │    │ selected        │
   └─────────────────┘    └──────────────────┘    └─────────────────┘

3. OUTDOOR NAVIGATION
   ┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
   │ GPS tracking    │───▶│ Google Maps      │───▶│ Route to        │
   │ current location│    │ route calculation│    │ building        │
   └─────────────────┘    └──────────────────┘    └─────────────────┘

4. MODE TRANSITION (AUTOMATIC)
   ┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
   │ Distance < 25m  │───▶│ Geofence         │───▶│ Switch to       │
   │ from building   │    │ detection        │    │ indoor mode     │
   └─────────────────┘    └──────────────────┘    └─────────────────┘

5. INDOOR NAVIGATION
   ┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
   │ Find room node  │───▶│ Dijkstra         │───▶│ Optimal path    │
   │ in graph        │    │ pathfinding      │    │ calculated      │
   └─────────────────┘    └──────────────────┘    └─────────────────┘

6. VISUALIZATION (User Choice)
   ┌─────────────────┐              ┌─────────────────┐
   │ 2D Map Mode     │              │ AR Camera Mode  │
   │ • Floor plan    │     OR       │ • Live camera   │
   │ • Path overlay  │              │ • Direction     │
   │ • Node markers  │              │   arrows        │
   └─────────────────┘              └─────────────────┘
```

## Key Data Structures

```
JSON GRAPH STRUCTURE:
════════════════════

{
  "nodes": [
    {
      "id": 7,           ← Unique identifier
      "x": 594,          ← Pixel coordinate
      "y": 1047,         ← Pixel coordinate  
      "type": "room",    ← "room" or "path"
      "name": "G01"      ← Room name or null
    }
  ],
  "edges": [
    {
      "source": 6,       ← Start node ID
      "target": 7,       ← End node ID
      "weight": 17.26    ← Distance in pixels
    }
  ]
}

PERFORMANCE METRICS:
═══════════════════

Component               | Data Size | Processing Time
─────────────────────────────────────────────────────
JSON Graph Loading      | 55.9 KB   | 0.004 seconds
Dijkstra Pathfinding    | 185 nodes | 0.239 ms average
Memory Footprint        | ~310 KB   | Constant usage
AR Rendering Latency    | -         | 0.15-0.4 seconds
Mode Transition         | -         | Real-time (25m)
```

## How to View the Mermaid Diagrams

To see the interactive Mermaid diagrams from the previous file, you have several options:

### Option 1: Online Mermaid Editor
1. Go to https://mermaid.live/
2. Copy the mermaid code from `data_flow_diagram.md`
3. Paste it in the editor to see the visual diagram

### Option 2: VS Code Extension
1. Install "Mermaid Preview" extension in VS Code
2. Open `data_flow_diagram.md`
3. Right-click → "Open Preview to the Side"

### Option 3: GitHub/GitLab
1. Push the file to GitHub/GitLab
2. View the file online (they render Mermaid automatically)

### Option 4: Export as Image
1. Use the online editor to export as PNG/SVG
2. Include the image in your patent application

The ASCII diagram above shows the same information in a text format that you can view immediately!