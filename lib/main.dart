/**
* flutter_background_geolocation Hello World
* https://github.com/transistorsoft/flutter_background_geolocation
*/

import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:parse_server_sdk/parse_server_sdk.dart';

////
// For pretty-printing location JSON.  Not a requirement of flutter_background_geolocation
//
// import 'dart:convert';

// JsonEncoder encoder = new JsonEncoder.withIndent("     ");
//
////

void main() => runApp(new App());

class App extends StatefulWidget {
  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    initParse();
  }

  Future<void> getSomeData() async {
    var apiResponse = await ParseObject('ParseTableName').getAll();

    if (apiResponse.success) {
      for (var testObject in apiResponse.result) {
        print("Parse result: " + testObject.toString());
      }
    }
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'The Hunt',
      theme: new ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: new MyHomePage(title: 'The Hunt'),
      // home: MapSample(),
    );
  }
}

CameraPosition CreateCameraFromPosition(lat, long) {
  return CameraPosition(target: LatLng(lat, long), zoom: 15);
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isMoving;
  bool _enabled;
  String _motionActivity;
  String _odometer;
  bg.Location _mostRecentLocation;

  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    _isMoving = false;
    _enabled = false;
    _motionActivity = 'UNKNOWN';
    _odometer = '0';

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

  void moveMapViewToOwnLocation() {
    _controller.future
        .then((controller) => (controller.animateCamera(
            CameraUpdate.newCameraPosition(CreateCameraFromPosition(
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
  void _onClickGetCurrentPosition() {
    bg.BackgroundGeolocation.getCurrentPosition(
            persist: false, // <-- do not persist this location
            desiredAccuracy: 0, // <-- desire best possible accuracy
            timeout: 30000, // <-- wait 30s before giving up.
            samples: 3 // <-- sample 3 location before selecting best.
            )
        .then((bg.Location location) {
      _mostRecentLocation = location;
      print('[getCurrentPosition] - $location');
    }).catchError((error) {
      print('[getCurrentPosition] ERROR: $error');
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Hunt'),
        actions: <Widget>[
          Center(child: Text(_enabled ? 'PÅ' : 'AV')),
          Switch(value: _enabled, onChanged: _onClickEnable),
        ],
      ),
      // body: MapSample(_controller),
      body: GoogleMap(
        initialCameraPosition: CreateCameraFromPosition(57.708870, 11.974560),
        mapType: MapType.hybrid,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
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
                      onPressed: _onClickGetCurrentPosition,
                    ),
                    Text('$_motionActivity · $_odometer km'),
                    MaterialButton(
                        minWidth: 50.0,
                        child: Icon(
                            (_isMoving) ? Icons.pause : Icons.play_arrow,
                            color: Colors.white),
                        color: (_isMoving) ? Colors.red : Colors.green,
                        onPressed: _onClickChangePace)
                  ]))),
    );
  }
}
