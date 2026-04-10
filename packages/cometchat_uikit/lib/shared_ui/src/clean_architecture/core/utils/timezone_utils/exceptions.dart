// Copyright (c) 2014, the timezone project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

class TimeZoneInitException implements Exception {
  final String msg;

  TimeZoneInitException(this.msg);

  @override
  String toString() => msg;
}

class LocationNotFoundException implements Exception {
  final String msg;

  LocationNotFoundException(this.msg);

  @override
  String toString() => msg;
}
