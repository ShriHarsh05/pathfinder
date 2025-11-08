import 'package:flutter/material.dart';
import 'package:pathfinder_indoor_navigation/screens/home_screen.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:pathfinder_indoor_navigation/services/indoor_map_service.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error initializing cameras: ${e.code}\n${e.description}');
  }
  
  // Wrap your app in Provider
  runApp(
    MultiProvider(
      providers: [
        // Make the IndoorMapService available to all widgets
        Provider<IndoorMapService>(create: (_) => IndoorMapService()),
        // You can add other services here in the future
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pathfinder Navigation',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
      ),
      // Pass the globally initialized cameras list to HomeScreen
      home: HomeScreen(cameras: cameras),
    );
  }
}

