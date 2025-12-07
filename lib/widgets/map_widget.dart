import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pathfinder_indoor_navigation/models/destination.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // Make sure you have http package
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // Make sure you have this

// IMPORTANT: Paste your Google Maps API Key here
const String GOOGLE_MAPS_API_KEY = "YATyaZfrXQscfRjZBmESic2Cw";

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
  List<LatLng> _polylineCoordinates = [];
  final PolylinePoints _polylinePoints = PolylinePoints();

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

    final LatLng userLatLng = LatLng(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
    );
    
    final LatLng destinationLatLng = widget.destination!.location;

    // This is the "L-Path" workaround, which is great
    // because it doesn't need an API key.
    final LatLng cornerPoint = LatLng(userLatLng.latitude, destinationLatLng.longitude);
    
    _polylineCoordinates = [
      userLatLng,       // Start
      cornerPoint,      // The "corner"
      destinationLatLng // End
    ];

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route_path'),
          points: _polylineCoordinates,
          color: Colors.lightBlueAccent,
          width: 6,
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
      
      // --- THE FIX ---
      // Set myLocationEnabled to true to show the default blue dot.
      myLocationEnabled: true, 
      // Set myLocationButtonEnabled to true so the user can re-center.
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