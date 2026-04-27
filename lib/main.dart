import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pathfinder_indoor_navigation/services/indoor_map_service.dart';
import 'package:pathfinder_indoor_navigation/services/wifi_positioning_service.dart';
import 'package:pathfinder_indoor_navigation/screens/indoor_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        Provider<IndoorMapService>(create: (_) => IndoorMapService()),
        ChangeNotifierProvider<WifiPositioningService>(
          create: (_) => WifiPositioningService(),
        ),
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
      title: 'GDN Indoor Navigation',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const IndoorNavigationScreen(),
    );
  }
}
