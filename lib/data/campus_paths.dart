import 'package:google_maps_flutter/google_maps_flutter.dart';

// A rebuilt and more accurate path network based on user-provided destination coordinates.
final List<List<LatLng>> campusPaths = [
  // =======================================================================
  // SECTION 1: CORE ACADEMIC & CENTRAL ROUTES
  // =======================================================================

  // Path A: Main Gate to Central Academic Plaza and towards TT
  // This is the primary East-West corridor of the academic area.
  [
    const LatLng(12.9687, 79.1543),   // Main Gate
    const LatLng(12.9697, 79.1547),   // G.D. Naidu Block
    const LatLng(12.9698, 79.1556),   // Anna Auditorium
    const LatLng(12.9688, 79.1558),   // Dr. M.G.R. Block
    const LatLng(12.9696, 79.1558),   // Main Building (MB)
    const LatLng(12.9690, 79.1568),   // Periyar Central Library
    const LatLng(12.9709, 79.1594),   // Technology Tower (TT) - Key Junction
  ],

  // =======================================================================
  // SECTION 2: HOSTEL ROUTES
  // =======================================================================

  // Path B: Main road connecting TT to the first group of Men's Hostels
  [
    const LatLng(12.9709, 79.1594),   // Technology Tower (TT)
    const LatLng(12.9720, 79.1573),   // Mens Hostel - H Block
    const LatLng(12.9720, 79.1580),   // Mens Hostel - J Block
    const LatLng(12.9728, 79.1580),   // Mens Hostel - C Block
    const LatLng(12.9727, 79.1587),   // Mens Hostel - D Block
    const LatLng(12.9727, 79.1597),   // Mens Hostel - E Block
  ],

  // Path C: Path connecting the second group of Men's Hostels
  [
    const LatLng(12.9728, 79.1571),   // Mens Hostel - A Block
    const LatLng(12.9737, 79.1582),   // Mens Hostel - F Block
    const LatLng(12.9744, 79.1574),   // Mens Hostel - B Block
  ],

  // Path D: Main road from TT towards Ladies' Hostels, SJT, and PRP
  [
    const LatLng(12.9709, 79.1594),   // Technology Tower (TT)
    const LatLng(12.9712, 79.1608),   // Ladies Hostel - C Block
    const LatLng(12.9712, 79.1610),   // Ladies Hostel - D Block
    const LatLng(12.9712, 79.1620),   // Ladies Hostel - E Block
    const LatLng(12.9709, 79.1627),   // Ladies Hostel - F Block
    const LatLng(12.9712, 79.1635),   // Silver Jubilee Tower (SJT)
    const LatLng(12.9712, 79.1663),   // Pearl Research Park (PRP)
  ],

  // Path E: Connects the farthest group of Men's Hostels
  [
    const LatLng(12.9725, 79.1613),   // Mens Hostel - K Block
    const LatLng(12.9727, 79.1626),   // Mens Hostel - L Block
    const LatLng(12.9728, 79.1637),   // Mens Hostel - M Block
    const LatLng(12.9732, 79.1635),   // Mens Hostel - R Block
    const LatLng(12.9738, 79.1639),   // Mens Hostel - Q Block
    const LatLng(12.9736, 79.1642),   // Mens Hostel - P Block
    const LatLng(12.9750, 79.1636),   // Mens Hostel - N Block
  ],

  // Path F: Connects the south-side Ladies' Hostels
  [
    const LatLng(12.9683, 79.1579),   // Ladies Hostel - A/B Block Area
    const LatLng(12.9682, 79.1597),   // Ladies Hostel - G/H Block Area
    const LatLng(12.9681, 79.1595),   // Ladies Hostel - J Block
  ],
];

