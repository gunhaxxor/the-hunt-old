import 'package:flutter/material.dart';
// import 'package:gunnars_test/main.dart';

import 'package:gunnars_test/services/parseServerInteractions.dart';

class StartScreen extends StatefulWidget {
  @override
  State<StartScreen> createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  bool _gameNameAvailable = false;
  bool _playerNameAvailable = false;
  String _sessionName = "";
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

  void _onClickHostGame() async {
    await createGameSession(_sessionName, _playerName);
    Navigator.pushReplacementNamed(context, '/lobby');
  }

  void _onClickJoinGame() async {
    await joinGameSession(_sessionName, _playerName);
    Navigator.pushReplacementNamed(context, '/lobby');
  }

  @override
  Widget build(BuildContext context) {
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
                        fontSize: 72,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 4
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
                          bool free = await isPlayerNameAvailable(value);
                          setState(() {
                            _playerNameAvailable = free;
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
                          bool free = await isGameNameAvailable(value);
                          print(free);
                          setState(() {
                            _gameNameAvailable = free;
                            _sessionName = value;
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
                            onPressed:
                                _gameNameAvailable && _sessionName.isNotEmpty
                                    ? _onClickHostGame
                                    : null),
                        RaisedButton(
                            color: Colors.orange[700],
                            child: Text('Join'),
                            onPressed:
                                _gameNameAvailable && _sessionName.isEmpty
                                    ? null
                                    : _onClickJoinGame),
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