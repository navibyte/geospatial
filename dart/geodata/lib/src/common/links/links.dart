// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';

import 'link.dart';

/// A metadata container for links.
///
/// See also IANA descriptions about common values for a link
/// [rel](https://www.iana.org/assignments/link-relations/link-relations.xhtml).
/// 
/// See also [OGC API Features](https://ogcapi.ogc.org/features/) standard
/// "Part 1: Core" section "5.2. Link relations" for reference.
@immutable
class Links with EquatableMixin {
  final List<Link> _items;

  /// Creates a metadata container for links as a view of [source].
  const Links(List<Link> source) : _items = source;

  /// Creates an empty metadata container for links.
  const Links.empty() : this(const []);

  /// Creates a metadata container for links from JSON data.
  ///
  /// Items of the [data] iterable are allowed to be `Map<String, dynamic>`
  /// (containing link attributes) or `String` (containing only a `href` part
  /// of a link).
  ///
  /// Throws `FormatException` if cannot parse data.
  factory Links.fromJson(Iterable<dynamic> data) => Links(
        data.map(Link.fromJson).toList(growable: false),
      );

  /// All links as a list.
  List<Link> get all => _items;

  @override
  List<Object?> get props => [all];

  /// All links matching by the given [rel], and optional [type] and [hreflang].
  Iterable<Link> byRel(String rel, {String? type, String? hreflang}) =>
      all.where(
        (e) =>
            e.rel == rel &&
            (type == null || e.type == type) &&
            (hreflang == null || e.hreflang == hreflang),
      );

  /// All links with `rel` matching `alternate`.
  ///
  /// IANA description: "Refers to a substitute for this context".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> alternate({String? type, String? hreflang}) =>
      byRel('alternate', type: type, hreflang: hreflang);

  /// All links with `rel` matching `canonical`.
  ///
  /// IANA description: "Designates the preferred version of a resource (the IRI
  /// and its contents)".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> canonical({String? type, String? hreflang}) =>
      byRel('canonical', type: type, hreflang: hreflang);

  /// All links with `rel` matching `collection`.
  ///
  /// IANA description: "The target IRI points to a resource which represents
  /// the collection resource for the context IRI".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> collection({String? type, String? hreflang}) =>
      byRel('collection', type: type, hreflang: hreflang);

  /// All links with `rel` matching `describedBy`.
  ///
  /// IANA description: "Refers to a resource providing information about the
  /// link's context".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> describedBy({String? type, String? hreflang}) =>
      byRel('describedBy', type: type, hreflang: hreflang);

  /// All links with `rel` matching `item`.
  ///
  /// IANA description: "The target IRI points to a resource that is a member of
  /// the collection represented by the context IRI".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> item({String? type, String? hreflang}) =>
      byRel('item', type: type, hreflang: hreflang);

  /// All links with `rel` matching `license`.
  ///
  /// IANA description: "Refers to a license associated with this context".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> license({String? type, String? hreflang}) =>
      byRel('license', type: type, hreflang: hreflang);

  /// All links with `rel` matching `next`.
  ///
  /// IANA description: "Indicates that the link's context is a part of
  /// a series, and that the next in the series is the link target".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> next({String? type, String? hreflang}) =>
      byRel('next', type: type, hreflang: hreflang);

  /// All links with `rel` matching `prev`.
  ///
  /// IANA description: "Indicates that the link's context is a part of
  /// a series, and that the previous in the series is the link target".
  /// 
  /// OGC API Features: "This relation is only used in examples".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> prev({String? type, String? hreflang}) =>
      byRel('prev', type: type, hreflang: hreflang);

  /// All links with `rel` matching `self`.
  ///
  /// IANA description: "Conveys an identifier for the link's context".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> self({String? type, String? hreflang}) =>
      byRel('self', type: type, hreflang: hreflang);

  /// All links with `rel` matching `service`.
  ///
  /// IANA description: "Indicates a URI that can be used to retrieve a service
  /// document".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> service({String? type, String? hreflang}) =>
      byRel('service', type: type, hreflang: hreflang);

  /// All links with `rel` matching `service-desc`.
  ///
  /// IANA description: "Identifies service description for the context that is
  /// primarily intended for consumption by machines".
  /// 
  /// OGC API Features: "API definitions are considered service descriptions".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> serviceDesc({String? type, String? hreflang}) =>
      byRel('service-desc', type: type, hreflang: hreflang);

  /// All links with `rel` matching `service-doc`.
  ///
  /// IANA description: "Identifies service documentation for the context that
  /// is primarily intended for human consumption".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> serviceDoc({String? type, String? hreflang}) =>
      byRel('service-doc', type: type, hreflang: hreflang);

  /// All links with `rel` matching `service-meta`.
  ///
  /// IANA description: "Identifies general metadata for the context that is
  /// primarily intended for consumption by machines".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> serviceMeta({String? type, String? hreflang}) =>
      byRel('service-meta', type: type, hreflang: hreflang);

  /// All links with `rel` matching `items`.
  ///
  /// OGC API Features: "Refers to a resource that is comprised of members of
  /// the collection represented by the link’s context".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> items({String? type, String? hreflang}) =>
      byRel('items', type: type, hreflang: hreflang);

  /// All links with `rel` matching `conformance`.
  ///
  /// OGC API Features: "Refers to a resource that identifies the specifications
  /// that the link’s context conforms to".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> conformance({String? type, String? hreflang}) =>
      byRel('conformance', type: type, hreflang: hreflang);

  /// All links with `rel` matching `data`.
  ///
  /// OGC API Features: "Refers to the root resource of a dataset in an API.".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> data({String? type, String? hreflang}) =>
      byRel('data', type: type, hreflang: hreflang);
}
