import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum GameState { 
   lobby, 
   starting, 
   running,
   paused,
   finished
}

enum PlayerType { 
   hunter, 
   prey 
}

class PlayerLocation {
  double latitude = 0.0;
  double longitude = 0.0;
  double heading = 0.0;
  double speed = 0.0;

  PlayerLocation({this.latitude, this.longitude, this.heading, this.speed});
}

class Player {
  String name = "Gösta";
  PlayerLocation playerLocation;
  PlayerType playerType;
}

class GameModel with ChangeNotifier { //                          <--- MyModel
  GameState gameState;
  Player myPlayer;
  var players = new List(0);
  
  void gameStateChange(GameState newState) {
    print("Gamestate has changed!");
    notifyListeners();
  }

  void waypointReached() {
    print("Waypoint reached!");
    notifyListeners();
  }

  void preyCaught() {
    print("Prey caught!");
    notifyListeners();
  }
}
