import 'dart:io';
import 'package:flutter/foundation.dart';

Future<Uint8List> fetchImageBytes(String url) async {
  final client = HttpClient();
  
  // Configure client for better iOS compatibility
  client.connectionTimeout = const Duration(seconds: 30);
  client.idleTimeout = const Duration(seconds: 30);
  
  try {
    final request = await client.getUrl(Uri.parse(url));
    
    // Add headers for better compatibility with file access tokens
    request.headers.set('Accept', 'image/*');
    request.headers.set('User-Agent', 'CometChat-Flutter-SDK');
    
    final response = await request.close();
    
    // Check for successful response
    if (response.statusCode != 200) {
      throw HttpException('Failed to load image: ${response.statusCode}', uri: Uri.parse(url));
    }
    
    return await consolidateHttpClientResponseBytes(response);
  } finally {
    client.close();
  }
}