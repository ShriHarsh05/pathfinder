# Pathfinder Indoor Navigation

A sophisticated Flutter mobile application that provides seamless outdoor-to-indoor navigation capabilities, specifically designed for campus environments. The app combines GPS-based outdoor navigation with detailed indoor pathfinding using computer vision and augmented reality features.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Google Maps](https://img.shields.io/badge/Google%20Maps-4285F4?style=for-the-badge&logo=googlemaps&logoColor=white)

## 🚀 Features

### 🗺️ Hybrid Navigation System
- **Outdoor GPS Navigation**: Real-time GPS tracking to building entrances
- **Indoor Pathfinding**: Node-based graph navigation within buildings
- **Automatic Handoff**: Seamless transition from outdoor to indoor navigation

### 📱 Dual Navigation Modes
- **2D Navigation**: Traditional map-based routing with visual path overlay
- **AR Navigation**: Augmented reality camera overlay for immersive directions

### 🎯 Smart Location Detection
- Real-time proximity detection with configurable zones
- Automatic building entrance recognition (25m radius)
- Location-aware destination suggestions

### 🏢 Indoor Mapping System
- Custom node-based graph system for complex indoor spaces
- Room and pathway mapping with Dijkstra pathfinding algorithm
- Interactive visual map overlay with real-time path visualization

## 🛠️ Technical Stack

### Core Dependencies
- **Flutter SDK**: >=3.8.0 <4.0.0
- **Google Maps Flutter**: Outdoor mapping and GPS navigation
- **Geolocator**: Real-time location tracking and proximity detection
- **Camera**: AR navigation capabilities
- **Provider**: State management architecture
- **SearchField**: Smart destination search with autocomplete
- **Flutter Compass**: Orientation detection for AR features

### Architecture
```
lib/
├── screens/           # Main UI screens
├── services/          # Business logic and data services
├── models/           # Data structures and entities
├── widgets/          # Reusable UI components
└── utils/            # Helper functions and utilities

assets/
├── maps/             # Floor plans and navigation data
├── icons/            # UI icons and markers
└── images/           # App assets and logos
```

## 🏗️ Installation & Setup

### Prerequisites
- Flutter SDK (>=3.8.0)
- Android Studio / VS Code
- Android/iOS device or emulator
- Google Maps API key

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/pathfinder_indoor_navigation.git
   cd pathfinder_indoor_navigation
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Google Maps API**
   - Get your API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Add the key to your platform-specific configuration files

4. **Run the application**
   ```bash
   flutter run
   ```

## 🗺️ Map Annotation System

The project includes a powerful Python-based map annotation tool for creating indoor navigation graphs:

### Features
- **Interactive Node Placement**: Click-to-place room and pathway nodes
- **Automatic Path Linking**: Smart connection of pathway nodes within configurable distances
- **Graph Visualization**: Real-time visualization of navigation graphs
- **Path Testing**: Built-in pathfinding verification system

### Usage
```bash
# Install Python dependencies
pip install opencv-python networkx

# Run the map annotator
python map_annotator.py
```

### Workflow
1. Load building floor plan images
2. Mark room locations and pathway nodes
3. Define connections between nodes
4. Export navigation graph as JSON
5. Test pathfinding algorithms

## 📍 Current Implementation

### Supported Locations
- **GDN Building**: Complete indoor navigation with 21+ room destinations
- **Campus-wide**: 20+ outdoor destinations including:
  - Main Building (MB)
  - Silver Jubilee Tower (SJT)
  - Dr. M.G.R. Block
  - Pearl Research Park (PRP)
  - Libraries and Auditoriums
  - Canteens and Food Courts
  - Sports Complex and Swimming Pool

### Navigation Data
- **185+ Indoor Nodes**: Comprehensive mapping of GDN building
- **Room Database**: All major rooms with precise coordinates
- **Path Network**: Optimized routing between all locations
- **GPS Coordinates**: Accurate outdoor destination mapping

## 🎯 Usage Guide

### Basic Navigation
1. **Select Destination**: Use the search field to find your target location
2. **Choose Mode**: Select between 2D map navigation or AR camera mode
3. **Follow Directions**: The app provides turn-by-turn guidance
4. **Indoor Handoff**: Automatically switches to indoor navigation when approaching buildings

### AR Navigation
1. Grant camera permissions
2. Select AR navigation mode
3. Point camera in walking direction
4. Follow AR overlay directions

### Indoor Navigation
1. Select an indoor destination (e.g., "G01", "G10A")
2. App navigates to building entrance first
3. Automatic handoff to indoor navigation
4. Follow path visualization to your destination

## 🔧 Configuration

### Proximity Settings
```dart
// Distance thresholds (in meters)
static const double INDOOR_HANDOFF_RADIUS = 25.0;  // Building entrance detection
static const double OUTDOOR_ARRIVAL_RADIUS = 35.0; // Outdoor destination arrival
```

### Map Annotation Settings
```python
MAX_DISPLAY_HEIGHT = 800           # Display window height
MAX_AUTO_LINK_DISTANCE = 40.0     # Auto-linking distance for pathways
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart style guidelines
- Add tests for new features
- Update documentation for API changes
- Ensure cross-platform compatibility

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- Google Maps Platform for mapping services
- OpenCV and NetworkX communities for computer vision and graph algorithms
- Campus administration for building floor plans and location data

## 📞 Support

For support, email shriharshkotecha.sk@gmail.com or create an issue in this repository.

---

**Built with ❤️ using Flutter**
