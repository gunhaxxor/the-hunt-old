/**
* flutter_background_geolocation Hello World
* https://github.com/transistorsoft/flutter_background_geolocation
*/

import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:parse_server_sdk/parse_server_sdk.dart';

void main() => runApp(new App());

class App extends StatefulWidget {
  @override
  AppState createState() => AppState();
}

CameraPosition createCameraFromPosition(lat, long) {
  return CameraPosition(target: LatLng(lat, long), zoom: 17);
}

class AppState extends State<App> {
  bool _isMoving;
  bool _enabled = false;
  String _motionActivity;
  String _odometer;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<CircleId, Circle> circles = <CircleId, Circle>{};
  int _circleIdCounter = 1;
  int _markerIdCounter = 1;
  int fillColorsIndex = 0;
  int strokeColorsIndex = 0;
  List<Color> colors = <Color>[
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.pink,
  ];
  int widthsIndex = 0;
  List<int> widths = <int>[10, 20, 5];
  bg.Location _mostRecentLocation;

  Completer<GoogleMapController> _controller = Completer();
  String _mapStyle;

  @override
  void initState() {
    super.initState();
    initParse();
    _isMoving = false;
    _enabled = false;
    _motionActivity = 'UNKNOWN';
    _odometer = '0';
    rootBundle.loadString("assets/mapStyle.txt").then((string) {
      _mapStyle = string;
    });

    // _controller.future.then((GoogleMapController controller) async {
    //   try {
    //     String jsonString =
    //     await controller.setMapStyle(jsonString);
    //     print("style was changed!!!!!");
    //   } catch (error) {
    //     print("ERRRRROOOOR!!!");
    //   }
    // });

    // 1.  Listen to events (See docs for all 12 available events).
    bg.BackgroundGeolocation.onLocation(_onLocation, (bg.LocationError error) {
      print("locationError] - $error");
    });
    bg.BackgroundGeolocation.onMotionChange(_onMotionChange);
    bg.BackgroundGeolocation.onActivityChange(_onActivityChange);
    bg.BackgroundGeolocation.onProviderChange(_onProviderChange);
    bg.BackgroundGeolocation.onConnectivityChange(_onConnectivityChange);

    // 2.  Configure the plugin
    bg.BackgroundGeolocation.ready(bg.Config(
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
            distanceFilter: 0.0,
            stopOnTerminate: false,
            startOnBoot: true,
            debug: true,
            logLevel: bg.Config.LOG_LEVEL_VERBOSE,
            reset: true))
        .then((bg.State state) {
      setState(() {
        _enabled = state.enabled;
        _isMoving = state.isMoving;
      });
    });
  }

  Future<void> initParse() async {
    await Parse().initialize('ZNTkzZ7nxKOu88Cza8qjaNcLTdJgvxe1FuVPb0TF',
        'https://parseapi.back4app.com',
        // masterKey: keyParseMasterKey, // Required for Back4App and others
        // clientKey: keyParseClientKey, // Required for some setups
        debug: true, // When enabled, prints logs to console
        // liveQueryUrl: keyLiveQueryUrl, // Required if using LiveQuery
        autoSendSessionId: true, // Required for authentication and ACL
        // securityContext: securityContext, // Again, required for some setups
        coreStore: await CoreStoreSharedPrefsImp
            .getInstance()); // Local data storage method. Will use SharedPreferences instead of Sembast as an internal DB

    // Check server is healthy and live - Debug is on in this instance so check logs for result
    final ParseResponse response = await Parse().healthCheck();

    if (response.success) {
      print("PARSE CONNECTION HEALTHY");
    } else {
      print("PARSE HEALTH NO GOOD");
    }
  }

  Future<void> getSomeTestData() async {
    var apiResponse = await ParseObject('GameSession').getAll();

    if (apiResponse.success) {
      for (var testObject in apiResponse.result) {
        print("Parse result: " + testObject.toString());
      }
    }
  }

  void moveMapViewToOwnLocation() async {
    if (_mostRecentLocation == null) await getCurrentPosition();
    _controller.future
        .then((controller) => (controller.animateCamera(
            CameraUpdate.newCameraPosition(createCameraFromPosition(
                _mostRecentLocation.coords.latitude,
                _mostRecentLocation.coords.longitude)))))
        .catchError((error) => (print(
            "ERROR when trying to get the GoogleMapController from it's future.")));
  }

  void _onClickEnable(enabled) {
    if (enabled) {
      bg.BackgroundGeolocation.start().then((bg.State state) {
        print('[start] success $state');
        setState(() {
          _enabled = state.enabled;
          _isMoving = state.isMoving;
        });
      });
    } else {
      bg.BackgroundGeolocation.stop().then((bg.State state) {
        print('[stop] success: $state');
        // Reset odometer.
        bg.BackgroundGeolocation.setOdometer(0.0);

        setState(() {
          _odometer = '0.0';
          _enabled = state.enabled;
          _isMoving = state.isMoving;
        });
      });
    }
  }

  // Manually toggle the tracking state:  moving vs stationary
  void _onClickChangePace() {
    setState(() {
      _isMoving = !_isMoving;
    });
    print("[onClickChangePace] -> $_isMoving");

    bg.BackgroundGeolocation.changePace(_isMoving).then((bool isMoving) {
      print('[changePace] success $isMoving');
    }).catchError((e) {
      print('[changePace] ERROR: ' + e.code.toString());
    });
  }

