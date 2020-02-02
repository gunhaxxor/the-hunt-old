import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gunnars_test/data/GameModel.dart';
import 'package:gunnars_test/screens/lobbyscreen.dart';
import 'package:gunnars_test/screens/startscreen.dart';
import 'package:gunnars_test/screens/gamescreen.dart';
import 'package:provider/provider.dart';

Future main() async {
  await DotEnv().load('.env');
  runApp(MainWidget());
}

class MainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameModel>(
        create: (context) => GameModel(),
        child: MaterialApp(home: GameScreen(), // becomes the route named '/'
            routes: <String, WidgetBuilder>{
              '/game': (BuildContext context) => GameScreen(),
              '/lobby': (BuildContext context) => LobbyScreen(),
            }));
  }
}
