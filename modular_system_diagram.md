# Pathfinder Indoor Navigation - Modular System Architecture

## Three-Block System Architecture

Copy this code to https://mermaid.live/ :

```
flowchart TB
    %% USER INTERACTION BLOCK
    subgraph UserBlock["👤 USER INTERACTION LAYER"]
        User[User]
        UserActions["User Actions:<br/>• Select Destination<br/>• Choose Navigation Mode<br/>• View Directions"]
        UserInterface["User Interface:<br/>• Home Screen<br/>• Search Field<br/>• Map Display<br/>• AR Camera View"]
    end
    
    %% OUTDOOR NAVIGATION SYSTEM
    subgraph OutdoorBlock["🌍 OUTDOOR NAVIGATION SYSTEM"]
        direction TB
        GPS[GPS Satellite Signals]
        GoogleMaps[Google Maps API]
        
        subgraph OutdoorComponents["Outdoor Components"]
            LocationService[Location Service<br/>• Real-time GPS tracking<br/>• Position updates<br/>• Distance calculation]
            OutdoorNav[Outdoor Navigation Module<br/>• Route calculation<br/>• Turn-by-turn directions<br/>• Map visualization]
            ProximityDetector[Proximity Detector<br/>• Geofence monitoring<br/>• 25m radius detection<br/>• Building approach alert]
        end
        
        OutdoorData["Outdoor Data:<br/>• GPS coordinates<br/>• Route polylines<br/>• Distance to destination<br/>• Map tiles"]
    end
    
    %% INDOOR NAVIGATION SYSTEM  
    subgraph IndoorBlock["🏢 INDOOR NAVIGATION SYSTEM"]
        direction TB
        FloorPlan[2D Floor Plan Image]
        
        subgraph PreProcessing["Pre-processing (Offline)"]
            MapAnnotator[map_annotator.py<br/>Python Script]
            OpenCV[OpenCV<br/>Contour Extraction]
            NetworkX[NetworkX<br/>Graph Generation]
        end
        
        subgraph IndoorComponents["Indoor Components"]
            IndoorMapService[Indoor Map Service<br/>• Graph loading (185 nodes)<br/>• Room identification<br/>• Path computation]
            PathFinder[Pathfinding Engine<br/>• Dijkstra algorithm<br/>• 0.239ms average<br/>• Optimal route calculation]
            ARRenderer[AR Visualization<br/>• Camera overlay<br/>• Direction arrows<br/>• Real-time rendering]
            IndoorMapWidget[2D Map Renderer<br/>• Floor plan display<br/>• Path overlay<br/>• Node markers]
        end
        
        IndoorData["Indoor Data:<br/>• JSON graph (55.9 KB)<br/>• Node coordinates<br/>• Edge weights<br/>• Room mappings"]
    end
    
    %% MODE TRANSITION CONTROLLER (Bridge)
    subgraph TransitionBlock["⚡ MODE TRANSITION CONTROLLER"]
        ModeController[Automatic Mode Switcher<br/>• Monitors GPS distance<br/>• Triggers indoor mode at 25m<br/>• Seamless handoff<br/>• No user intervention]
    end
    
    %% USER INTERACTIONS
    User --> UserActions
    UserActions --> UserInterface
    UserInterface --> User
    
    %% USER TO SYSTEMS
    UserInterface -.->|"1. Select Destination"| OutdoorNav
    UserInterface -.->|"2. Choose AR/2D Mode"| ARRenderer
    UserInterface -.->|"2. Choose AR/2D Mode"| IndoorMapWidget
    
    %% OUTDOOR SYSTEM FLOWS
    GPS --> LocationService
    GoogleMaps --> OutdoorNav
    LocationService --> OutdoorNav
    LocationService --> ProximityDetector
    OutdoorNav --> OutdoorData
    OutdoorData --> UserInterface
    
    %% INDOOR SYSTEM FLOWS
    FloorPlan --> MapAnnotator
    MapAnnotator --> OpenCV
    OpenCV --> NetworkX
    NetworkX --> IndoorData
    IndoorData --> IndoorMapService
    IndoorMapService --> PathFinder
    PathFinder --> ARRenderer
    PathFinder --> IndoorMapWidget
    ARRenderer --> UserInterface
    IndoorMapWidget --> UserInterface
    
    %% MODE TRANSITION FLOWS
    ProximityDetector -->|"Distance < 25m"| ModeController
    ModeController -->|"Activate Indoor"| IndoorMapService
    ModeController -->|"Deactivate Outdoor"| OutdoorNav
    
    %% STYLING
    classDef userStyle fill:#e3f2fd,stroke:#1976d2,stroke-width:3px
    classDef outdoorStyle fill:#e8f5e8,stroke:#388e3c,stroke-width:3px
    classDef indoorStyle fill:#fff3e0,stroke:#f57c00,stroke-width:3px
    classDef transitionStyle fill:#fce4ec,stroke:#c2185b,stroke-width:3px
    classDef dataStyle fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    
    class UserBlock,User,UserActions,UserInterface userStyle
    class OutdoorBlock,GPS,GoogleMaps,LocationService,OutdoorNav,ProximityDetector outdoorStyle
    class IndoorBlock,FloorPlan,MapAnnotator,OpenCV,NetworkX,IndoorMapService,PathFinder,ARRenderer,IndoorMapWidget indoorStyle
    class TransitionBlock,ModeController transitionStyle
    class OutdoorData,IndoorData dataStyle
```

