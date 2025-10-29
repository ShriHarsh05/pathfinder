import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:pathfinder_indoor_navigation/models/destination.dart';
import 'package:pathfinder_indoor_navigation/widgets/map_widget.dart';
// import 'package:pathfinder_indoor_navigation/widgets/ar_navigation_view.dart';
import 'package:searchfield/searchfield.dart';
import 'ar_navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  // HomeScreen now requires the list of cameras from main.dart
  final List<CameraDescription> cameras;

  const HomeScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  Destination? _selectedDestination;
  StreamSubscription<Position>? _positionStreamSubscription;
  final _searchController = TextEditingController();
  bool _isNavigating = false; // This bool is for 2D Map navigation

  // REMOVED: The destinations list is now imported from models/destination.dart

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorDialog('Location services are disabled. Please enable them.');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorDialog('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorDialog(
            'Location permissions are permanently denied. We cannot request permissions.');
        return;
      }

      final initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      if (mounted) {
        setState(() {
          _currentPosition = initialPosition;
        });
      }

      _startLocationStream();
    } catch (e) {
      print("Error initializing location: $e");
      _showErrorDialog("Could not get initial location. Please try again.");
    }
  }

  void _startLocationStream() {
    // ... (Your existing _startLocationStream logic remains unchanged)
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
  }

  void _showErrorDialog(String message) {
    // ... (Your existing _showErrorDialog logic remains unchanged)
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // This function is for your 2D MAP navigation
  void _toggleMapNavigation() {
    setState(() {
      _isNavigating = !_isNavigating;
    });
  }

  // This function is for the AR navigation
  void _startARNavigation() {
    if (_selectedDestination == null) return;

    if (widget.cameras.isEmpty) {
      _showErrorDialog(
          'No camera found on this device. Cannot start AR navigation.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ARNavigationScreen(
          destination: _selectedDestination!,
          camera: widget.cameras.first,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pathfinder Navigation'),
        centerTitle: true,
        automaticallyImplyLeading: !_isNavigating,
        leading: _isNavigating
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleMapNavigation,
              )
            : null,
      ),
      body: Stack(
        children: [
          if (_currentPosition == null)
            const Center(child: CircularProgressIndicator())
          else
            _isNavigating ? _buildNavigationView() : _buildSelectionView(),

          if (_isNavigating) _buildStopNavigationButton(),
        ],
      ),
    );
  }

  Widget _buildSelectionView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              _buildDestinationSelector(),
              const SizedBox(height: 20),
              Expanded(
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MapWidget(
                    currentPosition: _currentPosition!,
                    destination: _selectedDestination,
                    isNavigating: false,
                  ),
                ),
              ),
              const SizedBox(height: 90), // Space for the button(s)
            ],
          ),

          if (_selectedDestination != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              // UPDATED: This now uses the smart button builder
              child: _buildNavigationButtons(),
            ),
        ],
      ),
    );
  }

  // This is your original 2D Map Navigation View
  Widget _buildNavigationView() {
    return MapWidget(
      currentPosition: _currentPosition!,
      destination: _selectedDestination,
      isNavigating: true,
    );
  }

  // ** NEW SMARTER WIDGET **
  // This widget now intelligently decides which button(s) to show
  // based on the `isIndoor` flag from your new Destination model.
  Widget _buildNavigationButtons() {
    if (_selectedDestination == null) {
      return const SizedBox.shrink(); // Don't show anything
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // --- CONDITIONAL 2D MAP BUTTON ---
          // Only show this button if the destination is NOT indoor
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Start 2D Map'),
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              onPressed: _toggleMapNavigation, // Triggers 2D map
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Start AR Nav'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700, // Different color
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
                onPressed: _startARNavigation, // Triggers AR view
              ),
            ),
        ],
      ),
    );
  }

  // This is your original "Stop" button for the 2D Map
  Widget _buildStopNavigationButton() {
    return Positioned(
      bottom: 32.0,
      left: 0,
      right: 0,
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          onPressed: _toggleMapNavigation,
          child: const Text('Stop'),
        ),
      ),
    );
  }

  Widget _buildDestinationSelector() {
    return Card(
      elevation: 4,
      shadowColor: Colors.deepPurple.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SearchField<Destination>(
          controller: _searchController,
          // UPDATED: Now uses the global 'destinations' list from your model file
          suggestions: destinations
              .map((dest) =>
                  SearchFieldListItem<Destination>(dest.name, item: dest))
              .toList(),
          searchInputDecoration: const InputDecoration(
            hintText: 'Select a Destination',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.location_on, color: Colors.deepPurple),
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
          onSuggestionTap: (SearchFieldListItem<Destination> item) {
            FocusScope.of(context).unfocus();
            setState(() {
              _selectedDestination = item.item;
              _searchController.text = item.searchKey;
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
// Only AR Navigation View code without google-map
// import 'package:flutter/material.dart';
// import 'package:searchfield/searchfield.dart';
// import 'package:pathfinder_indoor_navigation/widgets/ar_navigation_view.dart';
// import 'package:camera/camera.dart';
// class Destination {
//   final String name;
//   final double latitude;
//   final double longitude;

//   Destination({
//     required this.name,
//     required this.latitude,
//     required this.longitude,
//   });
// }

// class HomeScreen extends StatefulWidget {
//   final List<CameraDescription> cameras;
//   const HomeScreen({Key? key, required this.cameras}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   Destination? _selectedDestination;

//   final List<Destination> destinations = [
//     Destination(name: 'Main Library', latitude: 12.9716, longitude: 77.5946),
//     Destination(name: 'Science Block', latitude: 12.9751, longitude: 77.5921),
//     Destination(name: 'Auditorium', latitude: 12.9722, longitude: 77.5954),
//     Destination(name: 'Cafeteria', latitude: 12.9730, longitude: 77.5960),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'PathFinder Indoor Navigation',
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.deepPurple,
//         elevation: 0,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.deepPurple.shade50, Colors.white],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Search Destination',
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87),
//               ),
//               const SizedBox(height: 15),
        
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.deepPurple.shade100.withOpacity(0.5),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: SearchField<Destination>(
//                   controller: _searchController,
//                   searchInputDecoration: const InputDecoration(
//                     hintText: 'Select a Destination',
//                     border: InputBorder.none,
//                     prefixIcon: Icon(Icons.location_on,color: Colors.deepPurple),
//                     contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                   ),
//                   suggestions: destinations
//                       .map((dest) => SearchFieldListItem<Destination>(
//                             dest.name,
//                             item: dest,
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 12.0, horizontal: 16.0,
//                               ),
//                               child: Text(
//                                 dest.name,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                           ))
//                       .toList(),
//                   itemHeight: 50,
//                   maxSuggestionsInViewPort: 5,
//                   onSuggestionTap: (SearchFieldListItem<Destination> item) {
//                     FocusScope.of(context).unfocus();
//                     setState(() {
//                       _selectedDestination = item.item;
//                       _searchController.text = item.searchKey;
//                     });
//                   },
//                 ),
//               ),
        
//               const SizedBox(height: 30),
        
//               if (_selectedDestination != null)
//                 Card(
//                   elevation: 4,
//                   shadowColor: Colors.deepPurple.shade100,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.all(15),
//                     leading: const Icon(Icons.place, color: Colors.deepPurple, size: 30),
//                     title: Text(
//                       _selectedDestination!.name,
//                       style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
//                     ),
//                     subtitle: Text(
//                       'Lat: ${_selectedDestination!.latitude}, '
//                       'Lng: ${_selectedDestination!.longitude}',
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ),
//                 ),
        
//               const Spacer(),
        
//               Center(
//                 child: ElevatedButton.icon(
//                   onPressed: _selectedDestination == null
//                       ? null
//                       : () {
//                         if (widget.cameras.isEmpty) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('No cameras found on this device.'),
//                             backgroundColor: Colors.red,
//                             ),
//                           );
//                           return ;
//                         }
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ARNavigationScreen(
//                               destination: _selectedDestination!, 
//                               camera: widget.cameras.first,
//                             ),
//                           ),
//                         );
//                       },
//                   icon: const Icon(Icons.navigation),
//                   label: const Text('Start Navigation',style: TextStyle(color: Colors.white, fontSize: 16),),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepPurple,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 30.0, vertical: 15.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 5,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//Older code backup
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:pathfinder_indoor_navigation/models/destination.dart';
// import 'package:pathfinder_indoor_navigation/widgets/map_widget.dart';
// import 'package:searchfield/searchfield.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   Position? _currentPosition;
//   Destination? _selectedDestination;
//   StreamSubscription<Position>? _positionStreamSubscription;
//   final _searchController = TextEditingController();
//   bool _isNavigating = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeLocation();
//   }

//   Future<void> _initializeLocation() async {
//     try {
//       bool serviceEnabled;
//       LocationPermission permission;

//       serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         _showErrorDialog('Location services are disabled. Please enable them.');
//         return;
//       }

//       permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           _showErrorDialog('Location permissions are denied.');
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         _showErrorDialog(
//             'Location permissions are permanently denied. We cannot request permissions.');
//         return;
//       }

//       final initialPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.bestForNavigation,
//       );
      
//       if (mounted) {
//         setState(() {
//           _currentPosition = initialPosition;
//         });
//       }

//       _startLocationStream();
//     } catch (e) {
//       print("Error initializing location: $e");
//       _showErrorDialog("Could not get initial location. Please try again.");
//     }
//   }
  
//   void _startLocationStream() {
//     _positionStreamSubscription = Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.bestForNavigation,
//         distanceFilter: 1,
//       ),
//     ).listen((Position position) {
//       if (mounted) {
//         setState(() {
//           _currentPosition = position;
//         });
//       }
//     });
//   }

//   void _showErrorDialog(String message) {
//     if (!mounted) return;
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Location Error'),
//         content: Text(message),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('OK'),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ],
//       ),
//     );
//   }

//   void _toggleNavigation() {
//     setState(() {
//       _isNavigating = !_isNavigating;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pathfinder Indoor Navigation'),
//         centerTitle: true,
//         automaticallyImplyLeading: !_isNavigating,
//       ),
//       body: Stack(
//         children: [
//           if (_currentPosition == null)
//             const Center(child: CircularProgressIndicator())
//           else
//             _isNavigating ? _buildNavigationView() : _buildSelectionView(),

//           if (_isNavigating) _buildStopNavigationButton(),
//         ],
//       ),
//     );
//   }

//   Widget _buildSelectionView() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Stack(
//         children: [
//           Column(
//             children: [
//               _buildDestinationSelector(),
//               const SizedBox(height: 20),
//               Expanded(
//                 child: Card(
//                   clipBehavior: Clip.antiAlias,
//                   child: MapWidget(
//                     currentPosition: _currentPosition!,
//                     destination: _selectedDestination,
//                     isNavigating: false,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 80),
//             ],
//           ),
//           if (_selectedDestination != null) _buildStartNavigationButton(),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavigationView() {
//     return MapWidget(
//       currentPosition: _currentPosition!,
//       destination: _selectedDestination,
//       isNavigating: true,
//     );
//   }

//   Widget _buildStartNavigationButton() {
//     return Positioned(
//       bottom: 16.0,
//       left: 16.0,
//       right: 16.0,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//             backgroundColor: Theme.of(context).primaryColor,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 16.0),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12.0),
//             ),
//             textStyle: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             )),
//         onPressed: _toggleNavigation,
//         child: const Text('Start Navigation'),
//       ),
//     );
//   }

//   Widget _buildStopNavigationButton() {
//     return Positioned(
//       bottom: 32.0,
//       left: 0,
//       right: 0,
//       child: Center(
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 40, vertical: 16.0),
//               shape: RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(30.0),
//               ),
//               textStyle: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               )),
//           onPressed: _toggleNavigation,
//           child: const Text('Stop'),
//         ),
//       ),
//     );
//   }

//   Widget _buildDestinationSelector() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//         child: SearchField<Destination>(
//           controller: _searchController,
//           hint: 'Select a Destination',
//           suggestions: destinations
//               .map((dest) =>
//                   SearchFieldListItem<Destination>(dest.name, item: dest))
//               .toList(),
//           searchInputDecoration: const InputDecoration(
//             border: InputBorder.none,
//             prefixIcon: Icon(Icons.location_on),
//           ),
//           onSuggestionTap: (SearchFieldListItem<Destination> item) {
//             FocusScope.of(context).unfocus();
//             setState(() {
//               _selectedDestination = item.item;
//               _searchController.text = item.searchKey;
//             });
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _positionStreamSubscription?.cancel();
//     _searchController.dispose();
//     super.dispose();
//   }
// }