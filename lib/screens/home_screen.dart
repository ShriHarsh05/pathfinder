import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pathfinder_indoor_navigation/models/destination.dart';
import 'package:pathfinder_indoor_navigation/widgets/map_widget.dart';
import 'package:pathfinder_indoor_navigation/screens/indoor_navigation_screen.dart'; 
import 'package:pathfinder_indoor_navigation/screens/ar_navigation_screen.dart'; 
import 'package:searchfield/searchfield.dart';
import 'package:camera/camera.dart'; 
import 'package:collection/collection.dart'; // For firstWhereOrNull

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({
    super.key,
    required this.cameras, 
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  Destination? _selectedDestination; // The *current* navigation target (could be a building)
  Destination? _finalIndoorDestination; // The *final* indoor target (e.g., G01)
  StreamSubscription<Position>? _positionStreamSubscription;
  final _searchController = TextEditingController();
  bool _isNavigating = false; 

  // --- NEW: Proximity check radius ---
  static const double INDOOR_HANDOFF_RADIUS = 20.0; // 20 meters

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorDialog('Location services are disabled. Please enable them.');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorDialog('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorDialog(
            'Location permissions are permanently denied. We cannot request permissions.');
        return;
      }

      final initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
      
      if (mounted) {
        setState(() {
          _currentPosition = initialPosition;
        });
      }

      _startLocationStream();
    } catch (e) {
      print("Error initializing location: $e");
      _showErrorDialog("Could not get initial location. Please try again.");
    }
  }
  
  void _startLocationStream() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1, // Update every 1 meter
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }

      // --- NEW: Proximity Handoff Logic ---
      // Check if we are currently navigating to an indoor final destination
      if (_isNavigating && _finalIndoorDestination != null && _selectedDestination != null) {
        
        // Calculate distance to the building entrance
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          _selectedDestination!.location.latitude,
          _selectedDestination!.location.longitude,
        );

        // If we are within the handoff radius
        if (distance < INDOOR_HANDOFF_RADIUS) {
          // --- CHECK: Prevent duplicate handoffs ---
          if (ModalRoute.of(context)?.isCurrent ?? false) {
             _triggerIndoorHandoff();
          }
        }
      }
    });
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _clearSelection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.clear();
      setState(() {
        _selectedDestination = null;
        _finalIndoorDestination = null;
        _isNavigating = false;
      });
    });
  }

  void _onStart2DNavigation() {
    if (_selectedDestination == null) return;
    
    // If the destination is indoor, we just start navigating to the building.
    // The location stream (_startLocationStream) will handle the handoff.
    if (_selectedDestination!.isIndoor || _finalIndoorDestination != null) {
      setState(() {
        _isNavigating = true;
      });
    } else {
      // It's a pure outdoor destination
      setState(() {
        _isNavigating = true;
      });
    }
  }

  void _onStartARNavigation() {
    if (_selectedDestination == null) return;
    if (widget.cameras.isEmpty) {
      _showErrorDialog("No camera found. Cannot start AR Navigation.");
      return;
    }

    // AR Nav will just navigate to the *current* target (the building entrance)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ARNavigationScreen(
          destination: _selectedDestination!,
          camera: widget.cameras[0], 
        ),
      ),
    );
    // Note: We don't clear selection, AR is just a view
  }

  // --- NEW: This is the function that switches to the indoor screen ---
  void _triggerIndoorHandoff() {
    // --- NEW: Check if we're already on the indoor screen ---
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      // Stop the outdoor navigation
      setState(() {
        _isNavigating = false;
      });

      // Navigate to the indoor screen, passing both start and end names
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IndoorNavigationScreen(
            preselectedDestinationName: _finalIndoorDestination!.name,
            preselectedStartName: "Entrance", // Default to "Entrance" as requested
            cameras: widget.cameras,
          ),
        ),
      );

      // Clear everything
      _clearSelection();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pathfinder Navigation'),
        centerTitle: true,
        automaticallyImplyLeading: !_isNavigating,
      ),
      body: Stack(
        children: [
          if (_currentPosition == null)
            const Center(child: CircularProgressIndicator())
          else
            _isNavigating ? _buildNavigationView() : _buildSelectionView(),

          if (_isNavigating) _buildStopNavigationButton(),

          // --- NEW: Add the "Simulate Arrival" button ---
          if (_isNavigating && _finalIndoorDestination != null)
            _buildSimulateArrivalButton(),
        ],
      ),
    );
  }

  Widget _buildSelectionView() {
    final mapKey = ValueKey('selection_${_selectedDestination?.id ?? "none"}');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Column(
            children: [
              _buildDestinationSelector(), // The single search bar
              const SizedBox(height: 20),
              Expanded(
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: MapWidget( // This is your Google Map Widget
                    key: mapKey, 
                    currentPosition: _currentPosition!,
                    destination: _selectedDestination,
                    isNavigating: false,
                  ),
                ),
              ),
              const SizedBox(height: 80), // Space for the button
            ],
          ),
          if (_selectedDestination != null) 
            _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildNavigationView() {
    final mapKey = ValueKey('navigation_${_selectedDestination?.id ?? "none"}');

    return MapWidget(
      key: mapKey,
      currentPosition: _currentPosition!,
      destination: _selectedDestination,
      isNavigating: true, // True for outdoor nav
    );
  }

  Widget _buildNavigationButtons() {
    return Positioned(
      bottom: 16.0,
      left: 16.0,
      right: 16.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Button 1: 2D Navigation
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('2D Nav'),
              style: ElevatedButton.styleFrom(
                // Style will be inherited from main.dart's theme
              ),
              onPressed: _onStart2DNavigation,
            ),
          ),
          const SizedBox(width: 12),

          // Button 2: AR Navigation
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('AR Nav'),
              style: ElevatedButton.styleFrom(
                // Style will be inherited from main.dart's theme
              ),
              onPressed: _onStartARNavigation,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopNavigationButton() {
    return Positioned(
      bottom: 32.0,
      left: 0,
      right: 0,
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(30.0),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          onPressed: () {
            // Updated to clear all navigation state
            _clearSelection();
          },
          child: const Text('Stop'),
        ),
      ),
    );
  }

  // --- NEW: A developer button to test the handoff ---
  Widget _buildSimulateArrivalButton() {
    return Positioned(
      bottom: 32.0,
      right: 16.0,
      child: FloatingActionButton(
        onPressed: _triggerIndoorHandoff, // Manually trigger the handoff
        tooltip: 'Simulate Arrival at GDN',
        backgroundColor: Colors.amber,
        child: const Icon(Icons.directions_walk, color: Colors.black),
      ),
    );
  }

  Widget _buildDestinationSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: SearchField<Destination>(
          controller: _searchController,
          hint: 'Select a Destination (Indoor or Outdoor)',
          suggestions: destinations 
              .map((dest) =>
                  SearchFieldListItem<Destination>(dest.name, item: dest))
              .toList(),
          searchInputDecoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.location_on),
          ),
          onSuggestionTap: (SearchFieldListItem<Destination> item) {
            FocusScope.of(context).unfocus();
            
            final destination = item.item;
            if (destination == null) return;

            // --- THIS IS THE KEY LOGIC ---
            if (destination.isIndoor) {
              // User selected an INDOOR location (e.g., "GDN G01")

              // Find the "Entrance" destination object for the building
              final buildingEntrance = destinations.firstWhereOrNull(
                (d) => d.id == 'gdn_entrance_target' // Find the entrance by its ID
              );

              setState(() {
                // Set the *final* destination to the room
                _finalIndoorDestination = destination;
                // Set the *current* navigation target to the building entrance
                _selectedDestination = buildingEntrance; 
                // Update search bar to show the FINAL destination
                _searchController.text = destination.name; 
              });

            } else {
              // User selected an OUTDOOR location.
              setState(() {
                _finalIndoorDestination = null; // Clear indoor target
                _selectedDestination = destination;
                _searchController.text = item.searchKey;
              });
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}