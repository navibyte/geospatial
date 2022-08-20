// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:typed_data';

import 'package:geobase/src/utils/byte_reader.dart';
import 'package:geobase/src/utils/byte_writer.dart';

import 'package:test/test.dart';

void main() {
  group('Byte writer and reader', () {
    final endians = [Endian.big, Endian.little];
    final bufferSizes = [4, 128, 2048];
    final sampleInts = [0, 1, -2, 97, -83];
    final sampleDoubles = [0.0, 1.238577237, -423.2, 97e12, -83899.22323];

    for (final endian in endians) {
      for (final bufferSize in bufferSizes) {
        test('Write and read bytes', () {
          // write bytes using ByteWriter
          final writer =
              ByteWriter.buffered(endian: endian, bufferSize: bufferSize);
          for (final sample in sampleInts) {
            writer
              ..writeInt8(sample)
              ..writeInt16(sample)
              ..writeInt16(sample * 234)
              ..writeInt32(sample)
              ..writeInt32(sample * 63423)
              ..writeInt64(sample)
              ..writeInt64(sample * 1283455)
              ..writeUint8(sample.abs())
              ..writeUint16(sample.abs())
              ..writeUint16((sample * 62).abs())
              ..writeUint32(sample.abs())
              ..writeUint32((sample * 61983).abs())
              ..writeUint64(sample.abs())
              ..writeUint64((sample * 8473443).abs());
          }
          for (final sample in sampleDoubles) {
            writer
              ..writeFloat32(sample)
              ..writeFloat64(sample);
          }

          // get bytes as Uint8List
          final bytes = writer.toBytes();

          // read bytes using ByteReader
          final reader = ByteReader.view(bytes, endian: endian);
          for (final sample in sampleInts) {
            expect(reader.readInt8(), sample);
            expect(reader.readInt16(), sample);
            expect(reader.readInt16(), sample * 234);
            expect(reader.readInt32(), sample);
            expect(reader.readInt32(), sample * 63423);
            expect(reader.readInt64(), sample);
            expect(reader.readInt64(), sample * 1283455);
            expect(reader.readUint8(), sample.abs());
            expect(reader.readUint16(), sample.abs());
            expect(reader.readUint16(), (sample * 62).abs());
            expect(reader.readUint32(), sample.abs());
            expect(reader.readUint32(), (sample * 61983).abs());
            expect(reader.readUint64(), sample.abs());
            expect(reader.readUint64(), (sample * 8473443).abs());
          }
          for (final sample in sampleDoubles) {
            expect(
              reader.readFloat32(),
              closeTo(sample, (sample / 10e6).abs()),
            );
            expect(reader.readFloat64(), sample);
          }
        });
      }
    }
  });
}
