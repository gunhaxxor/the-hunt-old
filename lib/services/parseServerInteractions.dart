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

Future<bool> isNameAvailable(String value) async {
  print("Checking if name taaaken");
  QueryBuilder<ParseObject> query =
      QueryBuilder<ParseObject>(ParseObject('GameSession'))
        ..whereEqualTo('name', value);

  var apiResponse = await query.query();
  if (apiResponse.success) {
    return Future.value(apiResponse.count == 0);
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
    for (var testObject in apiResponse.result) {
      //print("Parse result: " + testObject.toString());
      //print("/////");
    }

    return apiResponse.results;
  }

  return Future.error('no result');
}
