import 'package:flutter/material.dart';
import 'package:pathfinder_indoor_navigation/models/indoor_node.dart';
import 'package:pathfinder_indoor_navigation/services/indoor_map_service.dart';
import 'package:pathfinder_indoor_navigation/widgets/indoor_map_widget.dart';
import 'package:searchfield/searchfield.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart'; 
import 'package:collection/collection.dart'; 

class IndoorNavigationScreen extends StatefulWidget {
  final String? preselectedDestinationName;
  final String? preselectedStartName; 
  final List<CameraDescription> cameras;

  const IndoorNavigationScreen({
    Key? key,
    this.preselectedDestinationName,
    this.preselectedStartName, 
    required this.cameras,
  }) : super(key: key);

  @override
  // 1. Made State public
  IndoorNavigationScreenState createState() => IndoorNavigationScreenState();
}

// 2. Made State class public
class IndoorNavigationScreenState extends State<IndoorNavigationScreen> {
  late IndoorMapService _mapService;
  List<IndoorNode> _roomNodes = [];
  IndoorNode? _startNode;
  IndoorNode? _endNode;
  List<IndoorNode> _path = [];
  final _startSearchController = TextEditingController();
  final _endSearchController = TextEditingController();

  // 3. Changed from UniqueKey to a GlobalKey to control the child
  final GlobalKey<IndoorMapWidgetState> _mapWidgetKey = GlobalKey<IndoorMapWidgetState>();

  @override
  void initState() {
    super.initState();
    _mapService = Provider.of<IndoorMapService>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    await _mapService.loadMapData();
    setState(() {
      _roomNodes = _mapService.getRoomNodes();
    });

    bool needsPathCalculation = false;

    if (widget.preselectedDestinationName != null) {
      final preselectedNode = _roomNodes.firstWhereOrNull(
        (node) => node.name == widget.preselectedDestinationName,
      );

      if (preselectedNode != null) {
        setState(() {
          _endNode = preselectedNode;
          _endSearchController.text = preselectedNode.name ?? '';
          needsPathCalculation = true;
        });
      }
    }

    if (widget.preselectedStartName != null) {
      final preselectedNode = _roomNodes.firstWhereOrNull(
        (node) => node.name == widget.preselectedStartName,
      );

      if (preselectedNode != null) {
        setState(() {
          _startNode = preselectedNode;
          _startSearchController.text = preselectedNode.name ?? '';
          needsPathCalculation = true;
        });
      }
    }

    if (needsPathCalculation && _startNode != null && _endNode != null) {
      _calculatePath();
    }
  }

  void _calculatePath() {
    if (_startNode != null && _endNode != null) {
      setState(() {
        _path = _mapService.findPath(_startNode!.id, _endNode!.id);
      });
    } else {
      setState(() {
        _path = [];
      });
    }
    // We no longer need to change the key
    // _mapWidgetKey = UniqueKey();
  }
  
  // 4. NEW: Function to be called by the button
  void _reCenterMap() {
    if (_startNode != null) {
      // Call the public zoomToNode function on the map widget's state
      _mapWidgetKey.currentState?.zoomToNode(_startNode!);
    } else if (_path.isEmpty) {
      // If no start node, just reset the zoom
      _mapWidgetKey.currentState?.resetZoom();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GDN Indoor Navigation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLocationCard(
              label: "FROM Location (Your Location)",
              controller: _startSearchController,
              onSelected: (node) {
                setState(() {
                  _startNode = node;
                });
                _calculatePath();
                // Auto-zoom when a new start node is selected
                WidgetsBinding.instance.addPostFrameCallback((_) {
                   _reCenterMap();
                });
              },
              onClear: () {
                setState(() {
                  _startNode = null;
                });
                _calculatePath();
              },
            ),
            const SizedBox(height: 10),
            _buildLocationCard(
              label: "TO Location (Destination)",
              controller: _endSearchController,
              onSelected: (node) {
                setState(() {
                  _endNode = node;
                });
                _calculatePath();
              },
              onClear: () {
                setState(() {
                  _endNode = null;
                });
                _calculatePath();
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: IndoorMapWidget(
                  key: _mapWidgetKey, // 5. Assign the GlobalKey
                  // 6. FIX: Use the clean map file name
                  mapImagePath: 'assets/maps/gdn_ground_floor.png', 
                  path: _path,
                  startNode: _startNode,
                  endNode: _endNode,
                ),
              ),
            ),
          ],
        ),
      ),
      // 7. NEW: Add the Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _reCenterMap, // Call our re-center function
        tooltip: 'Re-center on Start',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildLocationCard({
    required String label,
    required TextEditingController controller,
    required Function(IndoorNode) onSelected,
    required VoidCallback onClear,
  }) {
    return Card(
      elevation: 4.0, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 12.0, right: 4.0, top: 4.0, bottom: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, top: 4.0),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: SearchField<IndoorNode>(
                    controller: controller,
                    hint: 'Select a room...',
                    suggestions: _roomNodes
                        .map((node) => SearchFieldListItem<IndoorNode>(
                              node.name ?? 'Unknown Room',
                              item: node,
                            ))
                        .toList(),
                    searchInputDecoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Select a room...',
                    ),
                    onSuggestionTap: (SearchFieldListItem<IndoorNode> item) {
                      onSelected(item.item!);
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    controller.clear();
                    onClear();
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