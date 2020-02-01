import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapUtil {
  static void moveMapViewToLocation(controller, location) async {
    // if (location == null) await getCurrentPosition();
    controller.animateCamera(CameraUpdate.newCameraPosition(
        createCameraFromPosition(
            location.coords.latitude, location.coords.longitude)));
    // .catchError((error) => (print(
    //     "ERROR when trying to get the GoogleMapController from it's future.")));
  }

  static CameraPosition createCameraFromPosition(lat, long) {
    return CameraPosition(target: LatLng(lat, long), zoom: 17);
  }
}
