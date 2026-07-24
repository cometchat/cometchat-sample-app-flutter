// Copyright (c) 2015, the timezone project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'location.dart';
import 'location_database.dart';
import 'tzdb.dart';

/// File name of the Time Zone default database.
const String tzDataDefaultFilename = 'latest.tzf';

final _utc = Location('UTC', [minTime], [0], [TimeZone.UTC]);

final _database = LocationDatabase();
late Location _local;

/// Global TimeZone database
LocationDatabase get timeZoneDatabase => _database;

/// UTC Location
Location get utc => _utc;

/// Local Location
///
/// By default it is instantiated with UTC [Location]
Location get local => _local;

/// Find [Location] by its name.
///
/// ```dart
/// final detroit = getLocation('America/Detroit');
/// ```
Location getLocation(String locationName) {
  return _database.get(locationName);
}

/// Set local [Location]
///
/// ```dart
/// final detroit = getLocation('America/Detroit')
/// setLocalLocation(detroit);
/// ```
void setLocalLocation(Location location) {
  _local = location;
}

/// Initialize Time zone database.
void initializeDatabase(List<int> rawData) {
  _database.clear();

  for (final l in tzdbDeserialize(rawData)) {
    _database.add(l);
  }

  _local = _utc;
}
