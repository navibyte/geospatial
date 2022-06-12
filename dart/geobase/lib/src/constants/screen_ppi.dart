// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// OGC defines a screen pixel of 0.28 mm that approximates to 90.7 ppi.
///
/// OGC specifies: `pixelResolution = 0.00028 * scaleDenominator` that gives
/// `scaleDenominator = pixelResolution / 0.00028`.
///
/// Another way to calculate a scale denominator:
/// `scaleDenominator = pixelResolution * screenPPI / 0.0254`
///
/// This constant: `screenPPIbyOGC = 0.0254 / 0.00028`
///
/// Abbreviations:
/// * PPI = pixels per inch
/// * OGC = The Open Geospatial Consortium
const screenPPIbyOGC = 0.0254 / 0.00028;
