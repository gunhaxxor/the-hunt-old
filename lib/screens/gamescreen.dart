import 'package:flutter/material.dart';

// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
//     as bg;
// import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

// import 'package:parse_server_sdk/parse_server_sdk.dart';
// import 'package:gunnars_test/services/parseServerInteractions.dart';
import 'package:gunnars_test/services/locationService.dart';

// import 'package:gunnars_test/data/gameModel.dart';

import 'package:gunnars_test/mapUtility.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gunnars_test/colors.dart';

// import 'package:gunnars_test/timerThingy.dart';

import 'package:quiver/async.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  @override
  GameScreenState createState() => GameScreenState();
}

// CameraPosition createCameraFromPosition(lat, long) {
//   return CameraPosition(target: LatLng(lat, long), zoom: 17);
// }

class GameScreenState extends State<GameScreen> {
  // bool _isMoving;
  // bool _enabled = false;
  bool _isPrey = true;
  // String _motionActivity;
  // String _odometer;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<CircleId, Circle> circles = <CircleId, Circle>{};
  int _circleIdCounter = 1;
  // int _markerIdCounter = 1;

  GoogleMapController _controller;
  String _mapStyle;

  // String _gameSessionName;
  // String _userId;
  // String _userPassword;
  // TimerThingy _timerThingy;
  // int _timeToReveal;
  AppColors get colors => AppColors();

  @override
  void initState() {
    super.initState();

    //_isMoving = false;
    //_enabled = false;
    _isPrey = true;

    // _timerThingy = TimerThingy(30,
    //     () => MapUtil.moveMapViewToLocation(_controller, _mostRecentLocation));
    // _motionActivity = 'UNKNOWN';
    // _odometer = '0';
    rootBundle.loadString("assets/mapStyle.json").then((string) {
      _mapStyle = string;
    });
  }

  void _onClickRole(isPrey) {
    setState(() {
      _isPrey = isPrey;
    });
  }

  void _startCountdown() {
    print("Countdown started");
    setState(() {
      // TODO game is starting
    });

    CountdownTimer(Duration(seconds: 5), Duration(seconds: 1)).listen((data) {})
      ..onData((data) {
        print(data.remaining.inSeconds + 1);
      })
      ..onDone(_startGame);
  }

  void _startGame() {
    // callback function
    print("Game started");
    setState(() {
      // TODO game is active
    });
  }

  ////
  // Event handlers
  //

  static final LatLng center = const LatLng(57.708612, 11.973289);

  // void _addMarker() {
  //   final int markerCount = markers.length;

  //   if (markerCount == 12) {
  //     return;
  //   }
  //   print("Adding marker");

  //   final String markerIdVal = 'marker_id_$_markerIdCounter';
  //   _markerIdCounter++;
  //   final MarkerId markerId = MarkerId(markerIdVal);

  //   final Marker marker = Marker(
  //     markerId: markerId,
  //     position: LatLng(
  //       center.latitude + sin(_markerIdCounter * pi / 6.0) / 20.0,
  //       center.longitude + cos(_markerIdCounter * pi / 6.0) / 20.0,
  //     ),
  //     infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
  //     onTap: () {
  //       // _onMarkerTapped(markerId);
  //     },
  //     onDragEnd: (LatLng position) {
  //       // _onMarkerDragEnd(markerId, position);
  //     },
  //   );

  //   setState(() {
  //     markers[markerId] = marker;
  //   });
  // }

  void _addCircle(double latitude, double longitude, bool isHunter) {
    Color circleColor = colors.prey;
    double circleRadius = 50;
    if (isHunter) {
      circleColor = colors.hunter;
      circleRadius = 25;
    }
    // if (circleCount == 12) {
    //   return;
    // }

    final String circleIdVal = 'circle_id_$_circleIdCounter';
    _circleIdCounter++;
    final CircleId circleId = CircleId(circleIdVal);

    final Circle circle = Circle(
      circleId: circleId,
      consumeTapEvents: true,
      strokeColor: circleColor,
      fillColor: Colors.transparent,
      strokeWidth: 10,
      center: LatLng(
        // center.latitude + sin(_circleIdCounter * pi / 6.0) / 20.0,
        // center.longitude + cos(_circleIdCounter * pi / 6.0) / 20.0,
        latitude,
        longitude,
      ),
      radius: circleRadius,
      onTap: () {
        _onCircleTapped(circleId);
      },
    );

    setState(() {
      circles[circleId] = circle;
    });
  }

