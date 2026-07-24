// Copyright (c) 2014, the timezone project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

/// Locations database
library;

import 'exceptions.dart';
import 'location.dart';

/// LocationDatabase provides interface to find [Location]s by their name.
///
///     List<int> data = load(); // load database
///
///     LocationDatabase db = LocationDatabase.fromBytes(data);
///     Location loc = db.get('US/Eastern');
///
class LocationDatabase {
  /// Mapping between [Location] name and [Location].
  final _locations = <String, Location>{};

  Map<String, Location> get locations => _locations;

  /// Adds [Location] to the database.
  void add(Location location) {
    _locations[location.name] = location;
  }

  /// Finds [Location] by its name.
  Location get(String name) {
    if (!isInitialized) {
      // Before you can get a location, you need to manually initialize the
      // timezone location database by calling initializeDatabase or similar.
      throw LocationNotFoundException(
        'Tried to get location before initializing timezone database',
      );
    }

    final loc = _locations[name];
    if (loc == null) {
      throw LocationNotFoundException(
        'Location with the name "$name" doesn\'t exist',
      );
    }
    return loc;
  }

  /// Clears the database of all [Location] entries.
  void clear() => _locations.clear();

  /// Returns whether the database is empty, or has [Location] entries.
  @Deprecated("Use 'isInitialized' instead")
  bool get isEmpty => isInitialized;

  /// Returns whether the database is empty, or has [Location] entries.
  bool get isInitialized => _locations.isNotEmpty;
}
