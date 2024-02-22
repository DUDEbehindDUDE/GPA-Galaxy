import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DatabaseHelper {
  static Future<DatabaseHelper> create(String database) async {
    await Hive.openBox(database);

    var component = DatabaseHelper._create(database);

    return component;
  }

  DatabaseHelper._create(this.database) {
    box = Hive.box(database);
  }

  final String database;
  late Box box;

  List<dynamic> getItems(String grade) {
    dynamic boxItems = box.get(grade);

    if (boxItems == null) {
      return [];
    }

    return boxItems;
  }

  List<dynamic> getAllItems() {
    var allItems = box.values.toList();
    return allItems;
  }

  void addItem(grade, item) {
    var box = Hive.box(database);
    List boxItems;
    boxItems = box.get(grade, defaultValue: []);

    boxItems.add(item);
    Hive.box(database).put(grade, boxItems);
  }

  ValueListenable<Box<dynamic>> getListener() {
    return box.listenable();
  }
}