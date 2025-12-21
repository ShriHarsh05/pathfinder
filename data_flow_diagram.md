# Pathfinder Indoor Navigation - Data Flow Diagram

## System Architecture & Data Flow

```mermaid
graph TB
    %% Input Sources
    GPS[GPS Satellite Signals]
    Camera[Device Camera]
    Compass[Compass Sensor]
    FloorPlan[2D Floor Plan Image]
    UserInput[User Destination Input]
    
    %% Pre-processing (Offline)
    subgraph "Offline Processing"
        MapAnnotator[map_annotator.py<br/>Python Script]
        OpenCV[OpenCV<br/>Contour Extraction]
        NetworkX[NetworkX<br/>Graph Processing]
        FloorPlan --> MapAnnotator
        MapAnnotator --> OpenCV
        OpenCV --> NetworkX
        NetworkX --> JSONGraph[gdn_ground_floor_graph.json<br/>185 nodes, 282 edges]
    end
    
    %% Main Application Components
    subgraph "Flutter Mobile Application"
        %% Core Services
        subgraph "Core Services"
            LocationService[Geolocator Service<br/>GPS Tracking]
            IndoorMapService[Indoor Map Service<br/>Graph Loading & Pathfinding]
            CameraService[Camera Service<br/>AR Processing]
        end
        
        %% UI Layer
        subgraph "User Interface"
            HomeScreen[Home Screen<br/>Destination Selection]
            MapWidget[Map Widget<br/>Google Maps Display]
            ARView[AR Navigation View<br/>Camera Overlay]
            IndoorMapWidget[Indoor Map Widget<br/>2D Path Visualization]
        end
        
        %% Navigation Modules
        subgraph "Navigation Logic"
            OutdoorNav[Outdoor Navigation Module<br/>GPS + Google Maps API]
            IndoorNav[Indoor Navigation Module<br/>Dijkstra Algorithm]
            ModeTransition[Mode Transition Controller<br/>Geofence Detection]
            ARRenderer[AR Visualization Module<br/>Overlay Rendering]
        end
        
        %% Data Models
        subgraph "Data Models"
            DestinationModel[Destination Model<br/>Location Data]
            IndoorNodeModel[Indoor Node Model<br/>Graph Nodes]
            PathModel[Path Model<br/>Route Information]
        end
    end
    
    %% External APIs
    GoogleMaps[Google Maps API]
    
    %% Data Flow Connections
    
    %% Input to Services
    GPS --> LocationService
    Camera --> CameraService
    Compass --> CameraService
    UserInput --> HomeScreen
    JSONGraph --> IndoorMapService
    
    %% Service to UI
    LocationService --> HomeScreen
    LocationService --> MapWidget
    IndoorMapService --> IndoorMapWidget
    CameraService --> ARView
    
    %% UI to Navigation Logic
    HomeScreen --> OutdoorNav
    HomeScreen --> IndoorNav
    HomeScreen --> ModeTransition
    
    %% Navigation Logic Interactions
    LocationService --> ModeTransition
    ModeTransition --> OutdoorNav
    ModeTransition --> IndoorNav
    OutdoorNav --> MapWidget
    IndoorNav --> IndoorMapWidget
    IndoorNav --> ARRenderer
    ARRenderer --> ARView
    
    %% External API Integration
    GoogleMaps --> OutdoorNav
    GoogleMaps --> MapWidget
    
    %% Data Model Usage
    DestinationModel --> OutdoorNav
    DestinationModel --> IndoorNav
    IndoorNodeModel --> IndoorNav
    PathModel --> MapWidget
    PathModel --> IndoorMapWidget
    PathModel --> ARRenderer
    
    %% Styling
    classDef inputSource fill:#e1f5fe
    classDef processing fill:#f3e5f5
    classDef service fill:#e8f5e8
    classDef ui fill:#fff3e0
    classDef navigation fill:#fce4ec
    classDef model fill:#f1f8e9
    classDef external fill:#ffebee
    
    class GPS,Camera,Compass,FloorPlan,UserInput inputSource
    class MapAnnotator,OpenCV,NetworkX,JSONGraph processing
    class LocationService,IndoorMapService,CameraService service
    class HomeScreen,MapWidget,ARView,IndoorMapWidget ui
    class OutdoorNav,IndoorNav,ModeTransition,ARRenderer navigation
    class DestinationModel,IndoorNodeModel,PathModel model
    class GoogleMaps external
```

## Detailed Data Flow Process

### 1. **Initialization Phase**
```mermaid
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
```

### 2. **Outdoor Navigation Flow**
```mermaid
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
    Mode->>GPS: Check distance to building
    GPS-->>Mode: Distance = 30m
    Mode-->>Home: Switch to indoor mode
```

### 3. **Indoor Navigation Flow**
```mermaid
sequenceDiagram
    participant Mode as ModeTransition
    participant Indoor as IndoorNavigation
    participant Graph as Graph Service
    participant Dijkstra as Pathfinding
    participant AR as AR Renderer
    
    Mode->>Indoor: Activate indoor navigation
    Indoor->>Graph: Find room node ID
    Graph-->>Indoor: Node ID found
    Indoor->>Dijkstra: Calculate path(start, end)
    Dijkstra-->>Indoor: Optimal path nodes
    Indoor->>AR: Render path overlay
    AR-->>Indoor: AR visualization ready
```

## Key Data Structures

### Node Structure
```json
{
  "id": 7,
  "x": 594,
  "y": 1047,
  "type": "room",
  "name": "G01"
}
```

### Edge Structure
```json
{
  "source": 6,
  "target": 7,
  "weight": 17.26267650163207
}
```

### Destination Model
```dart
class Destination {
  final String id;
  final String name;
  final LatLng location;
  final String building;
  final bool isIndoor;
}
```

## Performance Metrics

| Component | Data Size | Processing Time |
|-----------|-----------|-----------------|
| JSON Graph Loading | 55.9 KB | 0.004s |
| Dijkstra Pathfinding | 185 nodes | 0.239ms avg |
| Memory Footprint | ~310 KB | Constant |
| AR Rendering Latency | - | 0.15-0.4s |

## Critical Decision Points

1. **Mode Transition**: GPS distance < 25m → Switch to indoor
2. **Path Selection**: Dijkstra algorithm for optimal indoor routing
3. **AR Activation**: User selects AR mode → Camera overlay enabled
4. **Graph Loading**: App startup → Preload indoor graph data

This data flow diagram shows how your hybrid navigation system seamlessly integrates outdoor GPS navigation with indoor graph-based pathfinding, demonstrating the technical sophistication that supports your patent claims.