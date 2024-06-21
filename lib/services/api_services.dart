import 'package:cometchat_flutter_sample_app/models/material_button_user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ApiServices {

  // Fetch users from the API

  static Future<List<MaterialButtonUserModel>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('https://assets.cometchat.io/sampleapp/sampledata.json'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['users'] ?? [];
        final List<MaterialButtonUserModel> userList = data
            .map((user) => MaterialButtonUserModel(
                  user['name'] ?? "",
                  user['uid'] ?? "",
                  user['avatar'] ?? "",
                ))
            .toList();
        return userList;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      debugPrint('Exception while fetching users: $e');
      // Handle exception here, load users from local asset
      return getDefaultUsers();
    }
  }

  // Load default users from local asset
  static Future<List<MaterialButtonUserModel>> getDefaultUsers() async {
    Map<String, dynamic> jsonData =
        await loadJsonFromAssets('assets/sample_app/sample_data.json');
    final List<dynamic> data = jsonData['users'] ?? [];
    final List<MaterialButtonUserModel> userList = data
        .map((user) => MaterialButtonUserModel(
              user['name'] ?? "",
              user['uid'] ?? "",
              user['avatar'] ?? "",
            ))
        .toList();
    return userList;
  }

  // Load JSON from local asset
  static Future<Map<String, dynamic>> loadJsonFromAssets(
      String filePath) async {
    String jsonString = await rootBundle.loadString(filePath);
    return jsonDecode(jsonString);
  }
}
