# Pathfinder Indoor Navigation - Fixed Mermaid Diagrams

## Main System Architecture Diagram

Copy this code to https://mermaid.live/ :

```
graph TB
    %% Input Sources
    GPS[GPS Satellite Signals]
    Camera[Device Camera]
    Compass[Compass Sensor]
    FloorPlan[2D Floor Plan Image]
    UserInput[User Destination Input]
    
    %% Pre-processing Offline
    subgraph Offline["Offline Processing"]
        MapAnnotator[map_annotator.py<br/>Python Script]
        OpenCV[OpenCV<br/>Contour Extraction]
        NetworkX[NetworkX<br/>Graph Processing]
        JSONGraph[gdn_ground_floor_graph.json<br/>185 nodes, 282 edges]
    end
    
    %% Main Application Components
    subgraph FlutterApp["Flutter Mobile Application"]
        %% Core Services
        subgraph CoreServices["Core Services"]
            LocationService[Geolocator Service<br/>GPS Tracking]
            IndoorMapService[Indoor Map Service<br/>Graph Loading & Pathfinding]
            CameraService[Camera Service<br/>AR Processing]
        end
        
        %% UI Layer
        subgraph UserInterface["User Interface"]
            HomeScreen[Home Screen<br/>Destination Selection]
            MapWidget[Map Widget<br/>Google Maps Display]
            ARView[AR Navigation View<br/>Camera Overlay]
            IndoorMapWidget[Indoor Map Widget<br/>2D Path Visualization]
        end
        
        %% Navigation Modules
        subgraph NavigationLogic["Navigation Logic"]
            OutdoorNav[Outdoor Navigation Module<br/>GPS + Google Maps API]
            IndoorNav[Indoor Navigation Module<br/>Dijkstra Algorithm]
            ModeTransition[Mode Transition Controller<br/>Geofence Detection]
            ARRenderer[AR Visualization Module<br/>Overlay Rendering]
        end
        
        %% Data Models
        subgraph DataModels["Data Models"]
            DestinationModel[Destination Model<br/>Location Data]
            IndoorNodeModel[Indoor Node Model<br/>Graph Nodes]
            PathModel[Path Model<br/>Route Information]
        end
    end
    
    %% External APIs
    GoogleMaps[Google Maps API]
    
    %% Data Flow Connections
    FloorPlan --> MapAnnotator
    MapAnnotator --> OpenCV
    OpenCV --> NetworkX
    NetworkX --> JSONGraph
    
    GPS --> LocationService
    Camera --> CameraService
    Compass --> CameraService
    UserInput --> HomeScreen
    JSONGraph --> IndoorMapService
    
    LocationService --> HomeScreen
    LocationService --> MapWidget
    IndoorMapService --> IndoorMapWidget
    CameraService --> ARView
    
    HomeScreen --> OutdoorNav
    HomeScreen --> IndoorNav
    HomeScreen --> ModeTransition
    
    LocationService --> ModeTransition
    ModeTransition --> OutdoorNav
    ModeTransition --> IndoorNav
    OutdoorNav --> MapWidget
    IndoorNav --> IndoorMapWidget
    IndoorNav --> ARRenderer
    ARRenderer --> ARView
    
    GoogleMaps --> OutdoorNav
    GoogleMaps --> MapWidget
    
    DestinationModel --> OutdoorNav
    DestinationModel --> IndoorNav
    IndoorNodeModel --> IndoorNav
    PathModel --> MapWidget
    PathModel --> IndoorMapWidget
    PathModel --> ARRenderer
    
    %% Styling
    classDef inputSource fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef processing fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef service fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef ui fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef navigation fill:#fce4ec,stroke:#880e4f,stroke-width:2px
    classDef model fill:#f1f8e9,stroke:#33691e,stroke-width:2px
    classDef external fill:#ffebee,stroke:#b71c1c,stroke-width:2px
    
    class GPS,Camera,Compass,FloorPlan,UserInput inputSource
    class MapAnnotator,OpenCV,NetworkX,JSONGraph processing
    class LocationService,IndoorMapService,CameraService service
    class HomeScreen,MapWidget,ARView,IndoorMapWidget ui
    class OutdoorNav,IndoorNav,ModeTransition,ARRenderer navigation
    class DestinationModel,IndoorNodeModel,PathModel model
    class GoogleMaps external
```

