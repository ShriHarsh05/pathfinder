import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;

/// Represents the raw IoT coordinate from the API.
class IoTPosition {
  final double x;
  final double y;
  final String? label; // only set in demo mode

  const IoTPosition({required this.x, required this.y, this.label});

  factory IoTPosition.fromJson(Map<String, dynamic> json) {
    return IoTPosition(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }
}

/// Polls the IoT API for the device's current x,y position.
/// Notifies listeners whenever a new position is received.
class LocationApiService extends ChangeNotifier {
  // ---------------------------------------------------------------
  // SET THIS TO true TO USE DEMO MODE (no real API needed)
  static const bool demoMode = false;
  // ---------------------------------------------------------------

  // The endpoint that returns {"x": <number>, "y": <number>}
  static const String _apiUrl = 'http://10.54.170.215:5000/latest';

  // How often to poll / advance demo step
  static const Duration _pollInterval = Duration(seconds: 1);

  // Coordinate transform: IoT space → map pixel space
  // Derived via least-squares fit across 16 GDN rooms (RMSE: 6px X, 2.4px Y).
  static const double _scaleX = 10.1549;
  static const double _scaleY = -10.1914;
  static const double _offsetX = 9.3826;
  static const double _offsetY = 1181.5126;

  // Demo waypoints — walks a realistic route through the building
  static const List<IoTPosition> _demoWaypoints = [
    IoTPosition(x: 65,  y: 6,   label: 'GDN Entrance'),
    IoTPosition(x: 65,  y: 13,  label: '→ G01 corridor'),
    IoTPosition(x: 57,  y: 13,  label: 'G01'),
    IoTPosition(x: 60,  y: 13,  label: '← back to corridor'),
    IoTPosition(x: 60,  y: 26,  label: 'G02'),
    IoTPosition(x: 60,  y: 41,  label: '→ G03 corridor'),
    IoTPosition(x: 39,  y: 41,  label: 'G03'),
    IoTPosition(x: 39,  y: 62,  label: '→ G07 corridor'),
    IoTPosition(x: 41,  y: 62,  label: 'G07'),
    IoTPosition(x: 59,  y: 62,  label: 'G08'),
    IoTPosition(x: 26,  y: 62,  label: 'G06'),
    IoTPosition(x: 16,  y: 62,  label: 'G05'),
    IoTPosition(x: 18,  y: 59,  label: 'Cylinder Room'),
    IoTPosition(x: 59,  y: 80,  label: '→ G14 corridor'),
    IoTPosition(x: 67,  y: 80,  label: 'G14'),
    IoTPosition(x: 65,  y: 97,  label: '→ G10 corridor'),
    IoTPosition(x: 59,  y: 97,  label: 'G10'),
    IoTPosition(x: 27,  y: 94,  label: 'G10A'),
    IoTPosition(x: 65,  y: 107, label: 'G11'),
    IoTPosition(x: 71,  y: 24,  label: 'G19B'),
    IoTPosition(x: 85,  y: 21,  label: 'G19'),
    IoTPosition(x: 103, y: 21,  label: 'G19A'),
    IoTPosition(x: 65,  y: 6,   label: 'Back to Entrance'),
  ];

  int _demoIndex = 0;

  IoTPosition? _rawPosition;
  Offset? _mappedPosition;
  String? _error;
  Timer? _timer;
  bool _isPolling = false;

  IoTPosition? get rawPosition => _rawPosition;
  Offset? get mappedPosition => _mappedPosition;
  String? get error => _error;
  bool get isPolling => _isPolling;

  void startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    _tick(); // immediate first update
    _timer = Timer.periodic(_pollInterval, (_) => _tick());
    notifyListeners();
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
    _isPolling = false;
    notifyListeners();
  }

  void _tick() {
    if (demoMode) {
      _advanceDemo();
    } else {
      _fetchPosition();
    }
  }

  void _advanceDemo() {
    final waypoint = _demoWaypoints[_demoIndex];
    _rawPosition = waypoint;
    _mappedPosition = _transform(waypoint);
    _error = null;
    _demoIndex = (_demoIndex + 1) % _demoWaypoints.length;
    notifyListeners();
  }

  Future<void> _fetchPosition() async {
    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _rawPosition = IoTPosition.fromJson(json);
        _mappedPosition = _transform(_rawPosition!);
        _error = null;
      } else {
        _error = 'API error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Connection error: $e';
    }
    notifyListeners();
  }

  Offset _transform(IoTPosition pos) {
    return Offset(
      pos.x * _scaleX + _offsetX,
      pos.y * _scaleY + _offsetY,
    );
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
