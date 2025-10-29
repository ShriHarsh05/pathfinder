import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pathfinder_indoor_navigation/models/destination.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

final LatLngBounds vitCampusBounds = LatLngBounds(
  southwest: const LatLng(12.9680, 79.1540), // Min lat, Min lng
  northeast: const LatLng(12.9755, 79.1665), // Max lat, Max lng
);

class MapWidget extends StatefulWidget {
  final Position currentPosition;
  final Destination? destination;
  final bool isNavigating;

  const MapWidget({
    super.key,
    required this.currentPosition,
    required this.destination,
    required this.isNavigating,
  });

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  ui.Image? _gdnMapImage;
  bool _isInsideGdn = false;

  //BitmapDescriptor _currentLocationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  BitmapDescriptor _currentLocationIcon = BitmapDescriptor.defaultMarker;

  // GDN Building Coordinates (User-provided: 12.9697, 79.1547)
  static const LatLng _gdnBuildingLatLng = LatLng(12.9697, 79.1547); 
  static const double _proximityRadiusMeters = 50.0; // Radius to switch to indoor map

  @override
  void initState() {
    super.initState();
    _loadIndoorMapAsset();
    _checkIndoorStatus(widget.currentPosition);
    _loadCustomMarker();
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate proximity whenever the position updates
    if (widget.currentPosition != oldWidget.currentPosition) {
      _checkIndoorStatus(widget.currentPosition);
    }
  }

  Future<void> _loadIndoorMapAsset() async {
    try {
      // Note: Make sure 'assets/maps/binary_paint_cleaned_gdn.png' is added to pubspec.yaml
      final ByteData data = await rootBundle.load('assets/maps/binary_paint_cleaned_gdn.png');
      final List<int> bytes = data.buffer.asUint8List();
      final Completer<ui.Image> completer = Completer();
      ui.decodeImageFromList(Uint8List.fromList(bytes), (img) {
        return completer.complete(img);
      });
      _gdnMapImage = await completer.future;
      if (mounted) setState(() {});
    } catch (e) {
      print("Error loading indoor map asset: $e");
    }
  }

  Future<void> _loadCustomMarker() async {
    try {
      final icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(24, 24)), // You can adjust the size
        'assets/icons/location_dot.png', // Make sure you create this file!
      );
      if (mounted) {
        setState(() {
          _currentLocationIcon = icon;
        });
      }
    } catch (e) {
      print("Error loading custom marker: $e");
      // Keep the default icon if loading fails
    }
  }

  void _checkIndoorStatus(Position position) {
    // 1. Calculate distance to the GDN building entrance
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _gdnBuildingLatLng.latitude,
      _gdnBuildingLatLng.longitude,
    );
    
    // 2. Check conditions for indoor map display:
    // a) Destination must be an indoor location (isIndoor: true)
    // b) User must be within the proximity radius
    final isDestinationGdn = widget.destination?.building == 'GDN Block';
    final isNearBuilding = distance < _proximityRadiusMeters;

    final shouldBeIndoor = isDestinationGdn && isNearBuilding;

    if (_isInsideGdn != shouldBeIndoor) {
      if (mounted) {
        setState(() {
          _isInsideGdn = shouldBeIndoor;
        });
      }
    }
  }

  // --- Map Display Functions ---

  Widget _buildIndoorMap() {
    // Determine the specific location string inside GDN to display (e.g., G07 Survey Lab)
    final destinationName = widget.destination?.name ?? 'GDN Block';
    
    if (_gdnMapImage == null) {
      return const Center(child: Text('Loading GDN Indoor Map...'));
    }
    
    // Indoor Map Display (Binary GDN Map)
    return Container(
      color: Colors.black, // Background for the binary map
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'INDOOR NAVIGATION: $destinationName',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/maps/binary_paint_cleaned_gdn.png',
                fit: BoxFit.contain, // Fit the image nicely within the container
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text('Error: Indoor Map Asset Not Found!', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Pathfinding Logic (API CALLS) will be implemented here.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutdoorMap() {
    final userLatLng = LatLng(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
    );
    
    final LatLng destinationLatLng = widget.destination?.location ?? userLatLng;
    
    final Set<Marker> markers = {
      // User's Current Location Marker (Blue)
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: userLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'You Are Here'),
      ),
    };

    final Set<Polyline> polylines = {};
    
    // Add Destination Marker and Path if a destination is selected
    if (widget.destination != null) {
      markers.add(
        // Destination Marker (Red)
        Marker(
          markerId: const MarkerId('toLocation'),
          position: destinationLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: widget.destination!.name),
        ),
      );

      // Draw a path between user and destination location
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route_path'),
          points: [userLatLng, destinationLatLng],
          color: Colors.red.withOpacity(0.7),
          width: 5,
        ),
      );
    }
    
    // If not navigating, show map centered on the user. If navigating, the camera 
    // should continuously track the user, which GoogleMap does automatically via myLocationEnabled.
    final target = userLatLng;

    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: target,
        zoom: 18.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        if (!_controller.isCompleted) {
          _controller.complete(controller);
        }
      },
      markers: markers,
      polylines: polylines,
      myLocationEnabled: false,
      myLocationButtonEnabled: false, // We rely on our own camera updates

      cameraTargetBounds: CameraTargetBounds(vitCampusBounds),
      minMaxZoomPreference: const MinMaxZoomPreference(15.9, 19.0),
      rotateGesturesEnabled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Main Hybrid Logic: Switch to indoor map if conditions are met
    if (_isInsideGdn) {
      return _buildIndoorMap();
    } else {
      return _buildOutdoorMap();
    }
  }
}
//Older code
// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:pathfinder_indoor_navigation/data/campus_paths.dart';
// import 'package:pathfinder_indoor_navigation/models/destination.dart';
// import 'package:pathfinder_indoor_navigation/utils/path_finder.dart';

