import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class WifiReading {
  final String bssid;
  final String ssid;
  final int rssi;

  const WifiReading({required this.bssid, required this.ssid, required this.rssi});

  Map<String, dynamic> toJson() => {'bssid': bssid, 'ssid': ssid, 'rssi': rssi};
}

class WifiPositioningService extends ChangeNotifier {
  // ---------------------------------------------------------------
  static const bool demoMode = false;

  // Local ML server — POST /locate  body: {"readings":[{bssid,ssid,rssi},...]}
  //                                 response: {"x":<num>,"y":<num>}
  static const String _serverUrl = 'http://10.54.170.215:5000/locate';

  static const Duration _scanInterval = Duration(seconds: 1);
  // ---------------------------------------------------------------

  // Native MethodChannel — talks to MainActivity.kt
  static const _channel = MethodChannel('com.gdn.indoor/wifi');

  // Coordinate transform (same calibration as before)
  static const double _scaleX =  10.1549;
  static const double _scaleY = -10.1914;
  static const double _offsetX =  9.3826;
  static const double _offsetY =  1181.5126;

  // Demo waypoints
  static const _demo = [
    (x: 65.0,  y: 6.0,   label: 'GDN Entrance'),
    (x: 57.0,  y: 13.0,  label: 'G01'),
    (x: 60.0,  y: 26.0,  label: 'G02'),
    (x: 39.0,  y: 41.0,  label: 'G03'),
    (x: 41.0,  y: 62.0,  label: 'G07'),
    (x: 59.0,  y: 62.0,  label: 'G08'),
    (x: 26.0,  y: 62.0,  label: 'G06'),
    (x: 16.0,  y: 62.0,  label: 'G05'),
    (x: 67.0,  y: 80.0,  label: 'G14'),
    (x: 59.0,  y: 97.0,  label: 'G10'),
    (x: 27.0,  y: 94.0,  label: 'G10A'),
    (x: 65.0,  y: 107.0, label: 'G11'),
    (x: 85.0,  y: 21.0,  label: 'G19'),
    (x: 65.0,  y: 6.0,   label: 'Back to Entrance'),
  ];
  int _demoIndex = 0;

  // State
  Offset?          _mappedPosition;
  double?          _rawX;
  double?          _rawY;
  String?          _statusLabel;
  String?          _error;
  bool             _isRunning = false;
  Timer?           _timer;
  List<WifiReading> _lastReadings = [];

  Offset?           get mappedPosition => _mappedPosition;
  double?           get rawX           => _rawX;
  double?           get rawY           => _rawY;
  String?           get statusLabel    => _statusLabel;
  String?           get error          => _error;
  bool              get isRunning      => _isRunning;
  List<WifiReading> get lastReadings   => List.unmodifiable(_lastReadings);

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _tick();
    _timer = Timer.periodic(_scanInterval, (_) => _tick());
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  void _tick() => demoMode ? _advanceDemo() : _scanAndLocate();

  // ── Demo ──────────────────────────────────────────────────────

  void _advanceDemo() {
    final p = _demo[_demoIndex];
    _rawX = p.x; _rawY = p.y; _statusLabel = p.label;
    _mappedPosition = _transform(p.x, p.y);
    _error = null;
    _demoIndex = (_demoIndex + 1) % _demo.length;
    notifyListeners();
  }

  // ── Real ──────────────────────────────────────────────────────

  Future<void> _scanAndLocate() async {
    final readings = await _scanWifi();
    if (readings == null) return;
    _lastReadings = readings;

    if (readings.isEmpty) {
      _error = 'No WiFi APs found';
      notifyListeners();
      return;
    }
    await _requestPosition(readings);
  }

  Future<List<WifiReading>?> _scanWifi() async {
    try {
      final raw = await _channel.invokeMethod<List>('getWifiReadings');
      if (raw == null) return [];
      final readings = raw.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return WifiReading(
          bssid: m['bssid'] as String,
          ssid:  m['ssid']  as String,
          rssi:  m['rssi']  as int,
        );
      }).toList();

      // Print all RSSI readings to the terminal
      debugPrint('── WiFi Scan (${readings.length} APs) ──────────────────');
      for (final r in readings) {
        debugPrint('  ${r.ssid.padRight(30)} ${r.bssid}  RSSI: ${r.rssi} dBm');
      }
      debugPrint('────────────────────────────────────────────────────');

      return readings;
    } on PlatformException catch (e) {
      _error = 'WiFi scan failed: ${e.message}';
      notifyListeners();
      return null;
    }
  }

  Future<void> _requestPosition(List<WifiReading> readings) async {
    try {
      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'readings': readings.map((r) => r.toJson()).toList()}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _rawX = (json['x'] as num).toDouble();
        _rawY = (json['y'] as num).toDouble();
        _mappedPosition = _transform(_rawX!, _rawY!);
        _statusLabel = null;
        _error = null;
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Server unreachable: $e';
    }
    notifyListeners();
  }

  Offset _transform(double x, double y) => Offset(
    x * _scaleX + _offsetX,
    y * _scaleY + _offsetY,
  );

  @override
  void dispose() { stop(); super.dispose(); }
}
