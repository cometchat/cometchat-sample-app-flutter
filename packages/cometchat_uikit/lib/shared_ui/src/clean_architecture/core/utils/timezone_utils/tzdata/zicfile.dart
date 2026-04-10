// Copyright (c) 2014, the timezone project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'dart:convert' show ascii;
import 'dart:typed_data';

/// Time Zone information file magic header "TZif"
const int _ziMagic = 1415211366;

/// tzfile header structure
class _Header {
  /// Header size
  static int size = 6 * 4;

  /// The number of UTC/local indicators stored in the file.
  final int tzhTTisGmtCount;

  /// The number of standard/wall indicators stored in the file.
  final int tzhTTisStdCount;

  /// The number of leap seconds for which data is stored in the file.
  final int tzhLeapCount;

  /// The number of "transition times" for which data is stored in the file.
  final int tzhTimeCount;

  /// The  number  of  "local  time types" for which data is stored in the file
  /// (must not be zero).
  final int tzhTypeCount;

  /// The number of characters of "timezone abbreviation strings" stored in the
  /// file.
  final int tzhCharCnt;

  _Header(this.tzhTTisGmtCount, this.tzhTTisStdCount, this.tzhLeapCount,
      this.tzhTimeCount, this.tzhTypeCount, this.tzhCharCnt);

  int dataLength(int longSize) {
    final leapBytes = tzhLeapCount * (longSize + 4);
    final timeBytes = tzhTimeCount * (longSize + 1);
    final typeBytes = tzhTypeCount * 6;

    return tzhTTisGmtCount +
        tzhTTisStdCount +
        leapBytes +
        timeBytes +
        typeBytes +
        tzhCharCnt;
  }

  factory _Header.fromBytes(List<int> rawData) {
    final data = rawData is Uint8List ? rawData : Uint8List.fromList(rawData);

    final bdata =
        data.buffer.asByteData(data.offsetInBytes, data.lengthInBytes);

    final tzhTtisgmtcnt = bdata.getInt32(0);
    final tzhTtisstdcnt = bdata.getInt32(4);
    final tzhLeapcnt = bdata.getInt32(8);
    final tzhTimecnt = bdata.getInt32(12);
    final tzhTypecnt = bdata.getInt32(16);
    final tzhCharcnt = bdata.getInt32(20);

    return _Header(tzhTtisgmtcnt, tzhTtisstdcnt, tzhLeapcnt, tzhTimecnt,
        tzhTypecnt, tzhCharcnt);
  }
}

/// Read NULL-terminated string
String _readByteString(Uint8List data, int offset) {
  for (var i = offset; i < data.length; i++) {
    if (data[i] == 0) {
      return ascii.decode(
          data.buffer.asUint8List(data.offsetInBytes + offset, i - offset));
    }
  }
  return ascii.decode(data.buffer.asUint8List(data.offsetInBytes + offset));
}

/// This exception is thrown when Zone Info data is invalid.
class InvalidZoneInfoDataException implements Exception {
  final String msg;

  InvalidZoneInfoDataException(this.msg);

  @override
  String toString() => msg;
}

/// TimeZone data
class TimeZone {
  /// Offset in seconds east of UTC.
  final int offset;

  /// DST time.
  final bool isDst;

  /// Index to abbreviation.
  final int abbreviationIndex;

  const TimeZone(this.offset,
      {required this.isDst, required this.abbreviationIndex});
}

/// Location data
class Location {
  /// [Location] name
  final String name;

  /// Time in seconds when the transitioning is occured.
  final List<int> transitionAt;

  /// Transition zone index.
  final List<int> transitionZone;

  /// List of abbreviations.
  final List<String> abbreviations;

  /// List of [TimeZone]s.
  final List<TimeZone> zones;

  /// Time in seconds when the leap seconds should be applied.
  final List<int> leapAt;

  /// Amount of leap seconds that should be applied.
  final List<int> leapDiff;

  /// Whether transition times associated with local time types are specified as
  /// standard time or wall time.
  final List<int> isStd;

