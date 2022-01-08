// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'base_geometry.dart';

/// A function to transform the [source] point of [T] to a point of [T].
///
/// Target points of [T] are created using [source] itself as a point factory.
///
/// Throws FormatException if cannot transform.
typedef TransformPoint = T Function<T extends Point>(T source);
