import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pathfinder_indoor_navigation/models/destination.dart';
import 'package:pathfinder_indoor_navigation/widgets/map_widget.dart';
import 'package:searchfield/searchfield.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  Destination? _selectedDestination;
  StreamSubscription<Position>? _positionStreamSubscription;
  final _searchController = TextEditingController();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  /// First, gets the initial position, then starts the continuous stream.
  Future<void> _initializeLocation() async {
    try {
      // 1. Check permissions and services
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

      // 2. Get the FIRST position before building the UI to prevent layout bugs
      final initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      if (mounted) {
        setState(() {
          _currentPosition = initialPosition;
        });
      }

      // 3. NOW, start the stream for live updates in the background
      _startLocationStream();
    } catch (e) {
      print("Error initializing location: $e");
      _showErrorDialog("Could not get initial location. Please try again.");
    }
  }

  /// Starts the stream to listen for continuous location updates.
  void _startLocationStream() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1, // Update every 1 meter moved
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
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

  void _toggleNavigation() {
    setState(() {
      _isNavigating = !_isNavigating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pathfinder Indoor Navigation'),
        centerTitle: true,
        automaticallyImplyLeading: !_isNavigating,
      ),
      body: Stack(
        children: [
          // Show a loading indicator until the first location is fetched
          if (_currentPosition == null)
            const Center(child: CircularProgressIndicator())
          else
            _isNavigating ? _buildNavigationView() : _buildSelectionView(),

          if (_isNavigating) _buildStopNavigationButton(),
        ],
      ),
    );
  }

  Widget _buildSelectionView() {
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
                  child: MapWidget(
                    currentPosition: _currentPosition!,
                    destination: _selectedDestination,
                    isNavigating: false,
                  ),
                ),
              ),
              const SizedBox(height: 80), // Space for the button
            ],
          ),
          if (_selectedDestination != null) _buildStartNavigationButton(),
        ],
      ),
    );
  }

  Widget _buildNavigationView() {
    return MapWidget(
      currentPosition: _currentPosition!,
      destination: _selectedDestination,
      isNavigating: true,
    );
  }

  Widget _buildStartNavigationButton() {
    return Positioned(
      bottom: 16.0,
      left: 16.0,
      right: 16.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
        onPressed: _toggleNavigation,
        child: const Text('Start Navigation'),
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
                    BorderRadius.circular(30.0), // Pill shape
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          onPressed: _toggleNavigation,
          child: const Text('Stop'),
        ),
      ),
    );
  }

  Widget _buildDestinationSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: SearchField<Destination>(
          controller: _searchController,
          hint: 'Select a Destination',
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
            setState(() {
              _selectedDestination = item.item;
              _searchController.text = item.searchKey;
            });
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

