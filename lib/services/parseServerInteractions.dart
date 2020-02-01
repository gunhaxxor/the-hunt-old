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
    ParseUser user = ParseUser(userId, userPassword, "beg@gmail.com");
    var response = await user.signUp();
    print(response);
  } else {
    print("PARSE HEALTH NO GOOD");
  }

  //Testing if we gamesession name is taken
  isNameAvailable("bajs");
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
