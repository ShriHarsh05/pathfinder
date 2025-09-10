import 'package:google_maps_flutter/google_maps_flutter.dart';

class Destination {
  final String name;
  final LatLng location;

  Destination({required this.name, required this.location});
}

// Expanded list of destinations for VIT Vellore
final List<Destination> destinations = [
  // Academic Buildings
  Destination(name: 'Main Building (MB)', location: const LatLng(12.9696, 79.1558)),
  Destination(name: 'Technology Tower (TT)', location: const LatLng(12.970903,79.159461)),
  Destination(name: 'Silver Jubilee Tower (SJT)', location: const LatLng(12.97128085,79.16352452)),
  Destination(name: 'G.D. Naidu Block', location: const LatLng(12.9697, 79.1547)),
  Destination(name: 'Dr. M.G.R. Block', location: const LatLng(12.96880124,79.15588792)),
  Destination(name: 'Peal Research Park (PRP)', location: const LatLng(12.97128259,79.16635968)),
  
  // Library & Auditoriums
  Destination(name: 'Periyar Central Library', location: const LatLng(12.96907830,79.15681051)),
  Destination(name: 'Anna Auditorium', location: const LatLng(12.9698135, 79.1556754)),
  Destination(name: 'Channa Reddy Auditorium', location: const LatLng(12.934968, 79.146881)),

  // --- Men's Hostels ---
  Destination(name: 'Mens Hostel - A Block', location: const LatLng(12.97286304,79.15712022)),
  Destination(name: 'Mens Hostel - B Block', location: const LatLng(12.97440341,79.15740835)),
  Destination(name: 'Mens Hostel - C Block', location: const LatLng(12.97280554,79.15803278)),
  Destination(name: 'Mens Hostel - D Block', location: const LatLng(12.97279334,79.15879682)),
  Destination(name: 'Mens Hostel - E Block', location: const LatLng(12.97270099,79.15976842)),
  Destination(name: 'Mens Hostel - F Block', location: const LatLng(12.97377088,79.15829943)),
  Destination(name: 'Mens Hostel - G Block', location: const LatLng(12.97359489,79.15961440)),
  Destination(name: 'Mens Hostel - H Block', location: const LatLng(12.97207369,79.15738324)),
  Destination(name: 'Mens Hostel - J Block', location: const LatLng(12.97205452,79.15808108)),
  Destination(name: 'Mens Hostel - K Block', location: const LatLng(12.97256682,79.16131313)),
  Destination(name: 'Mens Hostel - L Block', location: const LatLng(12.97274630,79.16263364)),
  Destination(name: 'Mens Hostel - M Block', location: const LatLng(12.97289789,79.16376275)),
  Destination(name: 'Mens Hostel - N Block', location: const LatLng(12.97503942,79.16364997)),
  Destination(name: 'Mens Hostel - P Block', location: const LatLng(12.97361057,79.16422077)),
  Destination(name: 'Mens Hostel - Q Block', location: const LatLng(12.97386672,79.16396764)),
  Destination(name: 'Mens Hostel - R Block', location: const LatLng(12.97328298,79.16353009)),

  // --- Ladies Hostels ---
  Destination(name: 'Ladies Hostel - A Block', location: const LatLng(12.968389,79.157949)),
  Destination(name: 'Ladies Hostel - B Block', location: const LatLng(12.968389,79.157949)),
  Destination(name: 'Ladies Hostel - C Block', location: const LatLng(12.971261,79.160803)),
  Destination(name: 'Ladies Hostel - D Block', location: const LatLng(12.971271,79.161085)),
  Destination(name: 'Ladies Hostel - E Block', location: const LatLng(12.971256,79.162022)),
  Destination(name: 'Ladies Hostel - F Block', location: const LatLng(12.970973,79.162732)),
  Destination(name: 'Ladies Hostel - G Block', location: const LatLng(12.968217,79.159712)),
  Destination(name: 'Ladies Hostel - H Block', location: const LatLng(12.968217,79.159712)),
  Destination(name: 'Ladies Hostel - J Block', location: const LatLng(12.968193,79.159526)),

  
  // Food & Canteens
  Destination(name: 'Foodys Canteen', location: const LatLng(12.9704, 79.1578)),
  Destination(name: 'SJT Canteen', location: const LatLng(12.9710, 79.1583)),
  Destination(name: 'Food Court', location: const LatLng(12.9725, 79.1600)),
  
  // Sports & Other
  Destination(name: 'Indoor Sports Complex', location: const LatLng(12.9728, 79.1584)),
  Destination(name: 'Main Gate', location: const LatLng(12.9687, 79.1543)),
  Destination(name: 'Guest House', location: const LatLng(12.9705, 79.1545)),
  Destination(name: 'Health Centre', location: const LatLng(12.9681, 79.1558)),
  Destination(name: 'Post Office', location: const LatLng(12.9690, 79.1553)),
  Destination(name: 'Swimming Pool', location: const LatLng(12.9731, 79.1579)),
];

