import 'package:http/http.dart' as http;

Future<bool> validateURL(String input) async {
  if (input.isNotEmpty) {
    try {
      final uri = Uri.parse(input);
      if (!uri.isAbsolute) {
        // URL is not absolute (missing host)
        return false;
      }

      final response = await http.head(uri);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (e is http.ClientException &&
          e.message.toString().contains('Invalid statusCode: 404')) {
        // URL is valid but the resource is not found
        return false;
      } else {
        // Request failed due to other reasons
        return false;
      }
    }
  } else {
    // Empty URL
    return false;
  }
}
