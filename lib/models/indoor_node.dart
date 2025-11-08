// This class represents a single node from your JSON file
class IndoorNode {
  final int id;
  final int x;
  final int y;
  final String type;
  final String? name; // Nullable, since 'path' nodes have no name

  IndoorNode({
    required this.id,
    required this.x,
    required this.y,
    required this.type,
    this.name,
  });

  // Factory constructor to parse data from the JSON
  factory IndoorNode.fromJson(Map<String, dynamic> json) {
    return IndoorNode(
      id: json['id'],
      x: json['x'],
      y: json['y'],
      type: json['type'],
      name: json['name'],
    );
  }
}
