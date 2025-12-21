import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pathfinder_indoor_navigation/models/destination.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // Make sure you have http package
import 'dart:convert';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // Make sure you have this

// IMPORTANT: Paste your Google Maps API Key here
const String GOOGLE_MAPS_API_KEY = "YATyaZfrXQscfRjZBmESic2Cw";
const String ORS_API_KEY = "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjEyYWZhZjA1NWFkZjQ1MjQ5NjM3ZDRhMTQ2ZjAxNjJmIiwiaCI6Im11cm11cjY0In0=";

final LatLngBounds vitCampusBounds = LatLngBounds(
  southwest: const LatLng(12.9680, 79.1540),
  northeast: const LatLng(12.9755, 79.1665),
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
  // --- REMOVED Custom Icon Variable ---

  final Set<Polyline> _polylines = {};
  // List<LatLng> _polylineCoordinates = [];
  // final PolylinePoints _polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    // --- REMOVED Call to _loadCustomMarker() ---
    _getPolyline(); // Get path on initial load
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isNavigating && widget.currentPosition != oldWidget.currentPosition) {
      _animateCameraToUser();
    }

    if (widget.destination != oldWidget.destination) {
      _getPolyline(); // Recalculate path if destination changes
    }
  }

  Future<void> _animateCameraToUser() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(widget.currentPosition.latitude, widget.currentPosition.longitude),
          zoom: 18.0,
          bearing: widget.currentPosition.heading, 
          tilt: 45.0,
        ),
      ),
    );
  }

  // --- REMOVED _loadCustomMarker() function ---

  Future<void> _getPolyline() async {
    if (widget.destination == null) {
      setState(() {
        _polylines.clear();
      });
      return;
    }
    final startLat = widget.currentPosition.latitude;
    final startLng = widget.currentPosition.longitude;
    final endLat = widget.destination!.location.latitude;
    final endLng = widget.destination!.location.longitude;
    final String url =
        'https://api.openrouteservice.org/v2/directions/foot-walking?api_key=$ORS_API_KEY&start=$startLng,$startLat&end=$endLng,$endLat';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Parse the coordinates from the GeoJSON response
        // Structure: features[0] -> geometry -> coordinates (List of [lng, lat])
        final List<dynamic> coords = data['features'][0]['geometry']['coordinates'];
        
        // Convert to Google Maps LatLng (Note: ORS sends [lng, lat], Google wants [lat, lng])
        final List<LatLng> polylineCoordinates = coords
            .map((c) => LatLng(c[1], c[0]))
            .toList();

        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route_path'),
              points: polylineCoordinates,
              color: Colors.blue, // Nice navigation blue
              width: 6,
              jointType: JointType.round,
            ),
          );
        });
      } else {
        print("ORS Error: ${response.body}");
        _drawFallbackPath(); // If API fails, use the L-shape fallback
      }
    } catch (e) {
      print("Error fetching route: $e");
      _drawFallbackPath(); // If network error, use fallback
    }
  }
    void _drawFallbackPath() {
    if (widget.destination == null) return;
    final userLatLng = LatLng(widget.currentPosition.latitude, widget.currentPosition.longitude);
    final destLatLng = widget.destination!.location;
    final cornerPoint = LatLng(userLatLng.latitude, destLatLng.longitude);

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('fallback_path'),
          points: [userLatLng, cornerPoint, destLatLng],
          color: Colors.lightBlueAccent, // Lighter color for fallback
          width: 5,
          patterns: [PatternItem.dash(10), PatternItem.gap(10)], // Dashed to indicate "approximate"
        ),
      );
    });
  }
  Widget _buildOutdoorMap() {
    final userLatLng = LatLng(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
    );
    
    final LatLng destinationLatLng = widget.destination?.location ?? userLatLng;
    
    // --- MODIFIED: Removed the custom 'currentLocation' marker ---
    final Set<Marker> markers = {};

    if (widget.destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('toLocation'),
          position: destinationLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: widget.destination!.name),
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
      polylines: _polylines, 
      myLocationEnabled: true, 
      myLocationButtonEnabled: true, 
      cameraTargetBounds: CameraTargetBounds(vitCampusBounds),
      minMaxZoomPreference: const MinMaxZoomPreference(15.9, 19.0),
      rotateGesturesEnabled: false,
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

    return _buildOutdoorMap();
  }
}