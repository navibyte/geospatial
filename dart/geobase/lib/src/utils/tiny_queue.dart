// Ported from: https://github.com/mourner/tinyqueue/blob/main/index.js
//              https://github.com/mourner/tinyqueue/blob/main/LICENSE

/*
ISC License

Copyright (c) 2017, Vladimir Agafonkin

Permission to use, copy, modify, and/or distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.
*/

// Adaptations on the derivative work (the Dart port):
//
// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

@internal
class TinyQueue<E> {
  final List<E> _data;
  final Comparator<E> _compare;
  late int _length;

  TinyQueue(this._data, this._compare) {
    _length = _data.length;

    if (_length > 0) {
      for (var i = (_length >> 1) - 1; i >= 0; i--) {
        _down(i);
      }
    }
  }

  // push
  void push(E item) {
    _data.add(item);
    _up(_length++);
  }

  // pop
  E? pop() {
    if (_length == 0) return null;

    final top = _data[0];
    final bottom = _data.removeLast();

    if (--_length > 0) {
      _data[0] = bottom;
      _down(0);
    }

    return top;
  }

  // peek
  E get peek => _data[0];

  void _up(int position) {
    var pos = position;
    final item = _data[pos];

    while (pos > 0) {
      final parent = (pos - 1) >> 1;
      final current = _data[parent];
      if (_compare(item, current) >= 0) break;
      _data[pos] = current;
      pos = parent;
    }

    _data[pos] = item;
  }

  void _down(int position) {
    var pos = position;
    final halfLength = _length >> 1;
    final item = _data[pos];

    while (pos < halfLength) {
      var bestChild = (pos << 1) + 1; // initially it is the left child
      final right = bestChild + 1;

      if (right < _length && _compare(_data[right], _data[bestChild]) < 0) {
        bestChild = right;
      }
      if (_compare(_data[bestChild], item) >= 0) break;

      _data[pos] = _data[bestChild];
      pos = bestChild;
    }

    _data[pos] = item;
  }
}
