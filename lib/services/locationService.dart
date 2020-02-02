import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:gunnars_test/data/gameModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
// import 'package:provider/provider.dart';

class LocationService with ChangeNotifier {
  // Keep track of current player Location
  Location _currentPlayerLocation;

  bg.Location mostRecentLocation;

  var isMoving = false;
  var enabled = false;

  // Manually fetch the current position.
  Future<void> getCurrentPosition() async {
    try {
      bg.Location loc = await bg.BackgroundGeolocation.getCurrentPosition(
          persist: true, // <-- do not persist this location
          desiredAccuracy: 0, // <-- desire best possible accuracy
          timeout: 5000, // <-- wait 30s before giving up.
          samples: 3 // <-- sample 3 location before selecting best.
          );
      this.mostRecentLocation = loc;
      this._currentPlayerLocation = Location(
          latitude: loc.coords.latitude,
          longitude: loc.coords.longitude,
          heading: loc.coords.heading,
          speed: loc.coords.speed);

      print('[getCurrentPosition] - $loc');
      return _currentPlayerLocation;
    } catch (error) {
      print('[getCurrentPosition] ERROR: $error');
      return Future.error(error);
    }
  }

  // Manually toggle the tracking state:  moving vs stationary
  void onClickChangePace() {
    this.isMoving = !this.isMoving;
    print("[onClickChangePace] -> $isMoving");

    bg.BackgroundGeolocation.changePace(this.isMoving).then((bool isMoving) {
      print('[changePace] success $isMoving');
    }).catchError((e) {
      print('[changePace] ERROR: ' + e.code.toString());
    });
    notifyListeners();
  }

  void onClickEnable(enabled) {
    if (enabled) {
      bg.BackgroundGeolocation.start().then((bg.State state) {
        print('[start] success $state');
        this.enabled = state.enabled;
        this.isMoving = state.isMoving;
      });
    } else {
      bg.BackgroundGeolocation.stop().then((bg.State state) {
        print('[stop] success: $state');
        // Reset odometer.
        bg.BackgroundGeolocation.setOdometer(0.0);

        // _odometer = '0.0';
        this.enabled = state.enabled;
        this.isMoving = state.isMoving;
      });
    }
    notifyListeners();
  }

  // StreamController<PlayerLocation> _playerLocationController =
  //   StreamController<PlayerLocation>();

  // Stream<PlayerLocation> get playerLocationStream => _playerLocationController.stream;

  LocationService() {
    // 1.  Listen to events (See docs for all 12 available events).
    bg.BackgroundGeolocation.onLocation(this._onLocation,
        (bg.LocationError error) {
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
      this.enabled = state.enabled;
      this.isMoving = state.isMoving;
    });
  }

  void _onLocation(bg.Location location) {
    print('[location] - $location');
    this.mostRecentLocation = location;

    // Emit most recent location over our controller
    _currentPlayerLocation = Location(
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
        heading: location.coords.heading,
        speed: location.coords.speed);

    // Here we would add it to the stream BUT WE COMMENTED IT OUT
    // this._playerLocationController.add(_currentPlayerLocation);
    // this.sendLocationToParse(location);
    //_addCircle();
  }

  // void sendLocationToParse(bg.Location location) {
  //   ParseGeoPoint latlong = new ParseGeoPoint();
  //   latlong.latitude = location.coords.latitude;
  //   latlong.longitude = location.coords.longitude;
  //   ParseObject loc = ParseObject("Location")
  //     ..set('heading', location.coords.heading)
  //     ..set('coords', latlong)
  //     ..set('visibleByDefault', true);

  //   loc.save();
  // }

  void _onMotionChange(bg.Location location) {
    print('[motionchange] - $location');
  }

  void _onActivityChange(bg.ActivityChangeEvent event) {
    print('[activitychange] - $event');
    // setState(() {
    //   // _motionActivity = event.activity;
    // });
  }

  void _onProviderChange(bg.ProviderChangeEvent event) {
    print('$event');

    // setState(() {
    //   // _content = encoder.convert(event.toMap());
    //   // _content = event as String;
    // });
  }

  void _onConnectivityChange(bg.ConnectivityChangeEvent event) {
    print('$event');
  }
}
