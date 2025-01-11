// Copyright (c) 2020-2025 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// An enumeration of common coordinate reference system (CRS) types.
enum CoordRefSysType {
  /// Geographic Coordinate Systems (GCS)
  ///
  /// Geographic coordinate systems are used to define locations on the Earth
  /// based on the ellipsoidal Earth model. Coordinates are given as latitude
  /// and longitude angles.
  ///
  /// For example
  /// [World Geodetic System 1984[https://en.wikipedia.org/wiki/World_Geodetic_System#WGS_84]
  /// (WGS 84) positions are commonly represented using geographic coordinates.
  geographic,

  /// Geocentric Coordinate Systems
  ///
  /// Also known as
  /// [Earth-Centered, Earth-Fixed (ECEF)](https://en.wikipedia.org/wiki/Earth-centered,_Earth-fixed_coordinate_system)
  /// systems using three-dimensional Cartesian coordinates (X, Y, Z) centered
  /// at the Earth's center of mass.
  ///
  /// Examples: ITRF (International Terrestrial Reference Frame). The current
  /// realization of WGS 84 geocentric cartesian coordinates is aligned with
  /// ITRF within a few centimeters.
  geocentric,

  /// Projected Coordinate Systems (PCS)
  ///
  /// Geographic coordinates are projected onto a flat, two-dimensional surface
  /// using a map projection using a Cartesian coordinate system based on planar
  /// coordinates (e.g., meters, feet).
  ///
  /// For example
  /// [Universal Transverse Mercator](https://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system)
  /// (UTM) divides the Earth into 60 zones, each with its own transverse
  /// Mercator projection (6° wide in longitude).
  projected,

  /// Vertical Coordinate Systems
  ///
  /// These systems are used to measure heights or depths relative to a
  /// reference surface, such as mean sea level or a geoid model.
  ///
  /// For example
  /// [Earth Gravitation Model](https://en.wikipedia.org/wiki/Earth_Gravitational_Model)
  /// (EGM) models are used to define vertical datums.
  vertical,

  /// Engineering Coordinate Systems
  ///
  /// These are local coordinate systems used for specific engineering projects.
  /// They are often defined by a plane coordinate system and may not be based
  /// on a global reference frame.
  engineering,

  /// Compound Coordinate Systems
  ///
  /// These systems combine two or more different types of coordinate reference
  /// systems to create a multi-dimensional system. Typically, a compound
  /// coordinate system will include both horizontal and vertical components.
  ///
  /// Example: Combining a geographic coordinate system with a vertical
  /// coordinate system.
  compound;

  /// Returns true if this CRS type is geographic or geocentric.
  bool get isGeographicOrGeocentric => this == geographic || this == geocentric;

  /// Returns true if this CRS type is geographic or projected.
  bool get isGeographicOrProjected => this == geographic || this == projected;

  /// Returns true if this CRS type is geographic.
  bool get isGeographic => this == geographic;

  /// Returns true if this CRS type is geocentric.
  bool get isGeocentric => this == geocentric;

  /// Returns true if this CRS type is projected.
  bool get isProjected => this == projected;

  /// Returns true if this CRS type is vertical.
  bool get isVertical => this == vertical;

  /// Returns true if this CRS type is engineering.
  bool get isEngineering => this == engineering;

  /// Returns true if this CRS type is compound.
  bool get isCompound => this == compound;
}
