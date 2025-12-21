# Patent-Style Technical Diagrams for Pathfinder Indoor Navigation

## Figure 1: System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    PATHFINDER NAVIGATION SYSTEM                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │    GPS      │    │   Google    │    │   Camera    │         │
│  │ Satellites  │    │    Maps     │    │   Sensor    │         │
│  │             │    │     API     │    │             │         │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘         │
│         │                  │                  │                │
│         ▼                  ▼                  ▼                │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              MOBILE DEVICE PROCESSOR                    │   │
│  │                                                         │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │   │
│  │  │  Outdoor    │  │ Transition  │  │   Indoor    │     │   │
│  │  │ Navigation  │  │ Controller  │  │ Navigation  │     │   │
│  │  │   Module    │  │             │  │   Module    │     │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │   │
│  │                                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                │                                │
│                                ▼                                │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                USER INTERFACE                           │   │
│  │                                                         │   │
│  │  ┌─────────────┐              ┌─────────────┐           │   │
│  │  │  2D Map     │              │ AR Camera   │           │   │
│  │  │   View      │              │    View     │           │   │
│  │  │ (Outdoor &  │              │ (Outdoor    │           │   │
│  │  │  Indoor)    │              │   Only)     │           │   │
│  │  └─────────────┘              └─────────────┘           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Figure 2: Outdoor Navigation with AR Mode

```
┌─────────────────────────────────────────────────────────────────┐
│                    OUTDOOR AR NAVIGATION                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │    GPS      │    │   Compass   │    │   Camera    │         │
│  │   Signal    │    │   Sensor    │    │    Feed     │         │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘         │
│         │                  │                  │                │
│         ▼                  ▼                  ▼                │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              AR PROCESSING MODULE                       │   │
│  │                                                         │   │
│  │  Current Location: (lat, lng)                          │   │
│  │  Destination: Building Entrance                        │   │
│  │  Bearing Calculation: θ = atan2(Δlng, Δlat)           │   │
│  │  Direction: θ - compass_heading                        │   │
│  │                                                         │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                       │
│                        ▼                                       │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                CAMERA OVERLAY                           │   │
│  │                                                         │   │
│  │  ┌─────────────────────────────────────────────────┐   │   │
│  │  │              Live Camera Feed                   │   │   │
│  │  │                                                 │   │   │
│  │  │    ↑ STRAIGHT AHEAD                            │   │   │
│  │  │                                                 │   │   │
│  │  │    Distance: 150m                              │   │   │
│  │  │    Destination: GDN Building                   │   │   │
│  │  └─────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Figure 3: Indoor Graph Generation Process

```
┌─────────────────────────────────────────────────────────────────┐
│                INDOOR MAP PROCESSING PIPELINE                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐                                           │
│  │   2D Floor      │                                           │
│  │   Plan Image    │                                           │
│  │                 │                                           │
│  └─────────┬───────┘                                           │
│            │                                                   │
│            ▼                                                   │
│  ┌─────────────────┐      ┌─────────────────┐                 │
│  │ map_annotator.py│ ───► │     OpenCV      │                 │
│  │  Python Script │      │ Contour Extract │                 │
│  └─────────────────┘      └─────────┬───────┘                 │
│                                     │                         │
│                                     ▼                         │
│  ┌─────────────────┐      ┌─────────────────┐                 │
│  │    NetworkX     │ ◄─── │  Node Placement │                 │
│  │ Graph Generator │      │  Edge Creation  │                 │
│  └─────────┬───────┘      └─────────────────┘                 │
│            │                                                   │
│            ▼                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              JSON GRAPH OUTPUT                          │   │
│  │                                                         │   │
│  │  {                                                      │   │
│  │    "nodes": [                                           │   │
│  │      {"id": 7, "x": 594, "y": 1047,                   │   │
│  │       "type": "room", "name": "G01"}                   │   │
│  │    ],                                                   │   │
│  │    "edges": [                                           │   │
│  │      {"source": 6, "target": 7, "weight": 17.26}     │   │
│  │    ]                                                    │   │
│  │  }                                                      │   │
│  │                                                         │   │
│  │  Size: 55.9 KB                                         │   │
│  │  Nodes: 185                                             │   │
│  │  Edges: 282                                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Figure 4: Mode Transition Controller

