import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/map.dart';
import './models/scoped/station_model.dart';

class DBMapsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<StationsModel>(
      model: StationsModel(),
      child: new MaterialApp(
        title: 'OSM',
        home: ScopedModelDescendant<StationsModel>(
          builder: (context, child, model) => new MapPage(model),
        ),
      ),
    );
  }
}
