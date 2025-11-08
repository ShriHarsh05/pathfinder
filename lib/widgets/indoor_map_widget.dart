import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pathfinder_indoor_navigation/models/indoor_node.dart';
import 'dart:ui' as ui;
import 'dart:ui';
import 'dart:math' as math;

class IndoorMapWidget extends StatefulWidget {
  final String mapImagePath;
  final List<IndoorNode> path;
  final IndoorNode? startNode;
  final IndoorNode? endNode;

  const IndoorMapWidget({
    Key? key,
    required this.mapImagePath,
    this.path = const [],
    this.startNode,
    this.endNode,
  }) : super(key: key);

  @override
  // 1. Made State public (removed the '_')
  IndoorMapWidgetState createState() => IndoorMapWidgetState();
}

// 2. Made State class public
class IndoorMapWidgetState extends State<IndoorMapWidget> {
  ui.Image? _mapImage;
  late final TransformationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
    _loadMapImage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant IndoorMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mapImagePath != oldWidget.mapImagePath) {
      _loadMapImage();
    }

    // Auto-zoom when the startNode *first* appears
    if (widget.startNode != null && oldWidget.startNode == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          zoomToNode(widget.startNode!);
        }
      });
    } 
    // Reset zoom if the start node is cleared
    else if (widget.startNode == null && oldWidget.startNode != null) {
      resetZoom();
    }
  }

  Future<void> _loadMapImage() async {
    try {
      final ByteData data = await rootBundle.load(widget.mapImagePath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _mapImage = frame.image;
        });
      }
    } catch (e) {
      print("Error loading map image: $e");
    }
  }

  /// Resets the map view to its default, unzoomed state.
  // 3. Made function public
  void resetZoom() {
    _controller.value = Matrix4.identity();
  }

  /// Calculates the transformation to center the map on a specific node.
  // 4. Made function public
  void zoomToNode(IndoorNode node) {
    if (_mapImage == null || !mounted) return;

    if (context.findRenderObject() == null) {
      return;
    }
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size widgetSize = renderBox.size;

    const double zoomLevel = 2.5; 

    final double widgetCenterX = widgetSize.width / 2;
    final double widgetCenterY = widgetSize.height / 2;

    final Matrix4 matrix = Matrix4.identity()
      ..translate(widgetCenterX, widgetCenterY, 0.0) 
      ..scale(zoomLevel, zoomLevel, 1.0) 
      ..translate(-node.x.toDouble(), -node.y.toDouble(), 0.0);

    _controller.value = matrix;
  }

  @override
  Widget build(BuildContext context) {
    if (_mapImage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return InteractiveViewer(
      transformationController: _controller,
      minScale: 0.1, 
      maxScale: 4.0, 
      constrained: false, 
      child: CustomPaint(
        painter: PathPainter(
          mapImage: _mapImage!,
          path: widget.path,
          startNode: widget.startNode,
          endNode: widget.endNode,
        ),
        child: SizedBox(
          width: _mapImage!.width.toDouble(),
          height: _mapImage!.height.toDouble(),
        ),
      ),
    );
  }
}

// --- The Custom Painter (No changes below this line) ---
class PathPainter extends CustomPainter {
  final ui.Image mapImage;
  final List<IndoorNode> path;
  final IndoorNode? startNode;
  final IndoorNode? endNode;

  PathPainter({
    required this.mapImage,
    required this.path,
    this.startNode,
    this.endNode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ... (drawing logic is the same) ...
    final Rect srcRect = Rect.fromLTWH(0, 0, mapImage.width.toDouble(), mapImage.height.toDouble());
    final Rect dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(mapImage, srcRect, dstRect, Paint());

    if (path.length > 1) {
      final pathPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0; 

      final ui.Path drawPath = ui.Path();
      drawPath.moveTo(path.first.x.toDouble(), path.first.y.toDouble());
      for (int i = 1; i < path.length; i++) {
        drawPath.lineTo(path[i].x.toDouble(), path[i].y.toDouble());
      }
      
      _drawDashedPath(canvas, drawPath, pathPaint, 10.0, 5.0);
    }
    
    if (endNode != null) {
      _drawTargetMarker(canvas, endNode!, Colors.red);
    }

    if (startNode != null) {
      _drawTargetMarker(canvas, startNode!, Colors.green);
    }
  }

  void _drawTargetMarker(Canvas canvas, IndoorNode node, Color color) {
    if (color == Colors.red) {
      _drawPinMarker(canvas, node, color);
    } else {
      const double innerRadius = 7.0;
      const double innerRadiusWhite = 6.0;
      const double haloRadius = 12.0;

      final haloPaint = Paint()
        ..color = color.withAlpha((0.2 * 255).round())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(node.x.toDouble(), node.y.toDouble()), haloRadius, haloPaint);

      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(node.x.toDouble(), node.y.toDouble()), innerRadius, fillPaint);

      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0; 
      canvas.drawCircle(Offset(node.x.toDouble(), node.y.toDouble()), innerRadiusWhite, borderPaint);
    }
  }

  void _drawPinMarker(Canvas canvas, IndoorNode node, Color color) {
    final double tipX = node.x.toDouble();
    final double tipY = node.y.toDouble();
    const double pinHeight = 30.0;
    const double headRadius = 10.0;
    final double headCenterY = tipY - pinHeight + headRadius;
    final double headCenterX = tipX;

    final Paint fillPaint = Paint()..color = color;
    final Paint whitePaint = Paint()..color = Colors.white;
    final Paint shadowPaint = Paint()..color = Colors.black.withAlpha((0.3 * 255).round());

    final shadowPath = Path();
    shadowPath.addOval(Rect.fromCenter(center: Offset(tipX, tipY + 1), width: headRadius * 1.2, height: headRadius / 2));
    canvas.drawPath(shadowPath, shadowPaint);

    final Path path = Path();
    path.moveTo(tipX, tipY); 
    path.cubicTo(
      tipX - headRadius * 0.7, tipY - (pinHeight * 0.4), 
      tipX - headRadius, headCenterY - (headRadius * 0.5), 
      tipX - headRadius, headCenterY 
    );
    
    path.arcTo(
      Rect.fromCircle(center: Offset(headCenterX, headCenterY), radius: headRadius),
      math.pi, 
      math.pi, 
      false
    );

    path.cubicTo(
      tipX + headRadius, headCenterY - (headRadius * 0.5), 
      tipX + headRadius * 0.7, tipY - (pinHeight * 0.4), 
      tipX, tipY 
    );
    path.close();
    canvas.drawPath(path, fillPaint);

    canvas.drawCircle(Offset(tipX, headCenterY), headRadius / 2.5, whitePaint);
  }


  void _drawDashedPath(Canvas canvas, ui.Path path, Paint paint, double dashWidth, double dashSpace) {
    final PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return oldDelegate.path != path ||
           oldDelegate.mapImage != mapImage ||
           oldDelegate.startNode != startNode ||
           oldDelegate.endNode != endNode;
  }
}