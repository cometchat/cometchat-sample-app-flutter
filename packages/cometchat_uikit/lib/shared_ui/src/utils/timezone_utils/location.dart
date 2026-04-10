// Copyright (c) 2014, the timezone project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

/// TimeZone Location Info.
///
/// Most of this code were taken from the go standard library
/// [http://golang.org/src/pkg/time/zoneinfo.go](time/zoneinfo.go)
/// and ported to Dart.
library timezone.src.location;

/// Maximum value for time instants.
const int maxTime = 8640000000000000;

/// Minimum value for time instants.
const int minTime = -maxTime;

/// A [Location] maps time instants to the zone in use at that time.
/// Typically, the Location represents the collection of time offsets
/// in use in a geographical area, such as CEST and CET for central Europe.
class Location {
  /// [Location] name.
  final String name;

  /// Transition time, in milliseconds since 1970 UTC.
  final List<int> transitionAt;

  /// The index of the zone that goes into effect at that time.
  final List<int> transitionZone;

  /// [TimeZone]s at this [Location].
  final List<TimeZone> zones;

  /// [TimeZone] for the current time.
  TimeZone get currentTimeZone =>
      timeZone(DateTime.now().millisecondsSinceEpoch);

  // Most lookups will be for the current time.
  // To avoid the binary search through tx, keep a
  // static one-element cache that gives the correct
  // zone for the time when the Location was created.
  // if cacheStart <= t <= cacheEnd,
  // lookup can return cacheZone.
  // The units for cacheStart and cacheEnd are milliseconds
  // since January 1, 1970 UTC, to match the argument
  // to lookup.
  static final int _cacheNow = DateTime.now().millisecondsSinceEpoch;
  int _cacheStart = 0;
  int _cacheEnd = 0;
  late TimeZone _cacheZone;

  Location(this.name, this.transitionAt, this.transitionZone, this.zones) {
    // Fill in the cache with information about right now,
    // since that will be the most common lookup.
    for (var i = 0; i < transitionAt.length; i++) {
      final tAt = transitionAt[i];

      if ((tAt <= _cacheNow) &&
          ((i + 1 == transitionAt.length) ||
              (_cacheNow < transitionAt[i + 1]))) {
        _cacheStart = tAt;
        _cacheEnd = maxTime;
        if (i + 1 < transitionAt.length) {
          _cacheEnd = transitionAt[i + 1];
        }
        _cacheZone = zones[transitionZone[i]];
      }
    }
  }

  /// translate instant in time expressed as milliseconds since
  /// January 1, 1970 00:00:00 UTC to this [Location].
  int translate(int millisecondsSinceEpoch) {
    return millisecondsSinceEpoch + timeZone(millisecondsSinceEpoch).offset;
  }

  /// translate instant in time expressed as milliseconds since
  /// January 1, 1970 00:00:00 to UTC.
  int translateToUtc(int millisecondsSinceEpoch) {
    final t = lookupTimeZone(millisecondsSinceEpoch);
    final tz = t.timeZone;
    final start = t.start;
    final end = t.end;

    var utc = millisecondsSinceEpoch;

    if (tz.offset != 0) {
      utc -= tz.offset;

      if (utc < start) {
        utc =
            millisecondsSinceEpoch - lookupTimeZone(start - 1).timeZone.offset;
      } else if (utc >= end) {
        utc = millisecondsSinceEpoch - lookupTimeZone(end).timeZone.offset;
      }
    }

    return utc;
  }

  /// lookup for [TimeZone] and its boundaries for an instant in time expressed
  /// as milliseconds since January 1, 1970 00:00:00 UTC.
  TzInstant lookupTimeZone(int millisecondsSinceEpoch) {
    if (zones.isEmpty) {
      return const TzInstant(TimeZone.UTC, minTime, maxTime);
    }

    if (millisecondsSinceEpoch >= _cacheStart &&
        millisecondsSinceEpoch < _cacheEnd) {
      return TzInstant(_cacheZone, _cacheStart, _cacheEnd);
    }

    if (transitionAt.isEmpty || millisecondsSinceEpoch < transitionAt[0]) {
      final zone = _firstZone();
      const start = minTime;
      final end = transitionAt.isEmpty ? maxTime : transitionAt.first;
      return TzInstant(zone, start, end);
    }

    // Binary search for entry with largest millisecondsSinceEpoch <= sec.
    var lo = 0;
    var hi = transitionAt.length;
    var end = maxTime;

    while (hi - lo > 1) {
      final m = lo + (hi - lo) ~/ 2;
      final at = transitionAt[m];

      if (millisecondsSinceEpoch < at) {
        end = at;
        hi = m;
      } else {
        lo = m;
      }
    }

    return TzInstant(zones[transitionZone[lo]], transitionAt[lo], end);
  }

