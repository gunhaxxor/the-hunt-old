import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gunnars_test/screens/lobbyscreen.dart';
import 'package:gunnars_test/screens/mainscreen.dart';
import 'package:gunnars_test/screens/gamescreen.dart';

Future main() async {
  await DotEnv().load('.env');
  runApp(MaterialApp(home: MainScreen(), // becomes the route named '/'
      routes: <String, WidgetBuilder>{
        '/game': (BuildContext context) => GameScreen(),
        '/lobby': (BuildContext context) => LobbyScreen(),
      }));
}
