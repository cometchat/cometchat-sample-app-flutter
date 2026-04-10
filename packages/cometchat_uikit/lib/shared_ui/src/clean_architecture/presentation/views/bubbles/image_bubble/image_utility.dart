import 'dart:io';
import 'package:flutter/foundation.dart';

Future<Uint8List> fetchImageBytes(String url) async {
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse(url));
  final response = await request.close();

  return await consolidateHttpClientResponseBytes(response);
}