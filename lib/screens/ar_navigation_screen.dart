import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:pathfinder_indoor_navigation/models/destination.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;


class ARNavigationScreen extends StatefulWidget {
  final Destination destination;
  final CameraDescription camera;
  
  const ARNavigationScreen({
    Key? key,
    required this.destination,
    required this.camera,
  }) : super(key: key);

  @override
  State<ARNavigationScreen> createState() => _ARNavigationScreenState();
}

class _ARNavigationScreenState extends State<ARNavigationScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  // Stream
  StreamSubscription? _positionStream;
  StreamSubscription? _compassStream;

  double? _heading; // Phone's current direction
  double? _distance; // Distance to destination
  double? _bearing; // Direction to destination

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false, // We don't need audio for navigation
    );
    _initializeControllerFuture = _cameraController.initialize();
    _startLiveDataStreams();
  }
  void _startLiveDataStreams() {
    _compassStream = FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted)
      {
        setState(() {
          _heading = event.heading;
        });
      }
    });
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      if (mounted)
      {
        final destLat = widget.destination.location.latitude;
        final destLng = widget.destination.location.longitude;
        final newDistance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          destLat,
          destLng,
        );
        final newBearing = Geolocator.bearingBetween(
          position.latitude,
          position.longitude,
          destLat,
          destLng,
        );
        setState(() {
          _distance = newDistance;
          _bearing = newBearing;
        });
      }
    });
  }
  @override
  void dispose()
  {
    _cameraController.dispose();
    _positionStream?.cancel();
    _compassStream?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigating to ${widget.destination.name}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Camera is ready, show preview and overlay
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_cameraController),
                // Use the NEW live AR overlay
                _buildLiveArOverlay(),
              ],
            );
          } else {
            // Camera is loading
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
  Widget _buildLiveArOverlay() {
    // Get the live data, or show "Calculating..."
    String distanceText = _distance != null
        ? '${_distance!.toStringAsFixed(0)}m' // e.g., "120m"
        : 'Calculating...';

    // Get the live direction instruction
    final directionData = _getDirectionInstruction();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top instruction card (NOW DYNAMIC)
            Card(
              color: Colors.black.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      directionData['icon'], // Dynamic icon
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(width: 15),
                    Text(
                      directionData['text'], // Dynamic text
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom destination card (NOW DYNAMIC)
            Card(
              color: Colors.deepPurple.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destination: ${widget.destination.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Distance: $distanceText', // Dynamic distance
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper function to calculate the direction instruction
  Map<String, dynamic> _getDirectionInstruction() {
    if (_heading == null || _bearing == null) {
      return {'text': 'Calculating...', 'icon': Icons.sync};
    }

    // Calculate the difference between where the phone is pointing and
    // the direction of the destination.
    double relativeBearing = _bearing! - _heading!;
    
    // Normalize to -180 to +180
    if (relativeBearing > 180) relativeBearing -= 360;
    if (relativeBearing < -180) relativeBearing += 360;

    // Based on the difference, give an instruction
    if (relativeBearing.abs() < 20) { // +/- 20 degrees
      return {'text': 'Straight Ahead', 'icon': Icons.arrow_upward};
    } else if (relativeBearing > 160 || relativeBearing < -160) { // 160 to 180
      return {'text': 'Turn Around', 'icon': Icons.replay};
    } else if (relativeBearing > 0 && relativeBearing < 90) {
      return {'text': 'Bear Right', 'icon': Icons.turn_right_rounded};
    } else if (relativeBearing > 90) {
      return {'text': 'Turn Right', 'icon': Icons.u_turn_right};
    } else if (relativeBearing < 0 && relativeBearing > -90) {
      return {'text': 'Bear Left', 'icon': Icons.turn_left_rounded};
    } else { // -90 to -160
      return {'text': 'Turn Left', 'icon': Icons.u_turn_left};
    }
  }
}