import 'package:flutter/material.dart';
import 'package:gunnars_test/data/GameModel.dart';
// import 'package:gunnars_test/main.dart';

import 'package:gunnars_test/services/parseServerInteractions.dart';
import 'package:provider/provider.dart';

class StartScreen extends StatefulWidget {
  @override
  State<StartScreen> createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  // ONLY UI STATE HERE!!!!
  // GAME STATE IN GAME MODEL!!!!
  bool _gameNameAvailable = false;
  bool _playerNameAvailable = false;
  String _gameName = "";
  String _playerName = "";

  @override
  void initState() {
    super.initState();
    createUserCredentailsFromHardware().then((Map<String, String> credentials) {
      initParse(credentials["userId"], credentials["userPassword"]).then((_) {
        // getAllGameSessions().then((gameSessionsString) {
        //   _gameSessionName = gameSessionsString;
        // });
      });
    });
  }

  void _onClickHostGame(GameModel state) async {
    try {
      await createGameSession(_gameName);
      await joinGameSession(_gameName, _playerName);
      state.gameState = GameState.lobby;
      state.myPlayer = Player(name: _playerName);
      state.addPlayerToGameSession(state.myPlayer);

      Navigator.pushReplacementNamed(context, '/lobby');
    } catch (error) {
      print("fuck you!!");
      print(error);
    }
  }

  void _onClickJoinGame(GameModel state) async {
    await joinGameSession(_gameName, _playerName);
    state.gameState = GameState.lobby;
    state.myPlayer = Player(name: _playerName);
    state.addPlayerToGameSession(state.myPlayer);
    Navigator.pushReplacementNamed(context, '/lobby');
  }

  @override
  Widget build(BuildContext context) {
    final GameModel gameModel = Provider.of<GameModel>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('The Hunt'),
      ),
      body: Center(
        child: Container(
          color: Colors.amberAccent[200],
          padding:
              EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Text(
                      "The Hunt",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        foreground: Paint()
                          // ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = Colors.orange[600],
                      ),
                    ),
                    // Text(
                    //   "Are you ready for some action? One player is the prey, who needs to go to all waypoints. The other players are hunters, who try to get close enough to the prey to catch it.",
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //   ),
                    // ),
                    // Text(
                    //   "Come up with a name and host a game, or fill in the name of an existing game and join it.",
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //   ),
                    // ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Player Name',
                        ),
                        onChanged: (value) async {
                          var available = await isPlayerNameAvailable(value);
                          setState(() {
                            _playerNameAvailable = available;
                            _playerName = value;
                          });
                        },
                      ),
                    ),
                    Container(
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Game Name',
                        ),
                        onChanged: (value) async {
                          var available = await isGameNameAvailable(value);
                          setState(() {
                            _gameNameAvailable = available;
                            _gameName = value;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                            color: Colors.orange[700],
                            child: Text('Host'),
                            onPressed: _gameNameAvailable &&
                                    _gameName.isNotEmpty &&
                                    _playerNameAvailable &&
                                    _playerName.isNotEmpty
                                ? () => _onClickHostGame(gameModel)
                                : null),
                        RaisedButton(
                            color: Colors.orange[700],
                            child: Text('Join'),
                            onPressed: !_gameNameAvailable &&
                                    _gameName.isNotEmpty &&
                                    _playerNameAvailable &&
                                    _playerName.isNotEmpty
                                ? () => _onClickJoinGame(gameModel)
                                : null),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