// final LatLngBounds _campusBounds = LatLngBounds(
//   southwest: const LatLng(12.9650, 79.1530),
//   northeast: const LatLng(12.9770, 79.1650),
// );

// class MapWidget extends StatefulWidget {
//   final Position currentPosition;
//   final Destination? destination;
//   final bool isNavigating;

//   const MapWidget({
//     required this.currentPosition,
//     this.destination,
//     this.isNavigating = false,
//     super.key,
//   });

//   @override
//   MapWidgetState createState() => MapWidgetState();
// }

// class MapWidgetState extends State<MapWidget> {
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();
//   LatLngBounds? _cameraBounds;

//   @override
//   void didUpdateWidget(covariant MapWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.currentPosition != oldWidget.currentPosition ||
//         widget.isNavigating != oldWidget.isNavigating ||
//         widget.destination != oldWidget.destination) {
//       _updateCameraPosition();
//     }
//     if (widget.destination != oldWidget.destination) {
//       _updateCameraBounds();
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _updateCameraBounds();
//   }

//   void _updateCameraPosition() async {
//     final GoogleMapController controller = await _controller.future;
//     final position = widget.currentPosition;
//     final latLng = LatLng(position.latitude, position.longitude);

//     if (widget.isNavigating) {
//       controller.animateCamera(CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: latLng,
//           zoom: 19.5,
//           tilt: 50.0,
//           bearing: position.heading,
//         ),
//       ));
//     } else {
//       if (_cameraBounds != null) {
//         Future.delayed(const Duration(milliseconds: 50), () {
//           controller.animateCamera(
//               CameraUpdate.newLatLngBounds(_cameraBounds!, 60.0));
//         });
//       } else {
//         controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 18.0));
//       }
//     }
//   }

//   void _updateCameraBounds() {
//     if (widget.destination == null) {
//       setState(() {
//         _cameraBounds = null;
//       });
//       return;
//     }

//     final userLoc = widget.currentPosition;
//     final destLoc = widget.destination!.location;
//     double south = min(userLoc.latitude, destLoc.latitude);
//     double west = min(userLoc.longitude, destLoc.longitude);
//     double north = max(userLoc.latitude, destLoc.latitude);
//     double east = max(userLoc.longitude, destLoc.longitude);

//     setState(() {
//       _cameraBounds = LatLngBounds(
//         southwest: LatLng(south, west),
//         northeast: LatLng(north, east),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Set<Polyline> polylines = {};
//     final userLocation =
//         LatLng(widget.currentPosition.latitude, widget.currentPosition.longitude);

//     for (int i = 0; i < campusPaths.length; i++) {
//       polylines.add(Polyline(
//         polylineId: PolylineId('campus_path_$i'),
//         points: campusPaths[i],
//         color: Colors.grey.withAlpha(200),
//         width: 5,
//         startCap: Cap.roundCap,
//         endCap: Cap.roundCap,
//       ));
//     }

//     if (widget.destination != null) {
//       final startPointInfo = findNearestPointOnPaths(userLocation);
//       final endPointInfo =
//           findNearestPointOnPaths(widget.destination!.location);

//       if (startPointInfo != null && endPointInfo != null) {
//         final pathSegment = getPathSegment(startPointInfo, endPointInfo);

//         final fullRoute = [
//           userLocation,
//           ...pathSegment,
//           widget.destination!.location,
//         ];

//         polylines.add(
//           Polyline(
//             polylineId: const PolylineId('snapped_route'),
//             points: fullRoute,
//             color: Colors.lightBlueAccent,
//             width: 7,
//             zIndex: 1,
//             startCap: Cap.roundCap,
//             endCap: Cap.roundCap,
//           ),
//         );
//       }
//     }

//     final Set<Marker> markers = {
//       Marker(
//         markerId: const MarkerId('currentLocation'),
//         position: userLocation,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         infoWindow: const InfoWindow(title: 'Your Location'),
//         anchor: const Offset(0.5, 0.5),
//         flat: true,
//         rotation: widget.currentPosition.heading,
//       ),
//     };

//     if (widget.destination != null) {
//       markers.add(
//         Marker(
//           markerId: const MarkerId('destinationLocation'),
//           position: widget.destination!.location,
//           infoWindow: InfoWindow(title: widget.destination!.name),
//         ),
//       );
//     }

//     return GoogleMap(
//       mapType: MapType.normal,
//       initialCameraPosition: CameraPosition(
//         target: userLocation,
//         zoom: 18.0,
//       ),
//       cameraTargetBounds: CameraTargetBounds(_campusBounds),
//       minMaxZoomPreference: const MinMaxZoomPreference(16.0, 21.0),
//       onMapCreated: (GoogleMapController controller) {
//         if (!_controller.isCompleted) {
//           _controller.complete(controller);
//           _updateCameraPosition();
//         }
//       },
//       markers: markers,
//       polylines: polylines,
//       myLocationButtonEnabled: !widget.isNavigating,
//       myLocationEnabled: false,
//       zoomControlsEnabled: !widget.isNavigating,
//       compassEnabled: false,
//       tiltGesturesEnabled: !widget.isNavigating,
//       rotateGesturesEnabled: !widget.isNavigating,
//       scrollGesturesEnabled: !widget.isNavigating,
//     );
//   }
// }