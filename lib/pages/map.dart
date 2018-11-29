import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import '../widgets/search_bar.dart';

import '../models/object/station.dart';
import '../models/scoped/station_model.dart';

class MapPage extends StatefulWidget {
  final StationsModel model;

  MapPage(this.model);

  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  MapController _mapController;
  LatLng _currentLatLng = new LatLng(50.107407, 8.664137);
  List<Marker> _markers = [];

  void initState() {
    super.initState();
    _mapController = new MapController();
    _markers = [];
  }

  void _animatedMapMove(LatLng destLocation, double zoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = new Tween<double>(begin: _mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = new Tween<double>(begin: _mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = new Tween<double>(begin: _mapController.zoom, end: zoom);
    print('${_mapController.zoom} $zoom');

    // Create a new animation controller that has a duration and a TickerProvider.
    AnimationController controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      // Note that the mapController.move doesn't seem to like the zoom animation. This may be a bug in flutter_map.
      _mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)), _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      print("$status");
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          _buildMap(),
          _buildSearchBar(context),
        ],
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildMap() {
    return Container(
      child: FlutterMap(
        mapController: _mapController,
        options: new MapOptions(center: _currentLatLng, zoom: 16.0),
        layers: [
          new TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          new MarkerLayerOptions(markers: _markers)
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 36.0, left: 20.0, right: 20.0, bottom: 5.0),
      child: SearchBar(
        searchHintText: 'Bahnhofssuche ...',
        itemBuilder: (context, result) {
          Station station = result as Station;
          return new Card(
            color: Colors.white,
            elevation: 5.0,
            child: ListTile(
              leading: Icon(
                Icons.location_on,
                size: 28.0,
                color: Colors.red,
              ),
              title: Text(station.name),
              subtitle: Text('Lat: ${station.latitude} Long: ${station.longitude}'),
            ),
          );
        },
        resultsCallback: (pattern) {
          return widget.model.searchStation(pattern);
        },
        resultSelectionCallback: (result) {
          setState(() {
            Station station = result as Station;
            _currentLatLng = station.geoPoint;
            Widget child = new Column(
              children: <Widget>[
                Container(
                    // margin: EdgeInsets.all(5.0),
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      station.name,
                    ),
                    decoration: BoxDecoration(
                        border: new Border.all(
                          width: .5,
                          color: Colors.grey[300],
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: new Offset(-1.0, 5.0),
                            blurRadius: 5.0,
                          )
                        ],
                        color: Colors.white)),
                new Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.red,
                )
              ],
            );
            _markers = [
              new Marker(
                width: 200.0,
                height: 100.0,
                point: _currentLatLng,
                builder: (ctx) => child,
              ),
            ];
            _animatedMapMove(_currentLatLng, 16.0);
          });
        },
      ),
    );
  }
}
