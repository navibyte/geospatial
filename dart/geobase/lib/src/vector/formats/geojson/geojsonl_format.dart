// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

part of 'geojson_format.dart';

/// The newline-delimited GeoJSON (or "GeoJSON Text Sequences") text format for
/// [feature] objects.
///
/// Supports a text file with each line containing exactly one feature. Features
/// are delimited by line feeds, not commas. A text file represents a feature
/// collection, but no "FeatureCollection" element is encoded.
///
/// Features in a sequence can be separated by (supported when decoding):
/// * a newline (LF) character, see
///   [Newline Delimited JSON](http://ndjson.org/)
/// * a record-separator (RS) character, see
///   [RFC 8142 standard: GeoJSON Text Sequences](https://tools.ietf.org/html/rfc8142)
///
/// For encoding this implementation uses newline (LF) character as a delimiter
/// by default. To customize encoder output you can use `options` named
/// `GeoJSONL.delimiterBefore` and `GeoJSONL.delimiterAfter` taking values of
/// `String?`.
///
/// Other references:
/// * [NDJSON - Newline delimited JSON](https://github.com/ndjson/ndjson-spec)
/// * GDAL: [GeoJSONSeq: sequence of GeoJSON features](https://gdal.org/drivers/vector/geojsonseq.html)
/// * Interline: [Even more geospatial tools supporting the "GeoJSONL" format](https://www.interline.io/blog/here-cli-supports-geojsonl/)
/// * Steve Bennet: [Newline-delimited GeoJSON](https://stevage.github.io/ndgeojson/)
/// * [JSON Lines](https://jsonlines.org/)
/// * [JSON Lines format: Why jsonl is what you need for data streams?](https://dbconvert.com/blog/json-lines-data-stream/)
/// * [JavaScript Object Notation (JSON) Text Sequences](https://tools.ietf.org/html/rfc7464)
///
/// See also the [GeoJSON] format for traditional GeoJSON decoding / encoding.
class GeoJSONL {
  /// The content type (`application/x-ndjson`) for "Newline delimited JSON"
  /// by the specification
  /// [NDJSON - Newline delimited JSON](https://github.com/ndjson/ndjson-spec).
  static const contentTypeNDJSON = 'application/x-ndjson';

  /// The content type (`application/geo+json-seq`) for GeoJSON Text Sequences
  /// by [RFC 8142](https://tools.ietf.org/html/rfc8142).
  static const contentTypeGeoJSONSeq = 'application/geo+json-seq';

  /// The content type (`application/json-seq`) for JSON Text Sequences
  /// by [RFC 7464](https://tools.ietf.org/html/rfc7464).
  static const contentTypeJSONSeq = 'application/json-seq';

  // application/jsonl

  /// The newline-delimited GeoJSON text format (encoding and decoding) for
  /// feature objects.
  static const TextFormat<FeatureContent> feature =
      _GeoJsonLFeatureTextFormat();

  /// The newline-delimited GeoJSON text format (encoding and decoding) for
  /// feature objects with optional [conf].
  static TextFormat<FeatureContent> featureFormat({GeoJsonConf? conf}) =>
      _GeoJsonLFeatureTextFormat(conf: conf);
}

class _GeoJsonLFeatureTextFormat with TextFormat<FeatureContent> {
  const _GeoJsonLFeatureTextFormat({this.conf});

  final GeoJsonConf? conf;

