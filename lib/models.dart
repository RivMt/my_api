library my_api;

import 'package:my_api/exceptions.dart';

const String keyId = "id";

const String keyPid = "pid";

const String keyLastUsed = "last_used";

const String keyOwner = "owner_id";

const String keyEditors = "editors_id";

const String keyDescriptions = "descriptions";

class Model {

  Map<String, dynamic> map = {};

  Model(this.map);

  Model.fromJson() {

  }

  getValue(String key) {
    if (map.containsKey(key)) {
      return map[key];
    }
    throw InvalidModelException(key);
  }

  int get id {
    return getValue(keyId);
  }

  int get pid {
    return getValue(keyPid);
  }

  DateTime get lastUsed {
    int lu = getValue(keyLastUsed);
    return DateTime.fromMillisecondsSinceEpoch(lu);
  }

  set lastUsed(DateTime dateTime) {
    map[keyLastUsed] = dateTime.millisecondsSinceEpoch;
  }

  String get owner {
    return getValue(keyOwner);
  }

  set owner(String id) {
    throw UnimplementedError();
  }

  List<String> get editors {
    return getValue(keyEditors);
  }

  set editors(List<String> list) {
    map[keyEditors] = list;
  }

  String get descriptions {
    return getValue(keyDescriptions);
  }

  set descriptions(String desc) {
    map[keyDescriptions] = desc;
  }

}