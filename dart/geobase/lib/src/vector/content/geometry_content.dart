// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/coordinates/base.dart';

import 'simple_geometry_content.dart';

/// A function to write geometry data to [output].
typedef WriteGeometries = void Function(GeometryContent output);

/// An interface to write geometry data to format encoders and object builders.
///
/// This mixin supports specific simple geometry types defined by
/// [SimpleGeometryContent]. It's possible that in future other geometry types
/// are added to be supported.
///
/// Coordinate positions are represented either as [Position] or
/// `Iterable<num>`. Bounding boxes are represented either as [Box] or
/// `Iterable<num>`.
mixin GeometryContent implements SimpleGeometryContent {}
