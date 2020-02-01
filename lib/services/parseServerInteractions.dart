import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

Future<String> getLocation() async {
  QueryBuilder<ParseObject> playerQuery =
    QueryBuilder<ParseObject>(ParseObject('Player'))
      ..whereRelatedTo('participants', 'GameSession', 'RVpzsL3tST');


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

  if (apiResponse.success) {
    print("\\\\\\\\\\\\\\");
    for (var testObject in apiResponse.result) {
      print("Parse result: " + testObject.toString());
      print("/////");
    }

    return apiResponse.results.toString();
  }

  return Future.error('no result');
}
