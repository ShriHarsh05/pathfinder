import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pathfinder_indoor_navigation/data/campus_paths.dart';

class PathPointInfo {
  final LatLng point;
  final int pathIndex;
  final int pointIndex;

  PathPointInfo(this.point, this.pathIndex, this.pointIndex);
}

PathPointInfo? findNearestPointOnPaths(LatLng point) {
  PathPointInfo? nearestPointInfo;
  double minDistance = double.infinity;

  for (int i = 0; i < campusPaths.length; i++) {
    for (int j = 0; j < campusPaths[i].length; j++) {
      final pathPoint = campusPaths[i][j];
      final distance = _calculateDistance(point, pathPoint);

      if (distance < minDistance) {
        minDistance = distance;
        nearestPointInfo = PathPointInfo(pathPoint, i, j);
      }
    }
  }
  return nearestPointInfo;
}

List<LatLng> getPathSegment(PathPointInfo start, PathPointInfo end) {
  if (start.pathIndex != end.pathIndex) {
    return [start.point, end.point];
  }

  final path = campusPaths[start.pathIndex];
  if (start.pointIndex <= end.pointIndex) {
    return path.sublist(start.pointIndex, end.pointIndex + 1);
  } else {
    return path.sublist(end.pointIndex, start.pointIndex + 1).reversed.toList();
  }
}

double _calculateDistance(LatLng p1, LatLng p2) {
  const R = 6371e3; // metres
  final phi1 = p1.latitude * pi / 180;
  final phi2 = p2.latitude * pi / 180;
  final deltaPhi = (p2.latitude - p1.latitude) * pi / 180;
  final deltaLambda = (p2.longitude - p1.longitude) * pi / 180;

  final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
      cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c; // in metres
}