```
┌─────────────────────────────────────────────────────────────────┐
│                  AUTOMATIC MODE TRANSITION                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐                                           │
│  │  GPS Tracking   │                                           │
│  │                 │                                           │
│  │  Current: (lat₁, lng₁)                                     │
│  │  Building: (lat₂, lng₂)                                    │
│  │                 │                                           │
│  └─────────┬───────┘                                           │
│            │                                                   │
│            ▼                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │            DISTANCE CALCULATION                         │   │
│  │                                                         │   │
│  │  d = √[(lat₂-lat₁)² + (lng₂-lng₁)²] × 111,320m        │   │
│  │                                                         │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                       │
│                        ▼                                       │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              DECISION LOGIC                             │   │
│  │                                                         │   │
│  │              d > 25m ?                                  │   │
│  │                 │                                       │   │
│  │        ┌────────┴────────┐                             │   │
│  │        │                 │                             │   │
│  │       YES               NO                             │   │
│  │        │                 │                             │   │
│  │        ▼                 ▼                             │   │
│  │  ┌─────────────┐  ┌─────────────┐                     │   │
│  │  │   Outdoor   │  │   Indoor    │                     │   │
│  │  │ Navigation  │  │ Navigation  │                     │   │
│  │  │   Active    │  │   Active    │                     │   │
│  │  └─────────────┘  └─────────────┘                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Figure 5: Indoor Pathfinding Algorithm

```
┌─────────────────────────────────────────────────────────────────┐
│                    DIJKSTRA PATHFINDING                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐      ┌─────────────────┐                  │
│  │   Start Node    │      │    End Node     │                  │
│  │   (Entrance)    │      │     (G01)       │                  │
│  │     ID: 0       │      │     ID: 7       │                  │
│  └─────────┬───────┘      └─────────┬───────┘                  │
│            │                        │                          │
│            └────────┬───────────────┘                          │
│                     │                                          │
│                     ▼                                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              GRAPH PROCESSING                           │   │
│  │                                                         │   │
│  │  Priority Queue: [(distance, node_id)]                 │   │
│  │  Visited Set: {processed_nodes}                        │   │
│  │  Distances: {node_id: min_distance}                    │   │
│  │  Previous: {node_id: previous_node}                    │   │
│  │                                                         │   │
│  │  Algorithm Complexity: O(E + V log V)                  │   │
│  │  Average Execution: 0.239ms                            │   │
│  │                                                         │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                       │
│                        ▼                                       │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                PATH RESULT                              │   │
│  │                                                         │   │
│  │  Optimal Path: [0 → 1 → 2 → 3 → 6 → 7]               │   │
│  │  Total Distance: 89.5 pixels                           │   │
│  │  Path Nodes: 6                                         │   │
│  │  Optimality Ratio: 1.31                               │   │
│  │                                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Figure 6: User Interface Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      USER INTERACTION FLOW                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐                                           │
│  │   App Launch    │                                           │
│  │                 │                                           │
│  └─────────┬───────┘                                           │
│            │                                                   │
│            ▼                                                   │
│  ┌─────────────────┐                                           │
│  │ Load Indoor     │                                           │
│  │ Graph (55.9 KB) │                                           │
│  └─────────┬───────┘                                           │
│            │                                                   │
│            ▼                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              DESTINATION SELECTION                      │   │
│  │                                                         │   │
│  │  ┌─────────────────────────────────────────────────┐   │   │
│  │  │            Search Field                         │   │   │
│  │  │  ┌─────────────────────────────────────────┐   │   │   │
│  │  │  │ Enter destination: "G01"                │   │   │   │
│  │  │  └─────────────────────────────────────────┘   │   │   │
│  │  │                                                 │   │   │
│  │  │  Autocomplete Results:                          │   │   │
│  │  │  • G01 (Room)                                   │   │   │
│  │  │  • G02 (Room)                                   │   │   │
│  │  │  • G03 (Room)                                   │   │   │
│  │  └─────────────────────────────────────────────────┘   │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                       │
│                        ▼                                       │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              NAVIGATION MODE SELECTION                  │   │
│  │                                                         │   │
│  │  ┌─────────────┐              ┌─────────────┐           │   │
│  │  │   2D Nav    │              │   AR Nav    │           │   │
│  │  │   Button    │              │   Button    │           │   │
│  │  │ (Available  │              │ (Outdoor    │           │   │
│  │  │  Always)    │              │   Only)     │           │   │
│  │  └─────────────┘              └─────────────┘           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## How to Use These Diagrams in Your Patent Application

### **Section 7: Description of the invention in detail**

Add these references:

```
The hybrid navigation system architecture is illustrated in Figure 1, showing the integration of GPS satellites, Google Maps API, and camera sensors with the mobile device processor containing three main modules: Outdoor Navigation, Transition Controller, and Indoor Navigation.

Figure 2 demonstrates the outdoor AR navigation mode, where GPS signals and compass sensor data are processed to generate real-time camera overlays with directional guidance.

The indoor map processing pipeline is detailed in Figure 3, showing how 2D floor plan images are converted into navigable graphs using Python-based tools and OpenCV processing.

Figure 4 illustrates the automatic mode transition controller that monitors GPS distance and switches between outdoor and indoor navigation modes at the 25-meter threshold without user intervention.

The indoor pathfinding algorithm implementation is shown in Figure 5, demonstrating the Dijkstra algorithm processing with performance metrics including 0.239ms average execution time.

Figure 6 presents the complete user interaction flow from app launch through destination selection to navigation mode activation.
```

### **Benefits for Patent Application:**

✅ **Professional Appearance**: Clean, technical diagrams similar to standard patent figures  
✅ **Clear Technical Details**: Shows algorithms, data structures, and processing flows  
✅ **System Integration**: Demonstrates how components work together  
✅ **Performance Metrics**: Includes specific measurements and specifications  
✅ **User Interface**: Shows practical implementation and user interaction  

These diagrams will significantly strengthen your patent application by providing clear visual evidence of your technical innovations!