## Detailed User Journey Flow

Copy this code to https://mermaid.live/ :

```
sequenceDiagram
    participant U as 👤 User
    participant UI as User Interface
    participant OS as 🌍 Outdoor System
    participant TC as ⚡ Transition Controller
    participant IS as 🏢 Indoor System
    
    Note over U,IS: App Initialization
    U->>UI: Opens App
    UI->>IS: Load indoor graph (185 nodes)
    IS-->>UI: Graph loaded (55.9 KB)
    
    Note over U,IS: Destination Selection
    U->>UI: Types destination "G01"
    UI->>UI: Search autocomplete
    UI-->>U: Shows destination options
    U->>UI: Selects "G01 Room"
    
    Note over U,IS: Outdoor Navigation Phase
    UI->>OS: Start navigation to GDN Building
    OS->>OS: Get GPS location
    OS->>OS: Calculate route via Google Maps
    OS-->>UI: Display route on map
    UI-->>U: Shows outdoor navigation
    
    loop GPS Tracking
        OS->>TC: Current distance to building
        TC->>TC: Check if distance < 25m
    end
    
    Note over U,IS: Automatic Mode Transition
    TC->>TC: Distance = 20m (< 25m threshold)
    TC->>OS: Deactivate outdoor mode
    TC->>IS: Activate indoor mode
    TC-->>UI: Switch to indoor interface
    
    Note over U,IS: Indoor Navigation Phase
    IS->>IS: Find room "G01" in graph
    IS->>IS: Calculate path using Dijkstra
    IS-->>UI: Path calculated (0.239ms)
    
    U->>UI: Choose navigation mode
    alt AR Mode Selected
        UI->>IS: Activate AR renderer
        IS-->>UI: Camera view with arrows
        UI-->>U: AR navigation display
    else 2D Mode Selected
        UI->>IS: Activate 2D map renderer
        IS-->>UI: Floor plan with path overlay
        UI-->>U: 2D map navigation display
    end
    
    Note over U,IS: Navigation Complete
    U->>U: Follows directions to room
    IS->>UI: Destination reached detection
    UI-->>U: "You have arrived at G01"
```

## System Component Details

Copy this code to https://mermaid.live/ :

