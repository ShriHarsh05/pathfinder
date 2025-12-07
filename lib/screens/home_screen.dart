import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pathfinder_indoor_navigation/models/destination.dart';
import 'package:pathfinder_indoor_navigation/widgets/map_widget.dart';
import 'package:pathfinder_indoor_navigation/screens/indoor_navigation_screen.dart'; 
import 'package:pathfinder_indoor_navigation/screens/ar_navigation_screen.dart'; 
import 'package:pathfinder_indoor_navigation/widgets/arrival_dialog.dart'; // Ensure this matches Step 1
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
  Destination? _selectedDestination; // The *current* navigation target
  Destination? _finalIndoorDestination; // The *final* indoor target
  StreamSubscription<Position>? _positionStreamSubscription;
  final _searchController = TextEditingController();
  bool _isNavigating = false; 

  // --- UPDATED: Increased radius to 80m for better detection ---
  static const double INDOOR_HANDOFF_RADIUS = 80.0; 

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

      // --- Proximity Handoff Logic ---
      if (_isNavigating && _finalIndoorDestination != null && _selectedDestination != null) {
        
        // Calculate distance to the building entrance
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          _selectedDestination!.location.latitude,
          _selectedDestination!.location.longitude,
        );

        // --- DEBUG PRINT ---
        print("Distance to GDN Entrance: ${distance.toStringAsFixed(2)} meters");

        // If we are within the handoff radius
        if (distance < INDOOR_HANDOFF_RADIUS) {
          if (ModalRoute.of(context)?.isCurrent ?? false) {
             // Show the popup first, then switch
             _showArrivalDialogAndSwitch();
          }
        }
      }
    });
  }

  // --- NEW: Updated Function to handle the timer dialog ---
  void _showArrivalDialogAndSwitch() {
    // 1. Pause navigation updates immediately so the dialog doesn't trigger twice
    setState(() {
      _isNavigating = false;
    });

    // 2. Show the smart dialog
    showDialog(
      context: context,
      barrierDismissible: false, // User must either wait or click a button
      builder: (context) => ArrivalDialog(
        destinationName: _finalIndoorDestination?.name ?? "Indoor Location",
        
        // CHOICE A: Switch Now (Manual button or Timer end)
        onSwitchNow: () {
          Navigator.of(context).pop(); // Close dialog
          _triggerIndoorHandoff();     // Go to indoor screen
        },
        
        // CHOICE B: Stay Here
        onStay: () {
          Navigator.of(context).pop(); // Close dialog
          // We intentionally remain with _isNavigating = false.
          // This keeps the user on the map with the path visible,
          // but stops the "You have arrived" loop.
        },
      ),
    );
  }

  void _triggerIndoorHandoff() {
      // Navigate to the indoor screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IndoorNavigationScreen(
            preselectedDestinationName: _finalIndoorDestination!.name,
            preselectedStartName: "Entrance", 
            cameras: widget.cameras,
          ),
        ),
      );

      // Clear the outdoor selection state so when they come back, it's clean
      _clearSelection();
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
    
    if (_selectedDestination!.isIndoor || _finalIndoorDestination != null) {
      setState(() {
        _isNavigating = true;
      });
    } else {
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ARNavigationScreen(
          destination: _selectedDestination!,
          camera: widget.cameras[0], 
        ),
      ),
    );
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

          // The debug button is still useful for testing the new dialog
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
              _buildDestinationSelector(),
              const SizedBox(height: 20),
              Expanded(
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: MapWidget(
                    key: mapKey, 
                    currentPosition: _currentPosition!,
                    destination: _selectedDestination,
                    isNavigating: false,
                  ),
                ),
              ),
              const SizedBox(height: 80),
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
      isNavigating: true,
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
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('2D Nav'),
              onPressed: _onStart2DNavigation,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('AR Nav'),
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
            _clearSelection();
          },
          child: const Text('Stop'),
        ),
      ),
    );
  }

  Widget _buildSimulateArrivalButton() {
    return Positioned(
      bottom: 32.0,
      right: 16.0,
      child: FloatingActionButton(
        onPressed: _showArrivalDialogAndSwitch, 
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

            if (destination.isIndoor) {
              final buildingEntrance = destinations.firstWhereOrNull(
                (d) => d.id == 'gdn_entrance_target'
              );

              setState(() {
                _finalIndoorDestination = destination;
                _selectedDestination = buildingEntrance; 
                _searchController.text = destination.name; 
              });

            } else {
              setState(() {
                _finalIndoorDestination = null;
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