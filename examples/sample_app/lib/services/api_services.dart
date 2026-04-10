import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_model.dart';

class ApiServices {
  static Future<List<SampleUserModel>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('https://assets.cometchat.io/sampleapp/sampledata.json'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['users'] ?? [];
        return data
            .map((user) => SampleUserModel(
                  user['name'] ?? "",
                  user['uid'] ?? "",
                  user['avatar'] ?? "",
                ))
            .toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      debugPrint('Exception while fetching users: $e');
      return getDefaultUsers();
    }
  }

  static Future<List<SampleUserModel>> getDefaultUsers() async {
    String jsonString = await rootBundle.loadString('assets/sample_data.json');
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final List<dynamic> data = jsonData['users'] ?? [];
    return data
        .map((user) => SampleUserModel(
              user['name'] ?? "",
              user['uid'] ?? "",
              user['avatar'] ?? "",
            ))
        .toList();
  }
}
