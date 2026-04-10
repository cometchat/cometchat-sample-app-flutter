// Copyright (c) 2014, the timezone project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

/// zone1970.tab file parser
library timezone.src.tzdata.zone_tab;

/// Latitude and longitude of the zone's principal location
/// in ISO 6709 sign-degrees-minutes-seconds format,
/// either +-DDMM+-DDDMM or +-DDMMSS+-DDDMMSS,
/// first latitude (+ is north), then longitude (+ is east).
final _geoLocationRe =
    RegExp(r'^([+\-])(\d{2,3})(\d{2})(\d{2})?([+\-])(\d{2,3})(\d{2})(\d{2})?$');

class LocationDescription {
  final String name;
  final List<String> countryCodes;
  final double latitude;
  final double longitude;
  final String comments;

  LocationDescription(this.name, this.countryCodes, this.latitude,
      this.longitude, this.comments);

  factory LocationDescription.fromString(String line) {
    final parts = line.split('\t');
    final countryCodes = parts[0].split(',');
    final name = parts[2];
    final comments = parts.length > 3 ? parts[3] : '';

    final match = _geoLocationRe.firstMatch(parts[1])!;
    final latSign = match.group(1) == '+' ? 1 : -1;
    final latDeg = int.parse(match.group(2)!);
    final latMinutes = int.parse(match.group(3)!);
    final latSecondsRaw = match.group(4);
    final latSeconds = latSecondsRaw != null ? int.parse(latSecondsRaw) : 0;

    final longSign = match.group(5) == '+' ? 1 : -1;
    final longDeg = int.parse(match.group(6)!);
    final longMinutes = int.parse(match.group(7)!);
    final longSecondsRaw = match.group(8);
    final longSeconds = longSecondsRaw != null ? int.parse(longSecondsRaw) : 0;

    final latitude = latSign * (latDeg + (latMinutes + (latSeconds / 60)) / 60);
    final longitude =
        longSign * (longDeg + (longMinutes + (longSeconds / 60)) / 60);

    return LocationDescription(
        name, countryCodes, latitude, longitude, comments);
  }
}

class LocationDescriptionDatabase {
  final List<LocationDescription> locations;

  LocationDescriptionDatabase(this.locations);

  factory LocationDescriptionDatabase.fromString(String data) {
    final lines = data.split('\n');
    final locations = <LocationDescription>[];
    for (final line in lines) {
      if (line.isEmpty || line[0].startsWith('#')) {
        continue;
      }
      locations.add(LocationDescription.fromString(line));
    }

    return LocationDescriptionDatabase(locations);
  }
}
