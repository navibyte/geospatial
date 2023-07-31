// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A failure type for failures that could occur when accessing features.
enum FeatureFailure {
  /// An error occurred on the client side.
  clientError,

  /// A query failed for undefined reasons.
  queryFailed,

  /// A service returned `Found` (ie. HTTP 302) for a query.
  ///
  /// OGC API Common: "The target resource was found but resides temporarily
  /// under a different URI. A 302 response is not evidence that the operation
  /// has been successfully completed."
  found,

  /// A service returned `See Other` (ie. HTTP 303) for a query.
  ///
  /// OGC API Common: "The server is redirecting the user agent to a different
  /// resource. A 303 response is not evidence that the operation has been
  /// successfully completed.""
  seeOther,

  /// A service returned `Not Modified` (ie. HTTP 304) for a query.
  ///
  /// OGC API Common: "An entity tag was provided in the request and the
  /// resource has not changed since the previous request."
  notModified,

  /// A service returned `Temporary Redirect` (ie. HTTP 307) for a query.
  ///
  /// OGC API Common: "The target resource resides temporarily under a different
  /// URI and the user agent MUST NOT change the request method if it performs
  /// an automatic redirection to that URI."
  temporaryRedirect,

  /// A service returned `Permanent Redirect` (ie. HTTP 308) for a query.
  ///
  /// OGC API Common: "Indicates that the target resource has been assigned a
  /// new permanent URI and any future references to this resource ought to use
  /// one of the enclosed URIs."
  permanentRedirect,

  /// A service returned `Bad Request` (ie. HTTP 400) for a query.
  ///
  /// OGC API Common: The server cannot or will not process the request due to
  /// an apparent client error. For example, a query parameter had an incorrect
  /// value."
  badRequest,

  /// A service returned `Unauthorized` (ie. HTTP 401) for a query.
  ///
  /// OGC API Common: "The request requires user authentication. The response
  /// includes a WWW-Authenticate header field containing a challenge applicable
  /// to the requested resource."
  unauthorized,

  /// A service returned `Forbidden` (ie. HTTP 403) for a query.
  ///
  /// OGC API Common: "The server understood the request, but is refusing to
  /// fulfill it. While status code 401 indicates missing or bad authentication,
  /// status code 403 indicates that authentication is not the issue, but the
  /// client is not authorized to perform the requested operation on the
  /// resource."
  forbidden,

  /// A service returned `Not Found` (ie. HTTP 404) for a query.
  ///
  /// OGC API Common: "The requested resource does not exist on the server. For
  /// example, a path parameter had an incorrect value."
  notFound,

  /// A service returned `Method Not Allowed` (ie. HTTP 405) for a query.
  ///
  /// OGC API Common "The request method is not supported. For example, a POST
  /// request was submitted, but the resource only supports GET requests."
  methodNotAllowed,

  /// A service returned `Not Acceptable` (ie. HTTP 406) for a query.
  ///
  /// OGC API Common: "Content negotiation failed. For example, the Accept
  /// header submitted in the request did not support any of the media types
  /// supported by the server for the requested resource."
  notAcceptable,

  /// A service returned `Internal Server Error` (ie. HTTP 500) for a query.
  ///
  /// OGC API Common: "An internal error occurred in the server."
  internalServerError,
}
