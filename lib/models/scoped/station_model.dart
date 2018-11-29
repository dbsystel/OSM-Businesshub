import 'dart:async';
import 'package:scoped_model/scoped_model.dart';

import '../../services/persistence_service.dart';
import '../object/station.dart';

class StationsModel extends Model {
  PersistenceService _persistenceService = PersistenceService();
  Station currentStation;
  bool _operationInProgress = false;
  List _stationSearch = [];

  Future<List> searchStation(String searchString) async {
    String query =
        'SELECT name, longitude, latitude FROM trainstations where name LIKE \'\%$searchString\%\' order by name';
    return await _persistenceService.executeQuery(query).then((stations) {
      _stationSearch = [];
      stations.forEach((station) {
        _stationSearch.add(Station.fromMap(station));
      });
      _operationInProgress = false;
      notifyListeners();
      return _stationSearch;
    }).catchError((error) {
      _operationInProgress = false;
      notifyListeners();
      return [];
    });
  }
}
