import 'package:camera/camera.dart';

class CameraService {
  late List<CameraDescription> _cameras;
  CameraController? controller;

  // Initialize the camera and return the first available camera
  Future<CameraController?> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        print('No cameras found.');
        return null;
      }
      
      // Initialize the first back camera
      controller = CameraController(
        _cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();
      return controller;
      
    } on CameraException catch (e) {
      print('Camera initialization error: $e');
      controller = null;
      return null;
    }
  }

  void dispose() {
    controller?.dispose();
  }
}
