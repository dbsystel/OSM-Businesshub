import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

class Station {
  static const String kName = 'name';
  static const String kLongitude = 'longitude';
  static const String kLatitude = 'latitude';

  final String name;
  final double longitude;
  final double latitude;

  Station({@required this.name, @required this.longitude, @required this.latitude});

  LatLng get geoPoint {
    return LatLng(latitude, longitude);
  }

  Station.fromMap(Map<String, dynamic> map)
      : this(
          name: map[kName],
          longitude: map[kLongitude],
          latitude: map[kLatitude],
        );
}
