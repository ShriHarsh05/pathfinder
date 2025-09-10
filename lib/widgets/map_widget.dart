import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pathfinder_indoor_navigation/data/campus_paths.dart';
import 'package:pathfinder_indoor_navigation/models/destination.dart';

// Defines the rectangular boundary for the VIT Vellore campus
final LatLngBounds _campusBounds = LatLngBounds(
  southwest: const LatLng(12.9650, 79.1530), // Lower-left corner of VIT Vellore
  northeast: const LatLng(12.9770, 79.1650), // Upper-right corner of VIT Vellore
);

class MapWidget extends StatefulWidget {
  final Position currentPosition;
  final Destination? destination;
  final bool isNavigating;

  const MapWidget({
    required this.currentPosition,
    this.destination,
    this.isNavigating = false,
    super.key,
  });

  @override
  MapWidgetState createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  LatLngBounds? _cameraBounds;

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPosition != oldWidget.currentPosition ||
        widget.isNavigating != oldWidget.isNavigating ||
        widget.destination != oldWidget.destination) {
      _updateCameraPosition();
    }
    if (widget.destination != oldWidget.destination) {
      _updateCameraBounds();
    }
  }

  @override
  void initState() {
    super.initState();
    _updateCameraBounds();
  }

  void _updateCameraPosition() async {
    final GoogleMapController controller = await _controller.future;
    final position = widget.currentPosition;
    final latLng = LatLng(position.latitude, position.longitude);

    if (widget.isNavigating) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLng,
          zoom: 19.5,
          tilt: 50.0,
          bearing: position.heading,
        ),
      ));
    } else {
      if (_cameraBounds != null) {
        Future.delayed(const Duration(milliseconds: 50), () {
          controller.animateCamera(
              CameraUpdate.newLatLngBounds(_cameraBounds!, 60.0));
        });
      } else {
        controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 18.0));
      }
    }
  }

  void _updateCameraBounds() {
    if (widget.destination == null) {
      setState(() {
        _cameraBounds = null;
      });
      return;
    }

    final userLoc = widget.currentPosition;
    final destLoc = widget.destination!.location;
    double south = min(userLoc.latitude, destLoc.latitude);
    double west = min(userLoc.longitude, destLoc.longitude);
    double north = max(userLoc.latitude, destLoc.latitude);
    double east = max(userLoc.longitude, destLoc.longitude);

    setState(() {
      _cameraBounds = LatLngBounds(
        southwest: LatLng(south, west),
        northeast: LatLng(north, east),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Set<Polyline> polylines = {};
    final userLocation =
        LatLng(widget.currentPosition.latitude, widget.currentPosition.longitude);

    // 1. Draw all predefined campus paths in grey to show all possible walkways
    for (int i = 0; i < campusPaths.length; i++) {
      polylines.add(Polyline(
        polylineId: PolylineId('campus_path_$i'),
        points: campusPaths[i],
        color: Colors.grey.withAlpha(200),
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ));
    }

    // 2. If a destination is selected, draw a simple, straight "compass" line.
    if (widget.destination != null) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('compass_line'),
          points: [userLocation, widget.destination!.location],
          color: Colors.lightBlueAccent,
          width: 7,
          zIndex: 1, // Draw this line on top of the grey paths
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
        anchor: const Offset(0.5, 0.5),
        flat: true,
        rotation: widget.currentPosition.heading,
      ),
    };

    if (widget.destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destinationLocation'),
          position: widget.destination!.location,
          infoWindow: InfoWindow(title: widget.destination!.name),
        ),
      );
    }

    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: userLocation,
        zoom: 18.0,
      ),
      cameraTargetBounds: CameraTargetBounds(_campusBounds),
      minMaxZoomPreference: const MinMaxZoomPreference(16.0, 21.0),
      onMapCreated: (GoogleMapController controller) {
        if (!_controller.isCompleted) {
          _controller.complete(controller);
          _updateCameraPosition();
        }
      },
      markers: markers,
      polylines: polylines,
      myLocationButtonEnabled: !widget.isNavigating,
      myLocationEnabled: false,
      zoomControlsEnabled: !widget.isNavigating,
      compassEnabled: false,
      tiltGesturesEnabled: !widget.isNavigating,
      rotateGesturesEnabled: !widget.isNavigating,
      scrollGesturesEnabled: !widget.isNavigating,
    );
  }
}

