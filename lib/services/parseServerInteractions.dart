// import 'package:gunnars_test/data/GameModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:device_info/device_info.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io' show Platform;

Future<Map<String, String>> createUserCredentailsFromHardware() async {
  String _userId, _userPassword;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      _userPassword = (await deviceInfo.androidInfo).androidId;
    } else if (Platform.isIOS) {
      _userPassword = (await deviceInfo.iosInfo).identifierForVendor;
    }
    _userId = sha256.convert(utf8.encode(_userPassword)).toString();
    return Future.value({"userId": _userId, "userPassword": _userPassword});
  } catch (error) {
    print("NOOOOOOOOOOOO!!!!"); // NOOOOOOOOOOOO!!!!
    return Future.error(error);
  }
}

Future<void> initParse(userId, userPassword) async {
  await Parse().initialize('ZNTkzZ7nxKOu88Cza8qjaNcLTdJgvxe1FuVPb0TF',
      'https://parseapi.back4app.com',
      masterKey:
          DotEnv().env['PARSE_MASTERKEY'], // Required for Back4App and others
      // clientKey: keyParseClientKey, // Required for some setups
      debug: false, // When enabled, prints logs to console
      // liveQueryUrl: keyLiveQueryUrl, // Required if using LiveQuery
      autoSendSessionId: true, // Required for authentication and ACL
      // securityContext: securityContext, // Again, required for some setups
      coreStore: await CoreStoreSharedPrefsImp
          .getInstance()); // Local data storage method. Will use SharedPreferences instead of Sembast as an internal DB

  // Check server is healthy and live - Debug is on in this instance so check logs for result
  final ParseResponse response = await Parse().healthCheck();

  if (response.success) {
    print("PARSE CONNECTION HEALTHY");
    await loginOrSignup(userId, userPassword);
    print(response);
  } else {
    print("PARSE HEALTH NO GOOD");
  }
}

Future<void> loginOrSignup(userId, userPassword) async {
  ParseUser user;
  try {
    user = await ParseUser.currentUser();
    ParseResponse resp = await user.getUpdatedUser();
    if (!resp.success) {
      throw Exception("fuck you");
    }
    print("already logged in");
    return Future.value(user);
  } catch (error) {
    user = ParseUser(userId, userPassword, 'beg@mail.xyz');
    print("creating new user!!!");
    return user.signUp();
  }
}

Future<void> createGameSession(String name) async {
  print("creating gameSession $name");
  ParseUser user = await ParseUser.currentUser();
  ParseObject gameSession = ParseObject('GameSession')
    ..set('name', name)
    ..set('owner', user);
  return gameSession.save();
}

Future<void> joinGameSession(String name, String playerName,
    [bool asHunter = true]) async {
  QueryBuilder<ParseObject> query =
      QueryBuilder<ParseObject>(ParseObject('GameSession'))
        ..whereEqualTo('name', name);
  var resp = await query.query();
  if (resp.success) {
    ParseObject session = resp.results[0];
    ParseUser user = await ParseUser.currentUser();

    ParseObject player = ParseObject('Player')
      ..set("isHunter", asHunter)
      ..set("playerName", playerName)
      ..set("user", user);
    player.save();

    session.addRelation("participants", [player]);
  }
}

Future<bool> isGameNameAvailable(String value) async {
  print("Is game name $value available?");
  QueryBuilder<ParseObject> query =
      QueryBuilder<ParseObject>(ParseObject('GameSession'))
        ..whereEqualTo('name', value);

  var apiResponse = await query.query();
  if (apiResponse.success) {
    bool available = apiResponse.count == 0;
    print("Yes! game name $value is available on parse server");
    return Future.value(available);
  }
  return Future.error(
      'HEEEELVETE!! ITS ALL GUNNARS FAULT! BUT THIS WENT WRONG. SORRY. CANT HELP IT. DONT CRY. PLEASE.');
}

// TODO: Only check inside current gamesession. We allow duplicate names in different sessions!
Future<bool> isPlayerNameAvailable(String value) async {
  print("Is player name $value available? ");
  QueryBuilder<ParseObject> query =
      QueryBuilder<ParseObject>(ParseObject('Player'))
        ..whereEqualTo('playerName', value);

  var apiResponse = await query.query();
  if (apiResponse.success) {
    bool available = apiResponse.count == 0;
    print("Yes! playername $value is available on parse server");
    return Future.value(available);
  }
  return Future.error('HEEEELVETE!!');
}

Future<String> getAllGameSessions() async {
  var apiResponse = await ParseObject('GameSession').getAll();

  if (apiResponse.success) {
    for (var testObject in apiResponse.result) {
      print("Parse result: " + testObject.toString());
    }

    return apiResponse.results.toString();
  }

  return Future.error('no result');
}

Future<List<dynamic>> getPlayersForGameSession(String gameSessionId) async {
  QueryBuilder<ParseObject> playerQuery =
      QueryBuilder<ParseObject>(ParseObject('Player'))
        ..whereRelatedTo('participants', 'GameSession', gameSessionId);

  var apiResponse = await playerQuery.query();

  if (apiResponse.success && apiResponse.count > 0) {
    return apiResponse.results;
  }
  return Future.error('no result');
}

Future<List<dynamic>> getLocationsForGameSession(
    String gameSessionId, bool hunters) async {
  QueryBuilder<ParseObject> playerQuery =
      QueryBuilder<ParseObject>(ParseObject('Player'))
        ..whereRelatedTo('participants', 'GameSession', gameSessionId)
        ..whereEqualTo('isHunter', hunters);

  // QueryBuilder<ParseObject> sessionQuery =
  //   QueryBuilder<ParseObject>(ParseObject('GameSession'))
  //     ..whereEqualTo('objectId', 'RVpzsL3tST');

  QueryBuilder<ParseObject> queryBuilder =
      QueryBuilder<ParseObject>(ParseObject('Location'))
        ..whereEqualTo('visibleByDefault', true)
        ..whereMatchesQuery('player', playerQuery);

  // var apiResponse = await queryBuilder.query();
  var apiResponse = await queryBuilder.query();

  // var apiResponse = await ParseObject('Locations').;

  if (apiResponse.success && apiResponse.count > 0) {
    print("\\\\\\\\\\\\\\");
    print(apiResponse.count);

    return apiResponse.results;
  }

  return Future.error('no result');
}
