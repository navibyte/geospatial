// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An enum for spatial representations that can be used to code logic when
/// need to choose some options based on a representation.
///
/// The original use case for this enum is the problem of choosing the axis
/// order of coordinate values in position and point representations.
enum GeoRepresentation {
  /// The default representation of coordinates and geometries that represents
  /// coordinates in the axis order specified by an authority (like EPSG or
  /// OGC) in cases where order is not explicitely defined elsewhere.
  ///
  /// See also [geoJsonStrict].
  crsAuthority,

  /// The [GeoJSON](https://geojson.org/) representation of coordinates and
  /// geometries that always represents longitude (or easting) before latitude
  /// (or northing).
  ///
  /// According to the [specification](https://tools.ietf.org/html/rfc7946):
  ///
  /// "A position is an array of numbers.  There MUST be two or more
  /// elements. The first two elements are longitude and latitude, or
  /// easting and northing, precisely in that order and using decimal
  /// numbers.  Altitude or elevation MAY be included as an optional third
  /// element."
  ///
  /// "The coordinate reference system for all GeoJSON coordinates is a
  /// geographic coordinate reference system, using the World Geodetic
  /// System 1984 (WGS 84) datum, with longitude and latitude units
  /// of decimal degrees.  This is equivalent to the coordinate reference
  /// system identified by the Open Geospatial Consortium (OGC) URN
  /// urn:ogc:def:crs:OGC::CRS84. An OPTIONAL third-position element SHALL
  /// be the height in meters above or below the WGS 84 reference
  /// ellipsoid.  In the absence of elevation values, applications
  /// sensitive to height or depth SHOULD interpret positions as being at
  /// local ground or sea level."
  ///
  /// "Note: the use of alternative coordinate reference systems was
  /// specified in [GJ2008](http://geojson.org/geojson-spec.html), but it has
  /// been removed from this version of the specification because the use of
  /// different coordinate reference systems -- especially in the manner
  /// specified in [GJ2008](http://geojson.org/geojson-spec.html) -- has
  /// proven to have interoperability issues.  In general, GeoJSON
  /// processing software is not expected to have access to coordinate
  /// reference system databases or to have network access to coordinate
  /// reference system transformation parameters.  However, where all
  /// involved parties have a prior arrangement, alternative coordinate
  /// reference systems can be used without risk of data being
  /// misinterpreted."
  ///
  /// See also [crsAuthority].
  geoJsonStrict,

  // NOTE: currently no other enum values, to be extended in future
}