  /// Whether transition times associated with local time types are specified as
  /// UTC or local time.
  final List<int> isUtc;

  Location(
      this.name,
      this.transitionAt,
      this.transitionZone,
      this.abbreviations,
      this.zones,
      this.leapAt,
      this.leapDiff,
      this.isStd,
      this.isUtc);

  /// Deserialize [Location] from bytes
  factory Location.fromBytes(String name, List<int> rawData) {
    final data = rawData is Uint8List ? rawData : Uint8List.fromList(rawData);

    final bdata =
        data.buffer.asByteData(data.offsetInBytes, data.lengthInBytes);

    final magic1 = bdata.getUint32(0);
    if (magic1 != _ziMagic) {
      throw InvalidZoneInfoDataException('Invalid magic header "$magic1"');
    }
    final version1 = bdata.getUint8(4);

    var offset = 20;

    switch (version1) {
      case 0:
        final header = _Header.fromBytes(
            Uint8List.view(bdata.buffer, offset, _Header.size));

        // calculating data offsets
        final dataOffset = offset + _Header.size;
        final transitionAtOffset = dataOffset;
        final transitionZoneOffset =
            transitionAtOffset + header.tzhTimeCount * 5;
        final abbreviationsOffset =
            transitionZoneOffset + header.tzhTypeCount * 6;
        final leapOffset = abbreviationsOffset + header.tzhCharCnt;
        final stdOrWctOffset = leapOffset + header.tzhLeapCount * 8;
        final utcOrGmtOffset = stdOrWctOffset + header.tzhTTisStdCount;

        // read transitions
        final transitionAt = <int>[];
        final transitionZone = <int>[];

        offset = transitionAtOffset;

        for (var i = 0; i < header.tzhTimeCount; i++) {
          transitionAt.add(bdata.getInt32(offset));
          offset += 4;
        }

        for (var i = 0; i < header.tzhTimeCount; i++) {
          transitionZone.add(bdata.getUint8(offset));
          offset += 1;
        }

        // function to read from abbreviation buffer
        final abbreviationsData = data.buffer.asUint8List(
            data.offsetInBytes + abbreviationsOffset, header.tzhCharCnt);
        final abbreviations = <String>[];
        final abbreviationsCache = HashMap<int, int>();
        int readAbbreviation(int offset) {
          var result = abbreviationsCache[offset];
          if (result == null) {
            result = abbreviations.length;
            abbreviationsCache[offset] = result;
            abbreviations.add(_readByteString(abbreviationsData, offset));
          }
          return result;
        }

        // read zones
        final zones = <TimeZone>[];
        offset = transitionZoneOffset;

        for (var i = 0; i < header.tzhTypeCount; i++) {
          final ttGmtoff = bdata.getInt32(offset);
          final ttIsdst = bdata.getInt8(offset + 4);
          final ttAbbrind = bdata.getUint8(offset + 5);
          offset += 6;

          zones.add(TimeZone(ttGmtoff,
              isDst: ttIsdst == 1,
              abbreviationIndex: readAbbreviation(ttAbbrind)));
        }

        // read leap seconds
        final leapAt = <int>[];
        final leapDiff = <int>[];

        offset = leapOffset;
        for (var i = 0; i < header.tzhLeapCount; i++) {
          leapAt.add(bdata.getInt32(offset));
          leapDiff.add(bdata.getInt32(offset + 4));
          offset += 5;
        }

        // read std flags
        final isStd = <int>[];

        offset = stdOrWctOffset;
        for (var i = 0; i < header.tzhTTisStdCount; i++) {
          isStd.add(bdata.getUint8(offset));
          offset += 1;
        }

        // read utc flags
        final isUtc = <int>[];

        offset = utcOrGmtOffset;
        for (var i = 0; i < header.tzhTTisGmtCount; i++) {
          isUtc.add(bdata.getUint8(offset));
          offset += 1;
        }

        return Location(name, transitionAt, transitionZone, abbreviations,
            zones, leapAt, leapDiff, isStd, isUtc);

      case 50:
      case 51:
        // skip old version header/data
        final header1 = _Header.fromBytes(
            Uint8List.view(bdata.buffer, offset, _Header.size));
        offset += _Header.size + header1.dataLength(4);

        final magic2 = bdata.getUint32(offset);
        if (magic2 != _ziMagic) {
          throw InvalidZoneInfoDataException(
              'Invalid second magic header "$magic2"');
        }

        final version2 = bdata.getUint8(offset + 4);
        if (version2 != version1) {
          throw InvalidZoneInfoDataException(
              'Second version "$version2" doesn\'t match first version '
              '"$version1"');
        }

        offset += 20;

        final header2 = _Header.fromBytes(
            Uint8List.view(bdata.buffer, offset, _Header.size));

        // calculating data offsets
        final dataOffset = offset + _Header.size;
        final transitionAtOffset = dataOffset;
        final transitionZoneOffset =
            transitionAtOffset + header2.tzhTimeCount * 9;
        final abbreviationsOffset =
            transitionZoneOffset + header2.tzhTypeCount * 6;
        final leapOffset = abbreviationsOffset + header2.tzhCharCnt;
        final stdOrWctOffset = leapOffset + header2.tzhLeapCount * 12;
        final utcOrGmtOffset = stdOrWctOffset + header2.tzhTTisStdCount;

        // read transitions
        final transitionAt = <int>[];
        final transitionZone = <int>[];

        offset = transitionAtOffset;

        for (var i = 0; i < header2.tzhTimeCount; i++) {
          transitionAt.add(bdata.getInt64(offset));
          offset += 8;
        }

        for (var i = 0; i < header2.tzhTimeCount; i++) {
          transitionZone.add(bdata.getUint8(offset));
          offset += 1;
        }

        // function to read from abbreviation buffer
        final abbreviationsData = data.buffer.asUint8List(
            data.offsetInBytes + abbreviationsOffset, header2.tzhCharCnt);
        final abbreviations = <String>[];
        final abbreviationsCache = HashMap<int, int>();
        int readAbbreviation(int offset) {
          var result = abbreviationsCache[offset];
          if (result == null) {
            result = abbreviations.length;
            abbreviationsCache[offset] = result;
            abbreviations.add(_readByteString(abbreviationsData, offset));
          }
          return result;
        }

        // read transition info
        final zones = <TimeZone>[];
        offset = transitionZoneOffset;

        for (var i = 0; i < header2.tzhTypeCount; i++) {
          final ttGmtoff = bdata.getInt32(offset);
          final ttIsdst = bdata.getInt8(offset + 4);
          final ttAbbrind = bdata.getUint8(offset + 5);
          offset += 6;

          zones.add(TimeZone(ttGmtoff,
              isDst: ttIsdst == 1,
              abbreviationIndex: readAbbreviation(ttAbbrind)));
        }

        // read leap seconds
        final leapAt = <int>[];
        final leapDiff = <int>[];

        offset = leapOffset;
        for (var i = 0; i < header2.tzhLeapCount; i++) {
          leapAt.add(bdata.getInt64(offset));
          leapDiff.add(bdata.getInt32(offset + 8));
          offset += 9;
        }

        // read std flags
        final isStd = <int>[];

        offset = stdOrWctOffset;
        for (var i = 0; i < header2.tzhTTisStdCount; i++) {
          isStd.add(bdata.getUint8(offset));
          offset += 1;
        }

        // read utc flags
        final isUtc = <int>[];

        offset = utcOrGmtOffset;
        for (var i = 0; i < header2.tzhTTisGmtCount; i++) {
          isUtc.add(bdata.getUint8(offset));
          offset += 1;
        }

        return Location(name, transitionAt, transitionZone, abbreviations,
            zones, leapAt, leapDiff, isStd, isUtc);

      default:
        throw InvalidZoneInfoDataException('Unknown version: $version1');
    }
  }
}
