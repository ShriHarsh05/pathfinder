import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';
import 'package:pathfinder_indoor_navigation/models/indoor_node.dart';
import 'package:pathfinder_indoor_navigation/services/indoor_map_service.dart';
import 'package:pathfinder_indoor_navigation/services/wifi_positioning_service.dart';
import 'package:pathfinder_indoor_navigation/widgets/indoor_map_widget.dart';
import 'package:pathfinder_indoor_navigation/widgets/destination_reached_dialog.dart';

class IndoorNavigationScreen extends StatefulWidget {
  const IndoorNavigationScreen({Key? key}) : super(key: key);

  @override
  IndoorNavigationScreenState createState() => IndoorNavigationScreenState();
}

class IndoorNavigationScreenState extends State<IndoorNavigationScreen> {
  late IndoorMapService _mapService;
  late WifiPositioningService _positioningService;

  List<IndoorNode> _roomNodes = [];
  IndoorNode? _endNode;
  List<IndoorNode> _path = [];
  bool _isLoading = true;

  final _endSearchController = TextEditingController();
  final GlobalKey<IndoorMapWidgetState> _mapWidgetKey = GlobalKey<IndoorMapWidgetState>();

  Offset? _lastPosition;

  @override
  void initState() {
    super.initState();
    _mapService = Provider.of<IndoorMapService>(context, listen: false);
    _positioningService = Provider.of<WifiPositioningService>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _positioningService.stop();
    _positioningService.removeListener(_onPositionUpdate);
    _endSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _mapService.loadMapData();
    if (!mounted) return;
    setState(() {
      _roomNodes = _mapService.getRoomNodes();
      _isLoading = false;
    });
    _positioningService.addListener(_onPositionUpdate);
    _positioningService.start();
  }

  void _onPositionUpdate() {
    if (!mounted) return;
    final newPos = _positioningService.mappedPosition;
    if (newPos != null && newPos != _lastPosition && _endNode != null) {
      _lastPosition = newPos;
      _recalculatePath();
    } else {
      setState(() {});
    }
  }

  IndoorNode? _getNearestNode(Offset position) {
    IndoorNode? nearest;
    double minDist = double.infinity;
    for (final node in _mapService.getAllNodes()) {
      final dx = node.x - position.dx;
      final dy = node.y - position.dy;
      final dist = dx * dx + dy * dy;
      if (dist < minDist) {
        minDist = dist;
        nearest = node;
      }
    }
    return nearest;
  }

  void _onDestinationSelected(IndoorNode node) {
    setState(() => _endNode = node);
    _recalculatePath();
  }

  void _clearDestination() {
    setState(() {
      _endNode = null;
      _path = [];
    });
    _endSearchController.clear();
  }

  void _recalculatePath() {
    final livePos = _positioningService.mappedPosition;
    if (livePos == null || _endNode == null) {
      setState(() => _path = []);
      return;
    }

    final startNode = _getNearestNode(livePos);
    if (startNode == null) {
      setState(() => _path = []);
      return;
    }

    if (startNode.id == _endNode!.id) {
      setState(() => _path = []);
      showDialog(
        context: context,
        builder: (_) => DestinationReachedDialog(
          destinationName: _endNode!.name ?? 'Destination',
          onOk: () {},
        ),
      );
      return;
    }

    setState(() {
      _path = _mapService.findPath(startNode.id, _endNode!.id);
    });
  }

  void _reCenterOnUser() {
    final pos = _positioningService.mappedPosition;
    if (pos != null) {
      _mapWidgetKey.currentState?.zoomToPosition(pos);
    } else {
      _mapWidgetKey.currentState?.resetZoom();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading map data...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('GDN Indoor Navigation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatusBar(),
            const SizedBox(height: 10),
            _buildDestinationCard(),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: IndoorMapWidget(
                  key: _mapWidgetKey,
                  mapImagePath: 'assets/maps/gdn_ground_floor.png',
                  path: _path,
                  endNode: _endNode,
                  livePosition: _positioningService.mappedPosition,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _reCenterOnUser,
        tooltip: 'Center on my location',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildStatusBar() {
    final svc = _positioningService;
    final hasPosition = svc.mappedPosition != null;
    final hasError = svc.error != null;

    // Build the status message
    String message;
    if (hasError) {
      message = svc.error!;
    } else if (hasPosition) {
      if (WifiPositioningService.demoMode) {
        message = '[DEMO] ${svc.statusLabel ?? ''} (${svc.rawX?.toStringAsFixed(0)}, ${svc.rawY?.toStringAsFixed(0)})';
      } else {
        final apCount = svc.lastReadings.length;
        message = 'WiFi: $apCount APs scanned  •  pos (${svc.rawX?.toStringAsFixed(1)}, ${svc.rawY?.toStringAsFixed(1)})';
      }
    } else {
      message = WifiPositioningService.demoMode
          ? 'Starting demo...'
          : 'Scanning WiFi...';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: hasError
            ? Colors.red.shade50
            : hasPosition
                ? Colors.green.shade50
                : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasError
              ? Colors.red.shade200
              : hasPosition
                  ? Colors.green.shade200
                  : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasError ? Icons.wifi_off : hasPosition ? Icons.wifi : Icons.wifi_find,
            size: 18,
            color: hasError ? Colors.red : hasPosition ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: hasError ? Colors.red.shade700 : Colors.grey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (svc.isRunning)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 4.0, top: 4.0, bottom: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, top: 4.0),
              child: Text(
                'TO Location (Destination)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: SearchField<IndoorNode>(
                    controller: _endSearchController,
                    hint: 'Select a room...',
                    suggestions: _roomNodes
                        .map((node) => SearchFieldListItem<IndoorNode>(
                              node.name ?? 'Unknown',
                              item: node,
                            ))
                        .toList(),
                    searchInputDecoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Select a room...',
                    ),
                    onSuggestionTap: (SearchFieldListItem<IndoorNode> item) {
                      _onDestinationSelected(item.item!);
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    _clearDestination();
                    FocusScope.of(context).unfocus();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
