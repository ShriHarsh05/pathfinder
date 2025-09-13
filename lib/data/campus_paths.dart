import 'package:google_maps_flutter/google_maps_flutter.dart';

// The path network for the VIT Vellore campus.
// This file should ONLY contain high-accuracy paths recorded via GPS to ensure accuracy.
final List<List<LatLng>> campusPaths = [

  // --- High-accuracy recorded path from J Block to PRP Side Entrance ---
  // This is the primary "highway" that connects TT, SJT, and PRP.
  [
    const LatLng(12.97197, 79.15824), // Start near J Block
    const LatLng(12.97162, 79.15818), // Path Turn 1
    const LatLng(12.97104, 79.15864), // Path Turn 2
    const LatLng(12.97103, 79.15918), // Path Turn 3 (Near Technology Tower)
    const LatLng(12.97105, 79.15954), // Mid-point
    const LatLng(12.97117, 79.16005), // Path continues
    const LatLng(12.97126, 79.16048), // Path continues
    const LatLng(12.97130, 79.16087), // Path Turn 4
    const LatLng(12.97120, 79.16350), // Near Silver Jubilee Tower (SJT)
    const LatLng(12.97138, 79.16131), // Path continues
    const LatLng(12.97144, 79.16191), // Path Turn 5
    const LatLng(12.97148, 79.16233), // Path continues
    const LatLng(12.97162, 79.16276), // Path Turn 6
    const LatLng(12.97165, 79.16336), // Path continues
    const LatLng(12.97178, 79.16390), // Path continues
    const LatLng(12.97175, 79.16549), // Near PRP Side Entrance
    const LatLng(12.97128, 79.16635), // Pearl Research Park (PRP)
  ],
  
  // You can add more high-accuracy recorded paths here in the future.
  // The logic will work best if they connect to this main path at a junction.
];