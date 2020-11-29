// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import 'package:geocore/meta.dart';

/// Metadata container for links.
abstract class LinksMeta {
  const LinksMeta();

  /// Metadata container for links from a given iteratable.
  factory LinksMeta.all(Iterable<Link> all) = LinksMetaBase;

  /// Metadata container for links from JSON objects.
  factory LinksMeta.fromJson(List json) =>
      LinksMeta.all(json.map((e) => Link.fromJson(e)));

  /// All links iterated.
  Iterable<Link> get all;

  /// The first link matched by the given [rel] or null if no link found.
  ///
  /// An optional [type] can specify link (content) type.
  Link? byRel(String rel, {String? type});

  /// First link with "rel" matching "self" or null if no link found.
  ///
  /// An optional [type] can specify link (content) type.
  Link? self({String? type}) => byRel('self', type: type);

  /// First link with "rel" matching "service-desc" or null if no link found.
  ///
  /// An optional [type] can specify link (content) type.
  Link? serviceDesc({String? type}) => byRel('service-desc', type: type);
}

/// Base implementation of the [LinksMeta].
@immutable
class LinksMetaBase extends LinksMeta with EquatableMixin {
  const LinksMetaBase(this.all);

  @override
  final Iterable<Link> all;

  @override
  Link? byRel(String rel, {String? type}) {
    try {
      return all
          .firstWhere((e) => e.rel == rel && (type == null || e.type == type));
    } on StateError {
      // firstWhere did not found nothing, throws, but we wanna retun null!
      return null;
    }
  }

  @override
  List<Object?> get props => [all];
}

/*

Todo check these:

  http://docs.opengeospatial.org/DRAFTS/20-024.html

6.2. Link relations
RFC 8288 (Web Linking) is used to express relationships between resources. 
Link relation types from the IANA Link Relations Registry are used wherever 
possible. Additional link relation types are registered with the OGC Naming 
Authority.

The following link-relations are useed by this OGC Standard.

alternate: Refers to a substitute for this context. [IANA]

collection: The target IRI points to a resource which represents the collection resource for the context IRI. [IANA]

conformance: Refers to a resource that identifies the specifications that the link’s context conforms to. [OGC]

data: Indicates that the link’s context is a distribution of a dataset that is an API and refers to the root resource of the dataset in an API. [OGC]

describedBy: Refers to a resource providing information about the link’s context. [IANA]

item: The target IRI points to a resource that is a member of the collection represented by the context IRI. [IANA]

items: Refers to a resource that is comprised of members of the collection represented by the link’s context. [OGC]

license: Refers to a license associated with this context. [IANA]

self: Conveys an identifier for the link’s context. [IANA]

service-desc: Identifies service description for the context that is primarily intended for consumption by machines. [IANA]

API definitions are considered service descriptions.

service-doc: Identifies service documentation for the context that is primarily intended for human consumption. [IANA]


Or some stuff

http://docs.opengeospatial.org/is/17-069r3/17-069r3.html

The following registered link relation types are used in this document.

alternate: Refers to a substitute for this context.

collection: The target IRI points to a resource which represents the collection resource for the context IRI.

describedBy: Refers to a resource providing information about the link’s context.

item: The target IRI points to a resource that is a member of the collection represented by the context IRI.

next: Indicates that the link’s context is a part of a series, and that the next in the series is the link target.

license: Refers to a license associated with this context.

prev: Indicates that the link’s context is a part of a series, and that the previous in the series is the link target.

This relation is only used in examples.

self: Conveys an identifier for the link’s context.

service-desc: Identifies service description for the context that is primarily intended for consumption by machines.

API definitions are considered service descriptions.

service-doc: Identifies service documentation for the context that is primarily intended for human consumption.
  */
