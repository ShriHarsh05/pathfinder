import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pathfinder_indoor_navigation/models/destination.dart';
import 'package:flutter/services.dart';

// These bounds are for the outdoor map
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
  // REMOVED: We will use the default blue pin instead of a custom icon
  // BitmapDescriptor _currentLocationIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    // REMOVED: No longer need to load a custom marker
    // _loadCustomMarker();
    // No longer check for indoor status here
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // No longer check for indoor status here

    // --- NEW: Animate camera if navigating ---
    if (widget.isNavigating && widget.currentPosition != oldWidget.currentPosition) {
      _animateCameraToUser();
    }
  }

  // --- NEW: Function to animate camera ---
  Future<void> _animateCameraToUser() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(widget.currentPosition.latitude, widget.currentPosition.longitude),
          zoom: 18.0,
          bearing: widget.currentPosition.heading, // Point camera in direction of travel
          tilt: 45.0, // Angle the camera
        ),
      ),
    );
  }

  // REMOVED: This function is no longer needed
  /*
  Future<void> _loadCustomMarker() async {
    try {
      final icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, 
        'assets/icons/location_dot.png', // Make sure this file exists!
      );
      if (mounted) {
        setState(() {
          _currentLocationIcon = icon;
        });
      }
    } catch (e) {
      print("Error loading custom marker: $e");
    }
  }
  */

  // --- Map Display Function ---
  // This widget ONLY builds the outdoor map now
  Widget _buildOutdoorMap() {
    final userLatLng = LatLng(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
    );
    
    final LatLng destinationLatLng = widget.destination?.location ?? userLatLng;
    
    final Set<Marker> markers = {
      // User's Current Location Marker
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: userLatLng,
        // --- FIX: Using the default blue pin ---
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), 
        infoWindow: const InfoWindow(title: 'You Are Here'),
        // --- NEW: Make marker flat and rotate with compass ---
        flat: true,
        rotation: widget.currentPosition.heading,
        anchor: const Offset(0.5, 0.5), // Center the icon
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
      myLocationEnabled: false, // Explicitly false to hide the blue dot
      myLocationButtonEnabled: false, 
      cameraTargetBounds: CameraTargetBounds(vitCampusBounds),
      minMaxZoomPreference: const MinMaxZoomPreference(15.9, 19.0),
      rotateGesturesEnabled: false,
      // --- NEW: Control gestures based on navigation ---
      
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // This widget now *only* builds the outdoor map.
    // The logic to switch to indoor is in HomeScreen.
    return _buildOutdoorMap();
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