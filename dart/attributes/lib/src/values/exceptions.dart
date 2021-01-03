// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// A [FormatException] notifying about undefined value.
class UndefinedValueException extends FormatException {
  const UndefinedValueException() : super('Value is undefined.');
}

/// A [FormatException] notifying about null value.
class NullValueException extends FormatException {
  const NullValueException() : super('Value is null.');
}

/// A [FormatException] notifying about unsupported converion.
class ConversionException extends FormatException {
  const ConversionException({dynamic data, required Type target})
      : super(
            'Unsupported conversion to $target or invalid source data.', data);
}
