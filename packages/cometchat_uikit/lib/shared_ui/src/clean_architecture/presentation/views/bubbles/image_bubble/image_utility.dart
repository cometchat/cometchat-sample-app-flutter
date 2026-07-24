import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<Uint8List> fetchImageBytes(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return response.bodyBytes;
  }
  throw Exception('Failed to fetch image: ${response.statusCode}');
}
