// class Location extends ParseObject implements ParseCloneable {
//   Location() : super(_keyTableName);
//   DietPlan.clone() : this();

//   /// Looks strangely hacky but due to Flutter not using reflection, we have to
//   /// mimic a clone
//   @override
//   clone(Map map) => Location.clone()..fromJson(map);

//   static const String _keyTableName = 'Diet_Plans';
//   static const String keyName = 'Name';

//   String get name => get<String>(keyName);
//   set name(String name) => set<String>(keyName, name);
// }
