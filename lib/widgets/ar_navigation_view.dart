import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
// Pointing directly to your destination model file
import 'package:pathfinder_indoor_navigation/models/destination.dart';

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

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _cameraController = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
      enableAudio: false, // We don't need audio for navigation
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _cameraController.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraController.dispose();
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
            // If the Future is complete, display the preview.
            return Stack(
              fit: StackFit.expand,
              children: [
                // The camera preview
                CameraPreview(_cameraController),
                // The simulated AR overlay
                _buildSimulatedArOverlay(),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  /// Builds the simulated AR overlay UI
  Widget _buildSimulatedArOverlay() {
    // Using SafeArea to avoid the system's top notch/island
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top instruction card
            Card(
              color: Colors.black.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.turn_right_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(width: 15),
                    Text(
                      'Turn right in 10m',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom destination card
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
                    const Text(
                      'Estimated distance: 45m',
                      style: TextStyle(
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
}

