// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import 'link.dart';

/// Metadata container for links.
///
/// See also IANA descriptions about common values for a link
/// [rel](https://www.iana.org/assignments/link-relations/link-relations.xhtml).
abstract class Links {
  const Links();

  /// An empty metadata container for links.
  factory Links.empty() = _Links.empty;

  /// Metadata container for links as a view of [source].
  factory Links.view(Iterable<Link> source) = _Links;

  /// Metadata container for links from JSON objects.
  factory Links.fromJson(List json) =>
      Links.view(json.map((e) => Link.fromJson(e)));

  /// All links iterated.
  Iterable<Link> get all;

  /// All links matching by the given [rel], and optional [type] and [hreflang].
  Iterable<Link> byRel(String rel, {String? type, String? hreflang});

  /// All links with [rel] matching `alternate`.
  ///
  /// IANA description: "Refers to a substitute for this context".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> alternate({String? type, String? hreflang}) =>
      byRel('alternate', type: type, hreflang: hreflang);

  /// All links with [rel] matching `canonical`.
  ///
  /// IANA description: "Designates the preferred version of a resource (the IRI
  /// and its contents)".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> canonical({String? type, String? hreflang}) =>
      byRel('canonical', type: type, hreflang: hreflang);

  /// All links with [rel] matching `collection`.
  ///
  /// IANA description: "The target IRI points to a resource which represents
  /// the collection resource for the context IRI".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> collection({String? type, String? hreflang}) =>
      byRel('collection', type: type, hreflang: hreflang);

  /// All links with [rel] matching `describedBy`.
  ///
  /// IANA description: "Refers to a resource providing information about the
  /// link's context".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> describedBy({String? type, String? hreflang}) =>
      byRel('describedBy', type: type, hreflang: hreflang);

  /// All links with [rel] matching `item`.
  ///
  /// IANA description: "The target IRI points to a resource that is a member of
  /// the collection represented by the context IRI".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> item({String? type, String? hreflang}) =>
      byRel('item', type: type, hreflang: hreflang);

  /// All links with [rel] matching `license`.
  ///
  /// IANA description: "Refers to a license associated with this context".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> license({String? type, String? hreflang}) =>
      byRel('license', type: type, hreflang: hreflang);

  /// All links with [rel] matching `next`.
  ///
  /// IANA description: "Indicates that the link's context is a part of
  /// a series, and that the next in the series is the link target".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> next({String? type, String? hreflang}) =>
      byRel('next', type: type, hreflang: hreflang);

  /// All links with [rel] matching `prev`.
  ///
  /// IANA description: "Indicates that the link's context is a part of
  /// a series, and that the previous in the series is the link target".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> prev({String? type, String? hreflang}) =>
      byRel('prev', type: type, hreflang: hreflang);

  /// All links with [rel] matching `self`.
  ///
  /// IANA description: "Conveys an identifier for the link's context".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> self({String? type, String? hreflang}) =>
      byRel('self', type: type, hreflang: hreflang);

  /// All links with [rel] matching `service`.
  ///
  /// IANA description: "Indicates a URI that can be used to retrieve a service
  /// document".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> service({String? type, String? hreflang}) =>
      byRel('service', type: type, hreflang: hreflang);

  /// All links with [rel] matching `service-desc`.
  ///
  /// IANA description: "Identifies service description for the context that is
  /// primarily intended for consumption by machines".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> serviceDesc({String? type, String? hreflang}) =>
      byRel('service-desc', type: type, hreflang: hreflang);

  /// All links with [rel] matching `service-doc`.
  ///
  /// IANA description: "Identifies service documentation for the context that
  /// is primarily intended for human consumption".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> serviceDoc({String? type, String? hreflang}) =>
      byRel('service-doc', type: type, hreflang: hreflang);

  /// All links with [rel] matching `service-meta`.
  ///
  /// IANA description: "Identifies general metadata for the context that is
  /// primarily intended for consumption by machines".
  ///
  /// Optional [type] and [hreflang] params can specify links more precisely.
  Iterable<Link> serviceMeta({String? type, String? hreflang}) =>
      byRel('service-meta', type: type, hreflang: hreflang);
}

/// Private implementation of [Links].
/// The implementation may change in future.
@immutable
class _Links extends Links with EquatableMixin {
  const _Links(this.all);

  _Links.empty() : all = Iterable.empty();

  @override
  final Iterable<Link> all;

  @override
  Iterable<Link> byRel(String rel, {String? type, String? hreflang}) =>
      all.where((e) =>
          e.rel == rel &&
          (type == null || e.type == type) &&
          (hreflang == null || e.hreflang == hreflang));

  @override
  List<Object?> get props => [all];
}
