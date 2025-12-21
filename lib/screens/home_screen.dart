import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pathfinder_indoor_navigation/models/destination.dart';
import 'package:pathfinder_indoor_navigation/widgets/map_widget.dart';
import 'package:pathfinder_indoor_navigation/screens/indoor_navigation_screen.dart'; 
import 'package:pathfinder_indoor_navigation/screens/ar_navigation_screen.dart'; 
import 'package:pathfinder_indoor_navigation/widgets/arrival_dialog.dart'; 
import 'package:pathfinder_indoor_navigation/widgets/destination_reached_dialog.dart'; 
import 'package:searchfield/searchfield.dart';
import 'package:camera/camera.dart'; 
import 'package:collection/collection.dart'; 

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
  Destination? _selectedDestination; 
  Destination? _finalIndoorDestination; 
  StreamSubscription<Position>? _positionStreamSubscription;
  final _searchController = TextEditingController();
  bool _isNavigating = false; 

  // --- UPDATED RADIUS SETTINGS ---
  // 25.0 meters for both indoor handoff and outdoor arrival (consistent threshold)
  static const double INDOOR_HANDOFF_RADIUS = 25.0; 
  // 25.0 meters for outdoor arrival (consistent with indoor handoff)
  static const double OUTDOOR_ARRIVAL_RADIUS = 25.0; 

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
        _showErrorDialog('Location services are disabled.');
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
        _showErrorDialog('Location permissions are permanently denied.');
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
    }
  }
  
  void _startLocationStream() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1, 
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }

      if (_isNavigating && _selectedDestination != null) {
        
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          _selectedDestination!.location.latitude,
          _selectedDestination!.location.longitude,
        );

        // --- CASE 1: INDOOR HANDOFF ---
        if (_finalIndoorDestination != null) {
           // Debug print to see distance in console
           print("Distance to Entrance: ${distance.toStringAsFixed(2)}m (Threshold: $INDOOR_HANDOFF_RADIUS)");
           
           if (distance < INDOOR_HANDOFF_RADIUS) {
             if (ModalRoute.of(context)?.isCurrent ?? false) {
                _showHandoffDialog();
             }
           }
        } 
        // --- CASE 2: OUTDOOR ARRIVAL ---
        else {
           // Debug print to see distance in console
           print("Distance to Destination: ${distance.toStringAsFixed(2)}m (Threshold: $OUTDOOR_ARRIVAL_RADIUS)");

           if (distance < OUTDOOR_ARRIVAL_RADIUS) {
             if (ModalRoute.of(context)?.isCurrent ?? false) {
                _showOutdoorArrivalDialog();
             }
           }
        }
      }
    });
  }

  void _showHandoffDialog() {
    setState(() { _isNavigating = false; }); 

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) => ArrivalDialog(
        destinationName: _finalIndoorDestination?.name ?? "Indoor Location",
        onSwitchNow: () {
          Navigator.of(context).pop(); 
          _triggerIndoorHandoff();     
        },
        onStay: () {
          Navigator.of(context).pop(); 
        },
      ),
    );
  }

  void _showOutdoorArrivalDialog() {
    setState(() { _isNavigating = false; }); 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DestinationReachedDialog(
        destinationName: _selectedDestination?.name ?? "Destination",
        onOk: () {
          _clearSelection(); 
        },
      ),
    );
  }

  void _triggerIndoorHandoff() {
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
      _clearSelection();
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(child: const Text('OK'), onPressed: () => Navigator.of(context).pop()),
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
    setState(() {
      _isNavigating = true;
    });
  }

  void _onStartARNavigation() {
    if (_selectedDestination == null) return;
    if (widget.cameras.isEmpty) {
      _showErrorDialog("No camera found.");
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

          if (_isNavigating && _selectedDestination != null)
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
      bottom: 16.0, left: 16.0, right: 16.0,
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
      bottom: 32.0, left: 0, right: 0,
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
          onPressed: _clearSelection,
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
        onPressed: () {
          if (_finalIndoorDestination != null) {
            _showHandoffDialog();
          } else {
            _showOutdoorArrivalDialog();
          }
        }, 
        tooltip: 'Simulate Arrival',
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
          hint: 'Select a Destination',
          suggestions: destinations.map((dest) => SearchFieldListItem<Destination>(dest.name, item: dest)).toList(),
          searchInputDecoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.location_on),
          ),
          onSuggestionTap: (SearchFieldListItem<Destination> item) {
            FocusScope.of(context).unfocus();
            final destination = item.item;
            if (destination == null) return;

            if (destination.isIndoor) {
              final buildingEntrance = destinations.firstWhereOrNull((d) => d.id == 'gdn_entrance_target');
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