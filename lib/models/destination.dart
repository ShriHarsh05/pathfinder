import 'package:google_maps_flutter/google_maps_flutter.dart';

class Destination {
  final String id;
  final String name;
  final LatLng location;
  final String building; 
  final bool isIndoor; 

  const Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.building,
    required this.isIndoor,
  });
}

// GDN Building's known approximate coordinate for proximity check
const LatLng gdnBuildingCoord = LatLng(12.9697, 79.1547); 

final List<Destination> destinations = [
  // --- 1. The Single Outdoor Handoff Point ---
  // The user will never select this. The app uses it as the
  // GPS target when an indoor room is selected.
  const Destination(
    id: 'gdn_entrance_target', 
    name: 'GDN Entrance', 
    location: gdnBuildingCoord, 
    building: 'GDN Block', 
    isIndoor: false // This is 'false' so the outdoor map can navigate to it
  ),

  // --- 2. All INDOOR Rooms (from your map_annotator.py) ---
  // These are the destinations the user will see and select.
  // All have 'isIndoor: true' to trigger the handoff.
  const Destination(id: 'gdn_room_0', name: 'Entrance', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_7', name: 'G01', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_18', name: 'G02', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_35', name: 'G03', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_78', name: 'G05', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_72', name: 'G06', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_63', name: 'G07', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_53', name: 'G08', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_64', name: 'G08 BACK-GATE', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_123', name: 'G09A', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_100', name: 'G10', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_116', name: 'G10A', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_131', name: 'G11', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_90', name: 'G14', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_40', name: 'G16', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_166', name: 'G17', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_161', name: 'G18', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_143', name: 'G19', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_152', name: 'G19A', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_136', name: 'G19B', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),
  const Destination(id: 'gdn_room_76', name: 'Cylinder Room', location: gdnBuildingCoord, building: 'GDN Block', isIndoor: true),

  // --- 3. OTHER OUTDOOR DESTINATIONS ---
  // These will work as normal.
  const Destination(id: 'mb', name: 'Main Building (MB)', location: LatLng(12.9696, 79.1558), building: 'MB', isIndoor: false),
  const Destination(id: 'sjt', name: 'Silver Jubilee Tower (SJT)', location: LatLng(12.97128085,79.16352452), building: 'SJT', isIndoor: false),
  Destination(id: 'mgr', name: 'Dr. M.G.R. Block', location: const LatLng(12.96880124,79.15588792), building: 'MGR', isIndoor: false),
  Destination(id: 'prp', name: 'Peal Research Park (PRP)', location: const LatLng(12.97128259,79.16635968), building: 'PRP', isIndoor: false),
  Destination(id: 'prp_side', name: 'PRP Side Entrance', location: const LatLng(12.97175, 79.16549), building: 'PRP', isIndoor: false),
  Destination(id: 'library', name: 'Periyar Central Library', location: const LatLng(12.96907830,79.15681051), building: 'Library', isIndoor: false),
  Destination(id: 'anna_aud', name: 'Anna Auditorium', location: const LatLng(12.9698135, 79.1556754), building: 'Anna Aud', isIndoor: false),
  Destination(id: 'channa_aud', name: 'Channa Reddy Auditorium', location: const LatLng(12.934968, 79.146881), building: 'Channa Aud', isIndoor: false),
  Destination(id: 'foodys', name: 'Foodys Canteen', location: const LatLng(12.9704, 79.1578), building: 'Foodys', isIndoor: false),
  Destination(id: 'sjt_can', name: 'SJT Canteen', location: const LatLng(12.9710, 79.1583), building: 'SJT Canteen', isIndoor: false),
  Destination(id: 'food_court', name: 'Food Court', location: const LatLng(12.9725, 79.1600), building: 'Food Court', isIndoor: false),
  Destination(id: 'sports', name: 'Indoor Sports Complex', location: const LatLng(12.9728, 79.1584), building: 'ISC', isIndoor: false),
  Destination(id: 'maingate', name: 'Main Gate', location: const LatLng(12.9687, 79.1543), building: 'Gate', isIndoor: false),
  Destination(id: 'guest', name: 'Guest House', location: const LatLng(12.9705, 79.1545), building: 'Guest', isIndoor: false),
  Destination(id: 'health', name: 'Health Centre', location: const LatLng(12.9681, 79.1558), building: 'Health', isIndoor: false),
  Destination(id: 'post', name: 'Post Office', location: const LatLng(12.9690, 79.1553), building: 'Post', isIndoor: false),
  Destination(id: 'pool', name: 'Swimming Pool', location: const LatLng(12.9731, 79.1579), building: 'Pool', isIndoor: false),
];