  @override
  ContentDecoder decoder(
    FeatureContent builder, {
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      _GeoJsonLFeatureTextDecoder(
        builder,
        crs: crs,
        options: options,
        conf: conf,
      );

  @override
  ContentEncoder<FeatureContent> encoder({
    StringSink? buffer,
    int? decimals,
    CoordRefSys? crs,
    Map<String, dynamic>? options,
  }) =>
      _GeoJsonLFeatureTexEncoder(
        buffer: buffer,
        decimals: decimals,
        crs: crs,
        options: options,
        conf: conf,
      );
}

class _GeoJsonLFeatureTextDecoder implements ContentDecoder {
  // NOTE: this is an adapted version of _GeoJsonFeatureTextDecoder located in
  //       geojson_decoder.dart - both have some common code that should be
  //       kept in sync when changing code

  final FeatureContent builder;
  final CoordRefSys? crs;
  final Map<String, dynamic>? options;
  final GeoJsonConf? conf;

  _GeoJsonLFeatureTextDecoder(
    this.builder, {
    this.crs,
    this.options,
    this.conf,
  });

  @override
  void decodeBytes(Uint8List source) => decodeText(utf8.decode(source));

  @override
  void decodeText(String source) => decodeData(_parseLines(source));

  @override
  void decodeData(dynamic source) {
    try {
      // expect source as a list of string objects each containing a feature
      // (in GeoJSONL each feature is separately encoded as GeoJSON)
      final root = source as Iterable<String>;

      // swap x and y if CRS has y-x (lat-lon) order (and logic is auth based)
      final swapXY = crs?.swapXY(logic: conf?.crsLogic) ?? false;

      // if true coordinate values parsed are stored in Float32, not Float64
      final singlePrecision = conf?.singlePrecision ?? false;

      // whether to ignore custom (or foreign) members on Features or
      // FeatureCollections
      final ignoreCustom = conf?.ignoreForeignMembers ?? false;

      // optional parameters allowing getting only a range of features
      final opt = options;
      final itemOffset = opt != null ? opt['itemOffset'] as int? : null;
      final itemLimit = opt != null ? opt['itemLimit'] as int? : null;

      // optionally skip first features
      final skipped = itemOffset != null ? root.skip(itemOffset) : root;

      // optinally limit number of feature to be returned
      final limited = itemLimit != null ? skipped.take(itemLimit) : skipped;

      // build a single feature collection with features from source populated
      builder.featureCollection(
        (featureBuilder) {
          for (final featureJson in limited) {
            final feature = json.decode(featureJson) as Map<String, dynamic>;
            _decodeFeature(
              feature,
              featureBuilder,
              swapXY: swapXY,
              singlePrecision: singlePrecision,
              ignoreCustom: ignoreCustom,
            );
          }
        },
      );
    } on FormatException {
      rethrow;
    } catch (err) {
      // Errors might occur when casting invalid data from external sources.
      // We want to throw FormatException to clients however.
      throw FormatException('Not valid GeoJSONL data (error: $err)');
    }
  }
}

Iterable<String> _parseLines(String source) sync* {
  final len = source.length;
  var start = 0;
  var end = 0;

  while (start < len) {
    // move start forward as long as line separators found
    while (start < len && _isLineSeparator(source[start])) {
      start++;
    }
    if (start >= len) break;

    // move end to next line separator or end of string
    end = start;
    while (end < len && !_isLineSeparator(source[end])) {
      end++;
    }

    // yield a line if not empty
    if (end > start) {
      final line = source.substring(start, end).trim();
      if (line.isNotEmpty) {
        yield line;
      }
    }

    // go to next line
    start = end;
  }
}

// https://github.com/ndjson/ndjson-spec
//   The parser MUST accept newline as line delimiter \n (0x0A) as well as
//   carriage return and newline \r\n (0x0D0A).
//
// https://datatracker.ietf.org/doc/html/rfc8142
//   Defined in prose similar to the description of the JSON text sequence in
//   [RFC7464], a GeoJSON text sequence is any number of GeoJSON [RFC7946]
//   texts, each encoded in UTF-8 [RFC3629], preceded by one ASCII [RFC20]
//   record separator (RS) character, and followed by a line feed (LF).
bool _isLineSeparator(String s) =>
    // line feed (LF) - 0x0A
    s == '\n' ||
    // carriage return (CR) - 0x0D
    s == '\r' ||
    // record separator (RS) - 0x1E
    s == '\u{1e}';

class _GeoJsonLFeatureTexEncoder
    with FeatureContent
    implements ContentEncoder<FeatureContent> {
  final int? decimals;
  final CoordRefSys? crs;
  final GeoJsonConf? conf;

  late final StringSink _buffer;
  late final String? _delimiterBefore;
  late final String _delimiterAfter;

  _GeoJsonLFeatureTexEncoder({
    StringSink? buffer,
    this.decimals,
    this.crs,
    Map<String, dynamic>? options,
    this.conf,
  }) {
    _buffer = buffer ?? StringBuffer();

    // by default no delimiter before a feature text, but `\n` after a feature
    final o = options;
    _delimiterBefore =
        o != null ? o['GeoJSONL.delimiterBefore'] as String? : null;
    _delimiterAfter =
        (o != null ? o['GeoJSONL.delimiterAfter'] as String? : null) ?? '\n';
  }

  @override
  FeatureContent get writer => this;

  @override
  void featureCollection(
    WriteFeatures features, {
    int? count,
    Box? bounds,
    Map<String, dynamic>? custom,
  }) {
    features.call(this);
  }

  @override
  void feature({
    Object? id,
    WriteGeometries? geometry,
    Map<String, dynamic>? properties,
    Box? bounds,
    Map<String, dynamic>? custom,
  }) {
    if (_delimiterBefore != null) {
      _buffer.write(_delimiterBefore);
    }

    GeoJsonTextWriter<FeatureContent>(
      buffer: _buffer,
      decimals: decimals,
      crs: crs,
      conf: conf,
    ).feature(
      id: id,
      geometry: geometry,
      properties: properties,
      bounds: bounds,
      custom: custom,
    );

    _buffer.write(_delimiterAfter);
  }

  @override
  Uint8List toBytes() => Uint8List.fromList(utf8.encode(toText()));

  @override
  String toText() => _buffer.toString();

  @override
  String toString() => toText();
}
