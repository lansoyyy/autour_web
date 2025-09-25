import 'dart:js' as js;

/// JavaScript interop utility for TensorFlow.js people counting
class JsInterop {
  /// Count people in the video feed using TensorFlow.js
  /// Returns the number of people detected
  static Future<int> countPeople(String videoElementId) async {
    try {
      // Call the JavaScript function defined in index.html
      final result =
          await js.context.callMethod('countPeople', [videoElementId]);

      // Ensure the result is an integer
      if (result is int) {
        return result;
      } else if (result is double) {
        return result.toInt();
      } else if (result is String) {
        return int.tryParse(result) ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error calling countPeople JavaScript function: $e');
      return 0;
    }
  }

  /// Check if the TensorFlow.js model is loaded
  static Future<bool> isModelLoaded() async {
    try {
      final result = await js.context.callMethod('isModelLoaded', []);
      return result == true;
    } catch (e) {
      print('Error checking if model is loaded: $e');
      return false;
    }
  }
}
