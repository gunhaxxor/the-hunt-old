import 'package:flutter/material.dart';
// import 'package:gunnars_test/data/GameModel.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

enum GameState { lobby, starting, running, paused, finished }

class Player {
  String name = "Gösta";
  PlayerType playerType;
  Location currentLocation;
  List<Location> trail = new List<Location>(0);
  Player(
      {this.name = "",
      this.playerType = PlayerType.hunter,
      this.currentLocation,
      this.trail});
}

enum PlayerType { hunter, prey }

class Location {
  double latitude = 0.0;
  double longitude = 0.0;
  double heading = 0.0;
  double speed = 0.0;
  bool visibleByDefault = false;

  Location(
      {this.latitude,
      this.longitude,
      this.heading,
      this.speed,
      this.visibleByDefault = false});
}

class GameModel with ChangeNotifier {
  GameState _gameState;
  Player myPlayer;
  Player prey;
  List<Player> players = new List<Player>(0);

  set gameState(GameState newState) {
    _gameState = newState;
    print("Gamestate has changed!");
    notifyListeners();
  }

  GameState get gameState {
    return _gameState;
  }

  void addPlayerToGameSession(Player player) {
    players.add(player);
    if (player.playerType == PlayerType.prey) {
      if (prey == null) {
        print(
            "THERE WAS ALREADY A PREY ASSIGN TO THE GAME MODEL! CHECK YOUR COOODE FFS!");
      }
      prey = player;
    }
  }

  //TODO: perhaps something more robust than comparing name!!!
  //      This code relies on player names being unique (riiisky).
  void addLocationToPlayersTrail(String playerName, Location loc) {
    Player player = players.singleWhere((player) => player.name == playerName);
    player.trail.add(loc);
  }

  void addLocationToMyPlayersTrail(Location loc) {
    addLocationToPlayersTrail(myPlayer.name, loc);
  }

  // void waypointReached() {
  //   print("Waypoint reached!");
  //   notifyListeners();
  // }

  // void preyCaught() {
  //   print("Prey caught!");
  //   notifyListeners();
  // }
}
