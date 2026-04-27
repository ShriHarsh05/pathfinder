import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pathfinder_indoor_navigation/models/indoor_node.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class IndoorMapWidget extends StatefulWidget {
  final String mapImagePath;
  final List<IndoorNode> path;
  final IndoorNode? endNode;

  /// Live position from the IoT API (in floor plan pixel coordinates).
  final Offset? livePosition;

  const IndoorMapWidget({
    Key? key,
    required this.mapImagePath,
    this.path = const [],
    this.endNode,
    this.livePosition,
  }) : super(key: key);

  @override
  IndoorMapWidgetState createState() => IndoorMapWidgetState();
}

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
    // Auto-center on live position when it first arrives
    if (widget.livePosition != null && oldWidget.livePosition == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) zoomToPosition(widget.livePosition!);
      });
    }
  }

  Future<void> _loadMapImage() async {
    try {
      final ByteData data = await rootBundle.load(widget.mapImagePath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() => _mapImage = frame.image);
      }
    } catch (e) {
      debugPrint('Error loading map image: $e');
    }
  }

  void resetZoom() {
    _controller.value = Matrix4.identity();
  }

  void zoomToPosition(Offset position) {
    if (_mapImage == null || !mounted) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Size widgetSize = renderBox.size;
    const double zoomLevel = 2.5;

    _controller.value = Matrix4.identity()
      ..translate(widgetSize.width / 2, widgetSize.height / 2, 0.0)
      ..scale(zoomLevel, zoomLevel, 1.0)
      ..translate(-position.dx, -position.dy, 0.0);
  }

  void zoomToNode(IndoorNode node) {
    zoomToPosition(Offset(node.x.toDouble(), node.y.toDouble()));
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
          livePosition: widget.livePosition,
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

class PathPainter extends CustomPainter {
  final ui.Image mapImage;
  final List<IndoorNode> path;
  final IndoorNode? endNode;
  final Offset? livePosition;

  PathPainter({
    required this.mapImage,
    required this.path,
    this.endNode,
    this.livePosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw floor plan
    canvas.drawImageRect(
      mapImage,
      Rect.fromLTWH(0, 0, mapImage.width.toDouble(), mapImage.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    // Draw path
    if (path.length > 1) {
      final pathPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final drawPath = ui.Path();
      drawPath.moveTo(path.first.x.toDouble(), path.first.y.toDouble());
      for (int i = 1; i < path.length; i++) {
        drawPath.lineTo(path[i].x.toDouble(), path[i].y.toDouble());
      }
      _drawDashedPath(canvas, drawPath, pathPaint, 10.0, 5.0);
    }

    // Draw destination pin
    if (endNode != null) {
      _drawPinMarker(canvas, Offset(endNode!.x.toDouble(), endNode!.y.toDouble()), Colors.red);
    }

    // Draw live user position (pulsing blue dot)
    if (livePosition != null) {
      _drawLivePositionDot(canvas, livePosition!);
    }
  }

  void _drawLivePositionDot(Canvas canvas, Offset pos) {
    // Outer halo
    canvas.drawCircle(
      pos,
      16.0,
      Paint()..color = Colors.blue.withAlpha(50),
    );
    // Accuracy ring
    canvas.drawCircle(
      pos,
      10.0,
      Paint()
        ..color = Colors.blue.withAlpha(100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // White border
    canvas.drawCircle(pos, 8.0, Paint()..color = Colors.white);
    // Blue fill
    canvas.drawCircle(pos, 6.5, Paint()..color = Colors.blue);
  }

  void _drawPinMarker(Canvas canvas, Offset pos, Color color) {
    const double pinHeight = 30.0;
    const double headRadius = 10.0;
    final double headCenterY = pos.dy - pinHeight + headRadius;

    // Shadow
    canvas.drawPath(
      Path()
        ..addOval(Rect.fromCenter(
            center: Offset(pos.dx, pos.dy + 1),
            width: headRadius * 1.2,
            height: headRadius / 2)),
      Paint()..color = Colors.black.withAlpha(76),
    );

    // Pin body
    final pinPath = Path();
    pinPath.moveTo(pos.dx, pos.dy);
    pinPath.cubicTo(
      pos.dx - headRadius * 0.7, pos.dy - pinHeight * 0.4,
      pos.dx - headRadius, headCenterY - headRadius * 0.5,
      pos.dx - headRadius, headCenterY,
    );
    pinPath.arcTo(
      Rect.fromCircle(center: Offset(pos.dx, headCenterY), radius: headRadius),
      math.pi, math.pi, false,
    );
    pinPath.cubicTo(
      pos.dx + headRadius, headCenterY - headRadius * 0.5,
      pos.dx + headRadius * 0.7, pos.dy - pinHeight * 0.4,
      pos.dx, pos.dy,
    );
    pinPath.close();
    canvas.drawPath(pinPath, Paint()..color = color);
    canvas.drawCircle(Offset(pos.dx, headCenterY), headRadius / 2.5, Paint()..color = Colors.white);
  }

  void _drawDashedPath(Canvas canvas, ui.Path path, Paint paint, double dashWidth, double dashSpace) {
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return oldDelegate.path != path ||
        oldDelegate.mapImage != mapImage ||
        oldDelegate.livePosition != livePosition ||
        oldDelegate.endNode != endNode;
  }
}