  /// timeZone method returns [TimeZone] in use at an instant in time expressed
  /// as milliseconds since January 1, 1970 00:00:00 UTC.
  TimeZone timeZone(int millisecondsSinceEpoch) {
    return lookupTimeZone(millisecondsSinceEpoch).timeZone;
  }

  /// timeZoneFromLocal method returns [TimeZone] in use at an instant in time
  /// expressed as milliseconds since January 1, 1970 00:00:00.
  TimeZone timeZoneFromLocal(int millisecondsSinceEpoch) {
    final t = lookupTimeZone(millisecondsSinceEpoch);
    var tz = t.timeZone;
    final start = t.start;
    final end = t.end;

    if (tz.offset != 0) {
      final utc = millisecondsSinceEpoch - tz.offset;

      if (utc < start) {
        tz = lookupTimeZone(start - 1).timeZone;
      } else if (utc >= end) {
        tz = lookupTimeZone(end).timeZone;
      }
    }

    return tz;
  }

  /// This method returns the [TimeZone] to use for times before the first
  /// transition time, or when there are no transition times.
  ///
  /// The reference implementation in localtime.c from
  /// http://www.iana.org/time-zones/repository/releases/tzcode2013g.tar.gz
  /// implements the following algorithm for these cases:
  ///
  /// 1. If the first zone is unused by the transitions, use it.
  /// 2. Otherwise, if there are transition times, and the first
  ///    transition is to a zone in daylight time, find the first
  ///    non-daylight-time zone before and closest to the first transition
  ///    zone.
  /// 3. Otherwise, use the first zone that is not daylight time, if
  ///    there is one.
  /// 4. Otherwise, use the first zone.
  ///
  TimeZone _firstZone() {
    // case 1
    if (!_firstZoneIsUsed()) {
      return zones.first;
    }

    // case 2
    if (transitionZone.isNotEmpty && zones[transitionZone.first].isDst) {
      for (var zi = transitionZone.first - 1; zi >= 0; zi--) {
        final z = zones[zi];
        if (!z.isDst) {
          return z;
        }
      }
    }

    // case 3
    for (final zi in transitionZone) {
      final z = zones[zi];
      if (!z.isDst) {
        return z;
      }
    }

    // case 4
    return zones.first;
  }

  /// firstZoneUsed returns whether the first zone is used by some transition.
  bool _firstZoneIsUsed() {
    for (final i in transitionZone) {
      if (i == 0) {
        return true;
      }
    }

    return false;
  }

  @override
  String toString() => name;
}

/// A [TimeZone] represents a single time zone such as CEST or CET.
class TimeZone {
  // ignore: constant_identifier_names
  static const TimeZone UTC = TimeZone(0, isDst: false, abbreviation: 'UTC');

  /// Milliseconds east of UTC.
  final int offset;

  /// Is this [TimeZone] Daylight Savings Time?
  final bool isDst;

  /// Abbreviated name, "CET".
  final String abbreviation;

  const TimeZone(this.offset,
      {required this.isDst, required this.abbreviation});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TimeZone &&
            offset == other.offset &&
            isDst == other.isDst &&
            abbreviation == other.abbreviation;
  }

  @override
  int get hashCode {
    var result = 17;
    result = 37 * result + offset.hashCode;
    result = 37 * result + isDst.hashCode;
    result = 37 * result + abbreviation.hashCode;
    return result;
  }

  @override
  String toString() => '[$abbreviation offset=$offset dst=$isDst]';
}

/// A [TzInstant] represents a timezone and an instant in time.
class TzInstant {
  final TimeZone timeZone;
  final int start;
  final int end;

  const TzInstant(this.timeZone, this.start, this.end);
}
