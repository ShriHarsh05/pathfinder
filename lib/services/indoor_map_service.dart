import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pathfinder_indoor_navigation/models/indoor_node.dart';
import 'package:collection/collection.dart'; // For PriorityQueue

class IndoorMapService {
  List<IndoorNode> _nodes = [];
  Map<int, List<Map<String, dynamic>>> _adjacencyList = {};
  bool _isInitialized = false;

  // --- 1. Initialization ---
  
  Future<void> loadMapData() async {
    if (_isInitialized) return;

    try {
      // Load the JSON string from assets
      final String jsonString = await rootBundle.loadString('assets/maps/gdn_ground_floor_graph.json');
      
      // Decode the JSON
      final Map<String, dynamic> graphData = json.decode(jsonString);

      // Parse nodes
      final List<dynamic> nodesList = graphData['nodes'];
      _nodes = nodesList.map((nodeJson) => IndoorNode.fromJson(nodeJson)).toList();

      // Parse edges and build the adjacency list
      final List<dynamic> edgesList = graphData['edges'];
      _adjacencyList = {}; // Clear old list
      for (var edge in edgesList) {
        int source = edge['source'];
        int target = edge['target'];
        double weight = edge['weight'];

        _adjacencyList.putIfAbsent(source, () => []).add({'target': target, 'weight': weight});
        _adjacencyList.putIfAbsent(target, () => []).add({'target': source, 'weight': weight}); // Since it's an undirected graph
      }

      _isInitialized = true;
      print("Indoor map data loaded successfully.");
      print("Nodes loaded: ${_nodes.length}, Edges loaded: ${edgesList.length}");

    } catch (e) {
      print("Error loading map data: $e");
    }
  }

  // --- 2. Public Methods ---

  // Get only nodes that are 'rooms' (for the dropdowns)
  List<IndoorNode> getRoomNodes() {
    return _nodes.where((node) => node.type == 'room').toList();
  }

  // Get a node by its ID
  IndoorNode? getNodeById(int id) {
    return _nodes.firstWhereOrNull((node) => node.id == id);
  }

  // --- 3. Pathfinding (Dijkstra's Algorithm) ---
  
  List<IndoorNode> findPath(int startId, int endId) {
    if (!_isInitialized) return [];

    // Stores the shortest distance from startId to any node
    final distances = <int, double>{};
    // Stores the previous node in the shortest path
    final previous = <int, int?>{};
    // Priority queue to efficiently get the node with the smallest distance
    final queue = PriorityQueue<MapEntry<int, double>>((a, b) => a.value.compareTo(b.value));

    // Initialize all distances to infinity and previous to null
    for (var node in _nodes) {
      distances[node.id] = double.infinity;
      previous[node.id] = null;
    }

    // Start node distance is 0
    distances[startId] = 0;
    queue.add(MapEntry(startId, 0));

    while (queue.isNotEmpty) {
      // Get the node with the smallest distance
      final currentEntry = queue.removeFirst();
      final currentNodeId = currentEntry.key;
      final currentDistance = currentEntry.value;

      // If we've already processed this node with a shorter path, skip
      if (currentDistance > distances[currentNodeId]!) {
        continue;
      }

      // If we've reached the end, we're done
      if (currentNodeId == endId) {
        break;
      }

      // Check all neighbors of the current node
      if (_adjacencyList.containsKey(currentNodeId)) {
        for (var edge in _adjacencyList[currentNodeId]!) {
          final neighborId = edge['target'];
          final weight = edge['weight'];
          final newDistance = currentDistance + weight;

          // If we found a shorter path to this neighbor...
          if (newDistance < distances[neighborId]!) {
            distances[neighborId] = newDistance;
            previous[neighborId] = currentNodeId;
            queue.add(MapEntry(neighborId, newDistance)); // Add it to the queue to be processed
          }
        }
      }
    }

    // --- 4. Reconstruct the path ---
    final path = <IndoorNode>[];
    int? currentId = endId;

    while (currentId != null) {
      final node = getNodeById(currentId);
      if (node != null) {
        path.insert(0, node); // Add to the beginning to reverse the path
      }
      currentId = previous[currentId];
    }

    // If the path starts with the startId, we found a valid path
    if (path.isNotEmpty && path.first.id == startId) {
      print("Path found: ${path.map((n) => n.id).join(' -> ')}");
      return path;
    } else {
      print("No path found from $startId to $endId");
      return []; // No path found
    }
  }
}
