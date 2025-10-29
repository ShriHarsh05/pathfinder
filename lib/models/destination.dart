import 'package:google_maps_flutter/google_maps_flutter.dart';

// --- NEW PROPERTIES ADDED ---
class Destination {
  final String id;
  final String name;
  final LatLng location;
  final String building; // New field for building name
  final bool isIndoor; // New field to check if destination is indoors

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.building,
    required this.isIndoor,
  });
}

// GDN Building's known approximate coordinate for proximity check
const LatLng gdnBuildingCoord = LatLng(12.9697, 79.1547); 

// Expanded list of destinations for VIT Vellore
final List<Destination> destinations = [
  // Academic Buildings
  Destination(id: 'mb', name: 'Main Building (MB)', location: const LatLng(12.9696, 79.1558), building: 'MB', isIndoor: false),
  Destination(id: 'tt', name: 'Technology Tower (TT)', location: const LatLng(12.970903,79.159461), building: 'TT', isIndoor: false),
  Destination(id: 'sjt', name: 'Silver Jubilee Tower (SJT)', location: const LatLng(12.97128085,79.16352452), building: 'SJT', isIndoor: false),
  
  // --- GDN BLOCK DESTINATIONS ---
  // The 'location' is set to the building entrance coordinate (gdnBuildingCoord) 
  // because the outdoor map only needs to navigate to the entrance.
  Destination(id: 'gdn_entrance', name: 'G.D. Naidu Block', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  Destination(id: 'gdn_g07', name: 'GDN - G07 Survey Lab', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true), // Indoor location
  Destination(id: 'gdn_g08a', name: 'GDN - G08A Classroom', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true), // Indoor location
  
  Destination(id: 'mgr', name: 'Dr. M.G.R. Block', location: const LatLng(12.96880124,79.15588792), building: 'MGR', isIndoor: false),
  Destination(id: 'prp', name: 'Peal Research Park (PRP)', location: const LatLng(12.97128259,79.16635968), building: 'PRP', isIndoor: false),
  Destination(id: 'prp_side', name: 'PRP Side Entrance', location: const LatLng(12.97175, 79.16549), building: 'PRP', isIndoor: false),

  // Library & Auditoriums
  Destination(id: 'library', name: 'Periyar Central Library', location: const LatLng(12.96907830,79.15681051), building: 'Library', isIndoor: false),
  Destination(id: 'anna_aud', name: 'Anna Auditorium', location: const LatLng(12.9698135, 79.1556754), building: 'Anna Aud', isIndoor: false),
  Destination(id: 'channa_aud', name: 'Channa Reddy Auditorium', location: const LatLng(12.934968, 79.146881), building: 'Channa Aud', isIndoor: false),

  // --- Hostels (simplified with placeholder building names) ---
  Destination(id: 'mha', name: 'Mens Hostel - A Block', location: const LatLng(12.97286304,79.15712022), building: 'MHA', isIndoor: false),
  Destination(id: 'mhb', name: 'Mens Hostel - B Block', location: const LatLng(12.97440341,79.15740835), building: 'MHB', isIndoor: false),
  Destination(id: 'mhc', name: 'Mens Hostel - C Block', location: const LatLng(12.97280554,79.15803278), building: 'MHC', isIndoor: false),
  Destination(id: 'mhd', name: 'Mens Hostel - D Block', location: const LatLng(12.97279334,79.15879682), building: 'MHD', isIndoor: false),
  Destination(id: 'mhe', name: 'Mens Hostel - E Block', location: const LatLng(12.97270099,79.15976842), building: 'MHE', isIndoor: false),
  Destination(id: 'mhf', name: 'Mens Hostel - F Block', location: const LatLng(12.97377088,79.15829943), building: 'MHF', isIndoor: false),
  Destination(id: 'mhg', name: 'Mens Hostel - G Block', location: const LatLng(12.97359489,79.15961440), building: 'MHG', isIndoor: false),
  Destination(id: 'mhh', name: 'Mens Hostel - H Block', location: const LatLng(12.97207369,79.15738324), building: 'MHH', isIndoor: false),
  Destination(id: 'mhj', name: 'Mens Hostel - J Block', location: const LatLng(12.97205452,79.15808108), building: 'MHJ', isIndoor: false),
  Destination(id: 'mhk', name: 'Mens Hostel - K Block', location: const LatLng(12.97256682,79.16131313), building: 'MHK', isIndoor: false),
  Destination(id: 'mhl', name: 'Mens Hostel - L Block', location: const LatLng(12.97274630,79.16263364), building: 'MHL', isIndoor: false),
  Destination(id: 'mhm', name: 'Mens Hostel - M Block', location: const LatLng(12.97289789,79.16376275), building: 'MHM', isIndoor: false),
  Destination(id: 'mhn', name: 'Mens Hostel - N Block', location: const LatLng(12.97503942,79.16364997), building: 'MHN', isIndoor: false),
  Destination(id: 'mhp', name: 'Mens Hostel - P Block', location: const LatLng(12.97361057,79.16422077), building: 'MHP', isIndoor: false),
  Destination(id: 'mhq', name: 'Mens Hostel - Q Block', location: const LatLng(12.97386672,79.16396764), building: 'MHQ', isIndoor: false),
  Destination(id: 'mhr', name: 'Mens Hostel - R Block', location: const LatLng(12.97328298,79.16353009), building: 'MHR', isIndoor: false),

  // --- Ladies Hostels ---
  Destination(id: 'lha', name: 'Ladies Hostel - A Block', location: const LatLng(12.968389,79.157949), building: 'LHA', isIndoor: false),
  Destination(id: 'lhb', name: 'Ladies Hostel - B Block', location: const LatLng(12.968389,79.157949), building: 'LHB', isIndoor: false),
  Destination(id: 'lhc', name: 'Ladies Hostel - C Block', location: const LatLng(12.971261,79.160803), building: 'LHC', isIndoor: false),
  Destination(id: 'lhd', name: 'Ladies Hostel - D Block', location: const LatLng(12.971271,79.161085), building: 'LHD', isIndoor: false),
  Destination(id: 'lhe', name: 'Ladies Hostel - E Block', location: const LatLng(12.971256,79.162022), building: 'LHE', isIndoor: false),
  Destination(id: 'lhf', name: 'Ladies Hostel - F Block', location: const LatLng(12.970973,79.162732), building: 'LHF', isIndoor: false),
  Destination(id: 'lhg', name: 'Ladies Hostel - G Block', location: const LatLng(12.968217,79.159712), building: 'LHG', isIndoor: false),
  Destination(id: 'lhh', name: 'Ladies Hostel - H Block', location: const LatLng(12.968217,79.159712), building: 'LHH', isIndoor: false),
  Destination(id: 'lhj', name: 'Ladies Hostel - J Block', location: const LatLng(12.968193,79.159526), building: 'LHJ', isIndoor: false),

  // Food & Canteens
  Destination(id: 'foodys', name: 'Foodys Canteen', location: const LatLng(12.9704, 79.1578), building: 'Foodys', isIndoor: false),
  Destination(id: 'sjt_can', name: 'SJT Canteen', location: const LatLng(12.9710, 79.1583), building: 'SJT Canteen', isIndoor: false),
  Destination(id: 'food_court', name: 'Food Court', location: const LatLng(12.9725, 79.1600), building: 'Food Court', isIndoor: false),

  // Sports & Other
  Destination(id: 'sports', name: 'Indoor Sports Complex', location: const LatLng(12.9728, 79.1584), building: 'ISC', isIndoor: false),
  Destination(id: 'maingate', name: 'Main Gate', location: const LatLng(12.9687, 79.1543), building: 'Gate', isIndoor: false),
  Destination(id: 'guest', name: 'Guest House', location: const LatLng(12.9705, 79.1545), building: 'Guest', isIndoor: false),
  Destination(id: 'health', name: 'Health Centre', location: const LatLng(12.9681, 79.1558), building: 'Health', isIndoor: false),
  Destination(id: 'post', name: 'Post Office', location: const LatLng(12.9690, 79.1553), building: 'Post', isIndoor: false),
  Destination(id: 'pool', name: 'Swimming Pool', location: const LatLng(12.9731, 79.1579), building: 'Pool', isIndoor: false),
];
