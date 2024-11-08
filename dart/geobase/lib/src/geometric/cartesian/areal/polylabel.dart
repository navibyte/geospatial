// Ported from: https://github.com/mapbox/polylabel/blob/master/polylabel.js
//              https://github.com/mapbox/polylabel/blob/master/LICENSE

/*
ISC License
Copyright (c) 2016 Mapbox

Permission to use, copy, modify, and/or distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND ISC DISCLAIMS ALL WARRANTIES WITH REGARD TO
THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS.
IN NO EVENT SHALL ISC BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
SOFTWARE.
*/

// Adaptations on the derivative work (the Dart port):
//
// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore_for_file: avoid_print

part of 'cartesian_areal_extension.dart';

DistancedPosition _polylabel2D(
  Iterable<PositionSeries> polygon, {
  double precision = 1.0,
  bool debug = false,
  PositionScheme scheme = Position.scheme,
}) {
  // find the bounding box of the outer ring
  var minX = double.infinity;
  var minY = double.infinity;
  var maxX = -double.infinity;
  var maxY = -double.infinity;

  final outer = polygon.first; // the first ring on iterable is the outer ring
  for (var i = 0, len = outer.positionCount; i < len; i++) {
    final x = outer.x(i);
    final y = outer.y(i);
    if (x < minX) minX = x;
    if (y < minY) minY = y;
    if (x > maxX) maxX = x;
    if (y > maxY) maxY = y;
  }

  final width = maxX - minX;
  final height = maxY - minY;
  final cellSize = math.max(precision, math.min(width, height));

  if (cellSize == precision) {
    return DistancedPosition(scheme.position(x: minX, y: minY), 0.0);
  }

  // a priority queue of cells in order of their "potential" (max distance to
  // polygon)
  final cellQueue = TinyQueue<_Cell>([], (a, b) => b.max.compareTo(a.max));

  // take centroid as the first best guess
  var bestCell = _getCentroidCell(polygon);

  // second guess: bounding box centroid
  final bboxCell = _Cell(minX + width / 2.0, minY + height / 2.0, 0.0, polygon);
  if (bboxCell.d > bestCell.d) {
    bestCell = bboxCell;
  }

  var numProbes = 2;

  void potentiallyQueue(double x, double y, double h) {
    final cell = _Cell(x, y, h, polygon);
    numProbes++;
    if (cell.max > bestCell.d + precision) {
      cellQueue.push(cell);
    }

    // update the best cell if we found a better one
    if (cell.d > bestCell.d) {
      bestCell = cell;
      if (debug) {
        print('found best ${(1e4 * cell.d).round() / 1e4}'
            ' after $numProbes probes');
      }
    }
  }

  // cover polygon with initial cells
  var h = cellSize / 2.0;
  for (var x = minX; x < maxX; x += cellSize) {
    for (var y = minY; y < maxY; y += cellSize) {
      potentiallyQueue(x + h, y + h, h);
    }
  }

  // pop : pick the most promising cell from the queue
  _Cell? promising;
  while ((promising = cellQueue.pop()) != null) {
    if (promising == null) break;

    // do not drill down further if there's no chance of a better solution
    if (promising.max - bestCell.d <= precision) {
      break;
    }

    // split the cell into four cells
    h = promising.h / 2.0;
    potentiallyQueue(promising.x - h, promising.y - h, h);
    potentiallyQueue(promising.x + h, promising.y - h, h);
    potentiallyQueue(promising.x - h, promising.y + h, h);
    potentiallyQueue(promising.x + h, promising.y + h, h);
  }

  if (debug) {
    print('num probes: $numProbes\nbest distance: ${bestCell.d}');
  }

  return DistancedPosition(
    scheme.position(x: bestCell.x, y: bestCell.y),
    bestCell.d,
  );
}

class _Cell {
  /// Cell center x.
  double x;

  /// Cell center y.
  double y;

  /// Half the cell size.
  double h;

  /// Distance from cell center to polygon.
  late double d;

  /// Max distance to polygon within a cell.
  late double max;

  _Cell(this.x, this.y, this.h, Iterable<PositionSeries> polygon) {
    // distance from cell center to polygon
    d = _pointToPolygonDist(x, y, polygon);

    // max distance to polygon within a cell
    max = d + h * math.sqrt2;
  }
}

/// Signed distance from point to polygon outline (negative if point is
/// outside).
double _pointToPolygonDist(
  double x,
  double y,
  Iterable<PositionSeries> polygon,
) {
  var inside = false;
  var minDistSq = double.infinity;

  for (final ring in polygon) {
    for (var i = 0, len = ring.positionCount, j = len - 1; i < len; j = i++) {
      final a = ring[i];
      final b = ring[j];

      if ((a.y > y != b.y > y) &&
          (x < (b.x - a.x) * (y - a.y) / (b.y - a.y) + a.x)) {
        inside = !inside;
      }

      minDistSq = math.min(minDistSq, _getSegDistSq(x, y, a, b));
    }
  }

  return minDistSq == 0.0 ? 0.0 : (inside ? 1.0 : -1.0) * math.sqrt(minDistSq);
}

/// Get polygon centroid.
_Cell _getCentroidCell(Iterable<PositionSeries> polygon) {
  var area = 0.0;
  var x = 0.0;
  var y = 0.0;
  final points = polygon.first;

  for (var i = 0, len = points.positionCount, j = len - 1; i < len; j = i++) {
    final a = points[i];
    final b = points[j];
    final f = a.x * b.y - b.x * a.y;
    x += (a.x + b.x) * f;
    y += (a.y + b.y) * f;
    area += f * 3;
  }
  final centroid = _Cell(x / area, y / area, 0.0, polygon);
  if (area == 0.0 || centroid.d < 0.0) {
    return _Cell(points[0].x, points[0].y, 0.0, polygon);
  }
  return centroid;
}

/// Get squared distance from a point to a segment.
double _getSegDistSq(double px, double py, Position a, Position b) {
  var x = a.x;
  var y = a.y;
  var dx = b.x - x;
  var dy = b.y - y;

  if (dx != 0.0 || dy != 0.0) {
    final t = ((px - x) * dx + (py - y) * dy) / (dx * dx + dy * dy);

    if (t > 1.0) {
      x = b.x;
      y = b.y;
    } else if (t > 0.0) {
      x += dx * t;
      y += dy * t;
    }
  }

  dx = px - x;
  dy = py - y;

  return dx * dx + dy * dy;
}
