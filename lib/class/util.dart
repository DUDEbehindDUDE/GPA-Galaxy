import 'package:flutter/material.dart';

class Util {
  bool startsWithVowel(String str) {
    return str.startsWith(RegExp("[AaEeIiOoUu]"));
  }

  String getActionFromScreenName(String str) {
    return switch(str) {
      "grades" => "Add a class...",
      "activities" => "Add an activity...",
      _ => "Add $str..."
    };
  }

  Widget getNewItemDialogFromName(String str, dynamic args) {
    return switch(str) {
      // "grades" => ,
      _ => throw("Item not ")
    };
  }
}