  void _clearCircles() {
    _circleIdCounter = 0;
    setState(() {
      circles.clear();
    });
  }

  void _onCircleTapped(CircleId circleId) {
    // TODO
  }

  // void _getLocations() {
  //   _clearCircles();
  //   getLocationsForGameSession('RVpzsL3tST', false).then((response) {
  //     List<ParseObject> responsObjects = response;
  //     for (var locationObject in responsObjects) {
  //       ParseGeoPoint point = (locationObject.get("coords") as ParseGeoPoint);
  //       _addCircle(point.latitude, point.longitude, false);
  //     }
  //   });
  //   getLocationsForGameSession('RVpzsL3tST', true).then((response) {
  //     List<ParseObject> responsObjects = response;
  //     for (var locationObject in responsObjects) {
  //       ParseGeoPoint point = (locationObject.get("coords") as ParseGeoPoint);
  //       _addCircle(point.latitude, point.longitude, true);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocationService>(
        create: (context) => LocationService(),
        child: MaterialApp(
          title: 'The Hunt',
          theme: new ThemeData(
            primarySwatch: Colors.amber,
          ),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('The Hunt'),
              actions: <Widget>[
                Center(child: Text(_isPrey ? 'Prey' : 'Hunter')),
                Switch(value: _isPrey, onChanged: _onClickRole),
                Consumer<LocationService>(
                  builder: (context, locationService, child) {
                    return Center(
                        child: Text(locationService.enabled ? 'PÅ' : 'AV'));
                  },
                ),
                Consumer<LocationService>(
                  builder: (context, locationService, child) {
                    return Switch(
                        value: locationService.enabled,
                        onChanged: locationService.onClickEnable);
                  },
                )
              ],
            ),
            // body: MapSample(_controller),
            body: GoogleMap(
              initialCameraPosition:
                  MapUtil.createCameraFromPosition(57.708870, 11.974560),
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                controller.setMapStyle(_mapStyle).then((_) {
                  print("styling map!!!");
                }).catchError((error) {
                  print("ERROR while styling map");
                  return null;
                });
                _controller = controller;
              },
              markers: Set<Marker>.of(markers.values),
              circles: Set<Circle>.of(circles.values),
              myLocationButtonEnabled: false,
            ),
            floatingActionButton: Consumer<LocationService>(
                builder: (context, locationService, child) {
              return FloatingActionButton(
                child: Icon(Icons.gps_fixed),
                onPressed: () => MapUtil.moveMapViewToLocation(
                    _controller, locationService.mostRecentLocation),
              );
            }),
            bottomNavigationBar: BottomAppBar(
              child: Container(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Consumer<LocationService>(
                    builder: (context, locationService, child) {
                      return Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.gps_not_fixed),
                              onPressed: () =>
                                  locationService.getCurrentPosition(),
                            ),
                            // Text('$_motionActivity · $_odometer km'),
                            FlatButton(
                              child: const Text('Start'),
                              onPressed: _startCountdown,
                            ),
                            FlatButton(
                              child: const Text('Quit'),
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/');
                              },
                            ),
                            FlatButton(
                              child: const Text('add'),
                              onPressed: () => _addCircle(
                                  locationService
                                      .mostRecentLocation.coords.latitude,
                                  locationService
                                      .mostRecentLocation.coords.longitude,
                                  false),
                            ),
                            FlatButton(
                              child: const Text('clear'),
                              onPressed: _clearCircles,
                            ),
                            MaterialButton(
                                minWidth: 50.0,
                                child: Icon(
                                    (locationService.isMoving)
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white),
                                color: (locationService.isMoving)
                                    ? Colors.red
                                    : Colors.green,
                                onPressed: locationService.onClickChangePace)
                          ]);
                    },
                  )),
            ),
          ),
        ));
  }
}