  // Manually fetch the current position.
  Future<void> getCurrentPosition() async {
    try {
      bg.Location loc = await bg.BackgroundGeolocation.getCurrentPosition(
          persist: true, // <-- do not persist this location
          desiredAccuracy: 0, // <-- desire best possible accuracy
          timeout: 5000, // <-- wait 30s before giving up.
          samples: 3 // <-- sample 3 location before selecting best.
          );
      _mostRecentLocation = loc;
      print('[getCurrentPosition] - $loc');
      return Future.value();
    } catch (error) {
      print('[getCurrentPosition] ERROR: $error');
      return Future.error(error);
    }
  }

  ////
  // Event handlers
  //

  void _onLocation(bg.Location location) {
    print('[location] - $location');
    _mostRecentLocation = location;

    String odometerKM = (location.odometer / 1000.0).toStringAsFixed(1);
    // Future<GoogleMapController> future = _controller.future;
    // future
    //     .then((controller) => (controller.animateCamera(
    //         CameraUpdate.newCameraPosition(CreateCameraFromPosition(
    //             location.coords.latitude, location.coords.longitude)))))
    //     .catchError((error) => (print(
    //         "ERROR when trying to get the GoogleMapController from it's future.")));

    setState(() {
      // _content = encoder.convert(location.toMap());
      // _content = location as String;
      _odometer = odometerKM;
    });
  }

  void _onMotionChange(bg.Location location) {
    print('[motionchange] - $location');
  }

  void _onActivityChange(bg.ActivityChangeEvent event) {
    print('[activitychange] - $event');
    setState(() {
      _motionActivity = event.activity;
    });
  }

  void _onProviderChange(bg.ProviderChangeEvent event) {
    print('$event');

    setState(() {
      // _content = encoder.convert(event.toMap());
      // _content = event as String;
    });
  }

  void _onConnectivityChange(bg.ConnectivityChangeEvent event) {
    print('$event');
  }

  static final LatLng center = const LatLng(57.708612, 11.973289);
  void _addMarker() {
    final int markerCount = markers.length;

    if (markerCount == 12) {
      return;
    }
    print("Adding marker");

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        center.latitude + sin(_markerIdCounter * pi / 6.0) / 20.0,
        center.longitude + cos(_markerIdCounter * pi / 6.0) / 20.0,
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
        // _onMarkerTapped(markerId);
      },
      onDragEnd: (LatLng position) {
        // _onMarkerDragEnd(markerId, position);
      },
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  void _addCircle() {
    final int circleCount = circles.length;

    if (circleCount == 12) {
      return;
    }

    final String circleIdVal = 'circle_id_$_circleIdCounter';
    _circleIdCounter++;
    final CircleId circleId = CircleId(circleIdVal);

    final Circle circle = Circle(
      circleId: circleId,
      consumeTapEvents: true,
      strokeColor: Colors.orange,
      fillColor: Colors.transparent,
      strokeWidth: 10,
      center: LatLng(
        center.latitude + sin(_circleIdCounter * pi / 6.0) / 20.0,
        center.longitude + cos(_circleIdCounter * pi / 6.0) / 20.0,
      ),
      radius: 50,
      onTap: () {
        _onCircleTapped(circleId);
      },
    );

    setState(() {
      circles[circleId] = circle;
    });
  }

  void _clearCircles() {
    setState(() {
      circles.clear();
    });
  }

  void _onCircleTapped(CircleId circleId) {
    // TODO
  }

  Future<void> goToPos(lat, long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(createCameraFromPosition(lat, long)));
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'The Hunt',
      theme: new ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('The Hunt'),
          actions: <Widget>[
            Center(child: Text(_enabled ? 'PÅ' : 'AV')),
            Switch(value: _enabled, onChanged: _onClickEnable),
          ],
        ),
        // body: MapSample(_controller),
        body: GoogleMap(
          initialCameraPosition: createCameraFromPosition(57.708870, 11.974560),
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            controller.setMapStyle(_mapStyle).then((_) {
              print("styling map!!!");
            }).catchError((error) {print("ERROR while styling map");return null;});
            _controller.complete(controller);
          },
          markers: Set<Marker>.of(markers.values),
          circles: Set<Circle>.of(circles.values),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.gps_fixed),
          onPressed: moveMapViewToOwnLocation,
        ),
        bottomNavigationBar: BottomAppBar(
            child: Container(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.gps_not_fixed),
                        onPressed: getCurrentPosition,
                      ),
                      // Text('$_motionActivity · $_odometer km'),
                      FlatButton(
                        child: const Text('add'),
                        onPressed: _addCircle,
                      ),
                      FlatButton(
                        child: const Text('clear'),
                        onPressed: _clearCircles,
                      ),
                      MaterialButton(
                          minWidth: 50.0,
                          child: Icon(
                              (_isMoving) ? Icons.pause : Icons.play_arrow,
                              color: Colors.white),
                          color: (_isMoving) ? Colors.red : Colors.green,
                          onPressed: _onClickChangePace)
                    ]))),
      ),
    );
  }
}
