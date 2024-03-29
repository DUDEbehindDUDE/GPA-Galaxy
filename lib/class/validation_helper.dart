class ValidationHelper {
  
  /// Validates the input text based on specified constraints.
  ///
  /// Returns the parsed input if validation is successful.
  /// If validation fails, returns null.
  ///
  /// Parameters:
  ///   - [text]: The input text to be validated.
  ///   - [type]: The data type expected for the input.
  ///   - [min]: The minimum value allowed for the input.
  ///   - [max]: The maximum value allowed for the input.
  ///
  /// Returns:
  ///   - The parsed input if validation is successful, else null.
  static dynamic validateItem({required String text, Type? type, int? min, int? max}) {
    if (validateItemErrorText(text: text, type: type, min: min, max: max) != null) {
      return null;
    }

    if (type == num || type == double) {
      return double.parse(text);
    }
    if (type == int) {
      return int.parse(text);
    }

    return text;
  }

  /// Validates the input text and returns an error message if validation fails.
  ///
  /// Returns null if the input is valid.
  /// If validation fails, returns an error message describing the reason.
  ///
  /// Parameters:
  ///   - [text]: The input text to be validated.
  ///   - [type]: The data type expected for the input.
  ///   - [min]: The minimum value allowed for the input.
  ///   - [max]: The maximum value allowed for the input.
  ///   - [short]: A flag indicating whether to return short error messages.
  ///
  /// Returns:
  ///   - Null if the input is valid, else an error message.
  static String? validateItemErrorText({String? text, Type? type, int? min, int? max, short = false}) {
    if (text == null || text.isEmpty) {
      return short ? "Cannot be empty" : "Field cannot be left empty";
    }
    if (text.length > 50) {
      return short ? "${text.length}/50 characters" : "Field exceeds character limit (${text.length}/50)";
    }
    if (type == int || type == double || type == num) {
      String errorText = "";
      if (min != null && max != null) {
        errorText = "between $min and $max";
      } else if (min != null) {
        errorText = "greater or equal to $min";
      } else if (max != null) {
        errorText = "less than or equal to $max";
      }
      
      // check type
      num? number;
      if (type == int) {
        number = int.tryParse(text);
        errorText = short ? "Must be an integer" : "Field must be an integer $errorText";
      } else {
        number = double.tryParse(text);
        errorText = short ? "Must be a number" : "Field must be a number $errorText";
      }

      if (number == null || number != number || text.toLowerCase().contains("infinity")) {
        return errorText;
      }
      if (min != null && number < min) {
        return short ? "Must be $min or more" : errorText;
      }
      if (max != null && number > max) {
        return short ? "Must be $max or less" : errorText;
      }

    }

    return null;
  }
}