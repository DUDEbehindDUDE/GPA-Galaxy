import 'dart:math';

class Math {
  double roundToDecimalPlaces(double number, int decimalPlaces) {
    return (number * pow(10, decimalPlaces)).roundToDouble() / pow(10, decimalPlaces); 
  }
}