```
graph LR
    %% USER BLOCK DETAILS
    subgraph UserDetails["👤 USER INTERACTION COMPONENTS"]
        direction TB
        UserInput["User Inputs:<br/>• Destination search<br/>• Mode selection<br/>• Navigation preferences"]
        UserOutput["User Outputs:<br/>• Visual directions<br/>• Audio guidance<br/>• Arrival notifications"]
        UserDevices["User Devices:<br/>• Smartphone screen<br/>• Camera sensor<br/>• GPS receiver<br/>• Compass sensor"]
    end
    
    %% OUTDOOR BLOCK DETAILS
    subgraph OutdoorDetails["🌍 OUTDOOR SYSTEM COMPONENTS"]
        direction TB
        OutdoorInputs["Inputs:<br/>• GPS satellite signals<br/>• Google Maps API<br/>• User destination"]
        OutdoorProcessing["Processing:<br/>• Location tracking<br/>• Route calculation<br/>• Distance monitoring<br/>• Map rendering"]
        OutdoorOutputs["Outputs:<br/>• Turn-by-turn directions<br/>• Map visualization<br/>• Proximity alerts<br/>• ETA calculations"]
    end
    
    %% INDOOR BLOCK DETAILS
    subgraph IndoorDetails["🏢 INDOOR SYSTEM COMPONENTS"]
        direction TB
        IndoorInputs["Inputs:<br/>• Floor plan image<br/>• Room destination<br/>• User position"]
        IndoorProcessing["Processing:<br/>• Graph generation (185 nodes)<br/>• Pathfinding (Dijkstra)<br/>• AR rendering<br/>• 2D visualization"]
        IndoorOutputs["Outputs:<br/>• Optimal path route<br/>• AR direction arrows<br/>• Floor plan overlay<br/>• Room guidance"]
    end
    
    %% TRANSITION DETAILS
    subgraph TransitionDetails["⚡ TRANSITION CONTROLLER"]
        direction TB
        TransitionLogic["Transition Logic:<br/>• GPS distance monitoring<br/>• 25m threshold detection<br/>• Automatic mode switching<br/>• Seamless handoff"]
    end
    
    %% CONNECTIONS BETWEEN BLOCKS
    UserInput -.->|Destination Request| OutdoorInputs
    UserInput -.->|Mode Selection| IndoorInputs
    
    OutdoorOutputs -.->|Navigation Display| UserOutput
    IndoorOutputs -.->|Path Guidance| UserOutput
    
    OutdoorProcessing -->|Distance Data| TransitionLogic
    TransitionLogic -->|Mode Switch Signal| IndoorProcessing
    
    %% STYLING
    classDef userStyle fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef outdoorStyle fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef indoorStyle fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef transitionStyle fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    
    class UserDetails,UserInput,UserOutput,UserDevices userStyle
    class OutdoorDetails,OutdoorInputs,OutdoorProcessing,OutdoorOutputs outdoorStyle
    class IndoorDetails,IndoorInputs,IndoorProcessing,IndoorOutputs indoorStyle
    class TransitionDetails,TransitionLogic transitionStyle
```

## Key Technical Specifications

### 📊 System Performance Metrics

| Component | Specification | Performance |
|-----------|---------------|-------------|
| **Outdoor System** | GPS Accuracy | 5.3m mean error |
| **Indoor System** | Graph Size | 185 nodes, 282 edges |
| **Indoor System** | Pathfinding Speed | 0.239ms average |
| **Indoor System** | Memory Usage | 310 KB constant |
| **Transition Controller** | Switch Threshold | 25m radius |
| **Transition Controller** | Switch Time | Real-time (<1s) |
| **AR Renderer** | Latency | 0.15-0.4s |
| **Data Storage** | JSON File Size | 55.9 KB |

### 🔄 System Integration Points

1. **User → Outdoor**: Destination selection triggers GPS navigation
2. **Outdoor → Transition**: Distance monitoring enables automatic switching  
3. **Transition → Indoor**: Seamless handoff without user intervention
4. **Indoor → User**: Dual visualization modes (2D/AR) for guidance

## Benefits for Patent Application

This modular approach clearly demonstrates:

✅ **Separation of Concerns**: Each system has distinct responsibilities  
✅ **Seamless Integration**: Automatic transition between systems  
✅ **User-Centric Design**: Clear user interaction flows  
✅ **Technical Sophistication**: Detailed component specifications  
✅ **Innovation Clarity**: Hybrid architecture with automatic handoff  

Perfect for **Section 7** of your patent application!