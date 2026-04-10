import 'dart:convert';

import 'package:http/http.dart' as http;

class NetworkUtils {
  static Future<http.Response> postData(
      String url, Map<String, String> header, Map<String, dynamic> body) {
    final msg = jsonEncode(body);

    return http.post(Uri.parse(url), headers: header, body: msg);
  }

  static Future<http.Response> patchData(
      String url, Map<String, String> header, Map<String, dynamic> body) {
    return http.patch(Uri.parse(url), headers: header, body: body);
  }

  static Future<http.Response> delete(
      String url, Map<String, String> header, Map<String, dynamic> body) {
    return http.delete(Uri.parse(url), headers: header, body: body);
  }

  static Future<http.Response> put(
      String url, Map<String, String> header, Map<String, dynamic> body) {
    return http.put(Uri.parse(url), headers: header, body: body);
  }
}