## Initialization Sequence Diagram

Copy this code to https://mermaid.live/ :

```
sequenceDiagram
    participant App as Flutter App
    participant IMS as IndoorMapService
    participant JSON as JSON Graph File
    participant Camera as Camera Service
    
    App->>IMS: loadMapData()
    IMS->>JSON: Load gdn_ground_floor_graph.json
    JSON-->>IMS: 185 nodes, 282 edges
    IMS-->>App: Graph loaded successfully
    App->>Camera: Initialize camera for AR
    Camera-->>App: Camera ready
    Note over App,Camera: System ready for navigation
```

## Outdoor Navigation Flow

Copy this code to https://mermaid.live/ :

```
sequenceDiagram
    participant User as User
    participant Home as HomeScreen
    participant GPS as GPS Service
    participant GMaps as Google Maps
    participant Mode as ModeTransition
    
    User->>Home: Select destination
    Home->>GPS: Get current location
    GPS-->>Home: Current coordinates
    Home->>GMaps: Calculate route
    GMaps-->>Home: Route polyline
    Home->>Mode: Monitor proximity
    loop Every 5 seconds
        Mode->>GPS: Check distance to building
        GPS-->>Mode: Distance = 30m
    end
    Note over Mode: Distance < 25m detected
    Mode-->>Home: Switch to indoor mode
```

## Indoor Navigation Flow

Copy this code to https://mermaid.live/ :

```
sequenceDiagram
    participant Mode as ModeTransition
    participant Indoor as IndoorNavigation
    participant Graph as Graph Service
    participant Dijkstra as Pathfinding
    participant AR as AR Renderer
    participant UI as User Interface
    
    Mode->>Indoor: Activate indoor navigation
    Indoor->>Graph: Find room node ID
    Graph-->>Indoor: Node ID found
    Indoor->>Dijkstra: Calculate path(start, end)
    Note over Dijkstra: Dijkstra algorithm<br/>0.239ms average
    Dijkstra-->>Indoor: Optimal path nodes
    Indoor->>AR: Render path overlay
    AR-->>Indoor: AR visualization ready
    Indoor->>UI: Display indoor navigation
    Note over UI: User sees 2D map or AR view
```

## Simplified System Overview

Copy this code to https://mermaid.live/ :

```
flowchart TD
    A[User Opens App] --> B[Load Indoor Graph<br/>185 nodes, 282 edges]
    B --> C[Select Destination]
    C --> D{Destination Type?}
    
    D -->|Outdoor| E[GPS Navigation<br/>Google Maps]
    D -->|Indoor Room| F[Navigate to Building<br/>GPS Mode]
    
    E --> G[Arrive at Destination]
    F --> H{Distance < 25m?}
    
    H -->|No| I[Continue GPS Navigation]
    H -->|Yes| J[Switch to Indoor Mode<br/>Automatic]
    
    I --> H
    J --> K[Find Room in Graph]
    K --> L[Calculate Path<br/>Dijkstra Algorithm]
    L --> M{Navigation Mode?}
    
    M -->|2D Map| N[Show Floor Plan<br/>with Path Overlay]
    M -->|AR Mode| O[Camera View<br/>with Direction Arrows]
    
    N --> P[Follow Path to Room]
    O --> P
    P --> Q[Destination Reached]
    
    style A fill:#e1f5fe
    style B fill:#f3e5f5
    style J fill:#fce4ec
    style L fill:#e8f5e8
    style Q fill:#c8e6c9
```

## How to Use These Diagrams:

### Step 1: Go to Mermaid Live Editor
Visit: **https://mermaid.live/**

### Step 2: Copy and Paste
1. Copy one of the code blocks above (without the triple backticks)
2. Paste it into the left panel of the Mermaid editor
3. The diagram will appear on the right side

### Step 3: Export (Optional)
- Click "Actions" → "Download PNG" to save as image
- Use the image in your patent application

### For Your Patent Application:
I recommend using the **"Simplified System Overview"** diagram as it clearly shows:
- ✅ The hybrid outdoor-indoor flow
- ✅ Automatic mode transition at 25m
- ✅ Graph-based indoor navigation
- ✅ Dual visualization modes (2D/AR)

This will be perfect for **Section 7** of your patent application!